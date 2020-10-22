import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'misc.dart';

Widget requestForm(context) {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final _formKey = GlobalKey<FormState>();

  String _sender;
  double _amount;
  bool _submitEnabled = true;

  void receiveRequest(innerContext) async {
    // await the uid of the sender
    String senderUid;
    double senderBalanceGoal;
    Future<QuerySnapshot> _future = users
        .where('username', isEqualTo: _sender)
        .get();
    await _future.then((QuerySnapshot value) {
      if(value.size != 1) {
        showDialogBox('Error processing request', 'Found ${value.size} users with this username.', context);
        return;
      }
      QueryDocumentSnapshot retrievedDoc = value.docs.first;
      senderUid = retrievedDoc.id;
      // TODO: think long and hard about how balance goal should be calculated, comment thoughts
      senderBalanceGoal = retrievedDoc.data()['balance'] - _amount;
    });

    // write out the request - pending status is now true
    User userCredential = FirebaseAuth.instance.currentUser;
    users.doc(userCredential.uid)
        .update({
      'pending': true,
      'pending_user': _sender,
      'pending_amount': _amount
    });

    // subscribe to changes in the sender's doc
    int subscriptionEventCount = 0;
    Stream<DocumentSnapshot> senderDocumentStream = FirebaseFirestore.instance.collection('users').doc(senderUid).snapshots();
    StreamSubscription<DocumentSnapshot> senderSubscription = senderDocumentStream.listen((event) {
      subscriptionEventCount += 1;
      if (subscriptionEventCount == 2) {
        // this is the first time our target user (sender) updated their document since we started listening
        // (one event always fires once the subscription is set up)
        double newBalance = event.data()['balance'];
        if (newBalance == senderBalanceGoal) {
          // hooray! we can now perform the transaction on our end
        } else {
          final snackBar = SnackBar(content: Text('Invalid result read from sender.'));
          Scaffold.of(innerContext).showSnackBar(snackBar);
        }
      }
    });

    // wait 20 seconds to time out
    var timeoutFuture = Future.delayed(Duration(seconds: 20));
    await timeoutFuture.then((value) {
      // show a snackbar to indicate the outcome after 20 seconds
      // TODO: show a snackbar once the transaction has gone through - in this case a snackbar after 20 seconds is unnecessary
      String snackBarText;
      switch (subscriptionEventCount) {
        case 0:
          snackBarText = 'Timed out: no events received from subscription.';
          break;
        default:
          snackBarText = 'Timed out.';
          break;
      }
      final snackBar = SnackBar(content: Text(snackBarText));
      Scaffold.of(context).showSnackBar(snackBar);

      // stop listening to sender's document
      senderSubscription.cancel();
    });
    // now this method terminates and onPressed can continue
  }

  // TODO: split this up into multiple parts because the current indentation is just nasty!
  return Form(key: _formKey,
    child: Container(
      padding: EdgeInsets.all(10),
      child: Scaffold(
        body: Builder(
          // create an inner BuildContext so that the onPressed methods
          // can refer to the Scaffold with Scaffold.of()
          builder: (BuildContext innerContext) {
            return Column(
              children: <Widget>[
                Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  child: TextFormField(
                    validator: (value) {
                      if (value == '') {
                        return 'Empty field';
                      }
                      _sender = value;
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Sender\'s username',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  child: TextFormField(
                    validator: (value) {
                      if (value == '') {
                        return 'Empty field';
                      } else if (!isNumeric(value)){
                        return 'Not a number';
                      }
                      _amount = double.parse(value);
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Amount',
                    ),
                  ),
                ),
                Spacer(flex: 3),
                RaisedButton(
                  child: Text('Submit'),
                  onPressed: () async {
                    // this function is async so that _submitEnabled can block multiple requests from coming in at once
                    // TODO: add an indicator that the request is in progress and the button is unavailable
                    if (_submitEnabled && _formKey.currentState.validate()) {
                      _submitEnabled = false;
                      await receiveRequest(innerContext);
                      _submitEnabled = true;
                    }
                  },
                ),
                Spacer()
              ],
            );
          }
        )
      )
    )
  );
}
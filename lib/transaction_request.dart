import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'wallet.dart';
import 'misc.dart';

class RequestScreen extends StatefulWidget {
  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final _formKey = GlobalKey<FormState>();

  String _sender;
  double _amount;
  bool _submitEnabled = true;

  void receiveRequest(myContext) async {
    // await the uid of the sender
    String senderUid;
    double senderBalanceGoal;
    Future<QuerySnapshot> senderFuture = users
        .where('username', isEqualTo: _sender)
        .get();
    await senderFuture.then((QuerySnapshot value) {
      if(value.size != 1) {
        showDialogBox('Error processing request', 'Found ${value.size} users with this username.', myContext);
        return;
      }
      QueryDocumentSnapshot retrievedDoc = value.docs.first;
      senderUid = retrievedDoc.id;
      // sender should deduct the agreed amount from their balance
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
    bool transactionCompleted = false;
    Stream<DocumentSnapshot> senderDocumentStream = FirebaseFirestore.instance.collection('users').doc(senderUid).snapshots();
    StreamSubscription<DocumentSnapshot> senderSubscription = senderDocumentStream.listen((event) {
      subscriptionEventCount += 1;
      if (subscriptionEventCount == 2) {
        // this is the first time our target user (sender) updated their document since we started listening
        // (one event always fires once the subscription is set up)
        double newBalance = event.data()['balance'] * 1.0; // ENSURE this is a double
        if (newBalance == senderBalanceGoal) {
          // clear own pending status and perform transaction
          // TODO: add to debt
          users.doc(userCredential.uid)
              .update({
            'balance': BalanceStore.balance + _amount,
            'pending': false,
            'pending_user': '',
            'pending_amount': 0
          });
        } else {
          final snackBar = SnackBar(content: Text('Invalid result read from sender.'));
          Scaffold.of(myContext).showSnackBar(snackBar);
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
      Scaffold.of(myContext).showSnackBar(snackBar);

      // stop listening to sender's document
      senderSubscription.cancel();
    });
    // now this method terminates and onPressed can continue
  }

  @override
  Widget build(BuildContext context) {
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
}
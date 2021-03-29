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
    String senderUid;
    double senderBalanceGoal;
    Map<String, dynamic> myDebts =
        Map<String, dynamic>.from(UserDocStore.userDoc['debts']);
    bool stillPending = true;
    bool transactionAttempted = false;

    // request the sender's doc and await the result
    var senderFuture = await users.where('username', isEqualTo: _sender).get();

    // if the number of matching users is NOT 1, show an error message and escape (return)
    if (senderFuture.size != 1) {
      showDialogBox('Error processing request',
          'Found ${senderFuture.size} users with this username.', myContext);
      return;
    }

    // the future returned just one result - success!
    QueryDocumentSnapshot retrievedDoc = senderFuture.docs.first;
    senderUid = retrievedDoc.id;
    // sender should deduct the agreed amount from their balance
    senderBalanceGoal = retrievedDoc.data()['balance'] - _amount;

    final snackBar = SnackBar(content: Text("Processing request"));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // write out the request - pending status is now true
    User userCredential = FirebaseAuth.instance.currentUser;
    users.doc(userCredential.uid).update({
      'pending': true,
      'pending_user': _sender,
      'pending_amount': _amount
    }).catchError((error) {
      showDialogBox(
          'Error updating user doc', "Err01: " + error.toString(), myContext);
    });

    // subscribe to changes in the sender's doc
    int subscriptionEventCount = 0;
    Stream<DocumentSnapshot> senderDocumentStream = FirebaseFirestore.instance
        .collection('users')
        .doc(senderUid)
        .snapshots();
    StreamSubscription<DocumentSnapshot> senderSubscription =
        senderDocumentStream.listen((event) {
      subscriptionEventCount += 1;
      if (subscriptionEventCount == 2 && stillPending) {
        // this is the first time our target user (sender) updated their document since we started listening
        // (one event always fires once the subscription is set up)
        double newBalance =
            event.data()['balance'] * 1.0; // ENSURE this is a double
        if (newBalance == senderBalanceGoal) {
          // clear own pending status and attempt to perform transaction
          transactionAttempted = true;

          // update debts map
          myDebts.update(_sender, (var value) => value + _amount,
              ifAbsent: () => _amount);

          // perform transaction by updating own user doc!
          users.doc(userCredential.uid).update({
            'balance': BalanceStore.balance + _amount,
            'debts': myDebts,
            'pending': false,
            'pending_user': '',
            'pending_amount': 0,
          }).then((value) {
            final snackBar = SnackBar(content: Text('Transaction successful'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }).catchError((error) {
            showDialogBox('Error updating user doc',
                "Err02: " + error.toString(), myContext);
          });
        } else {
          final snackBar =
              SnackBar(content: Text('Invalid result read from sender.'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    });

    // wait 20 seconds to time out
    var timeoutFuture = Future.delayed(Duration(seconds: 10));
    await timeoutFuture.then((value) {
      // show a snackbar if no transaction came through in 10 seconds
      if (!transactionAttempted) {
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
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }

      // remove pending state
      stillPending = false;
      users.doc(userCredential.uid).update({
        'pending': false,
        'pending_user': '',
        'pending_amount': 0,
      }).catchError((error) {
        showDialogBox(
            'Error updating user doc', "Err03: " + error.toString(), myContext);
      });

      // stop listening to sender's document
      senderSubscription.cancel();
    });
    // now this method terminates and onPressed can continue
  }

  @override
  Widget build(BuildContext context) {
    // TODO: split this up into multiple parts because the current indentation is just nasty!
    return Form(
      key: _formKey,
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
                        } else if (!isNumeric(value)) {
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
                  ElevatedButton(
                    child: Text('Submit'),
                    onPressed: () async {
                      // this function is async so that _submitEnabled can block multiple requests from coming in at once
                      // TODO: add an indicator that the request is in progress and the button is unavailable
                      if (_submitEnabled && _formKey.currentState.validate()) {
                        _formKey.currentState.reset();
                        _submitEnabled = false;
                        await receiveRequest(innerContext);
                        _submitEnabled = true;
                      }
                    },
                  ),
                  Spacer()
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

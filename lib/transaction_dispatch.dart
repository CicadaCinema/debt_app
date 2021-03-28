import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'wallet.dart';
import 'misc.dart';

class DispatchScreen extends StatefulWidget {
  @override
  _DispatchScreenState createState() => _DispatchScreenState();
}

class _DispatchScreenState extends State<DispatchScreen> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final _formKey = GlobalKey<FormState>();

  String _recipient;
  double _amount;

  void dispatchRequest(myContext) {
    User userCredential = FirebaseAuth.instance.currentUser;
    String myDisplayName = userCredential.displayName;
    Map<String, dynamic> myDebts = Map<String, dynamic>.from(UserDocStore.userDoc['debts']);
    Future<QuerySnapshot> recipientFuture = users
        .where('username', isEqualTo: _recipient)
        .get();

    recipientFuture.then((QuerySnapshot value) {
      // various errors are shown as dialog boxes
      String errorMessage;
      if (value.size != 1) {
        errorMessage = 'Found ${value.size} users with this username.';
      } else if (value.docs.first.data()['pending'] != true) {
        errorMessage = 'Receiver is not pending';
      } else if (value.docs.first.data()['pending_user'] != myDisplayName) {
        errorMessage = 'Username does not match';
      } else if (value.docs.first.data()['pending_amount'] != _amount) {
        errorMessage = 'Amount does not match';
      } else {
        // attempt to perform transaction

        // update debts map
        myDebts.update(
          _recipient,
          (var value) => value - _amount,
          ifAbsent: () => -1 * _amount);

        users.doc(userCredential.uid)
            .update({
          'balance': BalanceStore.balance - _amount,
          'debts': myDebts,
        })
            .then((value) {
          final snackBar = SnackBar(content: Text('Transaction successful'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        })
            .catchError((error) {
          showDialogBox('Error updating user doc', "Err04: " + error.toString(), myContext);
        });
        return;
      }
      showDialogBox('Error processing request', errorMessage, myContext);
    })
        .catchError((error) {
      showDialogBox('Cloud Firestore error', 'Error retrieving data: ' + error.toString(), myContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(key: _formKey,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Scaffold(
          body: Builder(
            // create an inner BuildContext so that the onPressed methods
            // can refer to the Scaffold with Scaffold.of()
            builder: (BuildContext innerContext) {
              return Container(
                child: Column(
                  children: <Widget>[
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                      child: TextFormField(
                        validator: (value) {
                          if (value == '') {
                            return 'Empty field';
                          }
                          _recipient = value;
                          return null;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Recipient\'s username',
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
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          dispatchRequest(innerContext);
                        }
                      },
                    ),
                    Spacer()
                  ],
                ),
              );
            }
          ),
        )
      )
    );
  }
}
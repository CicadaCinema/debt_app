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

  //String _recipient;
  //double _amount;

  // performs transaction of a specific amount to specific user
  void dispatchRequest(myContext, recipient, amount) {
    User userCredential = FirebaseAuth.instance.currentUser;
    //String myDisplayName = userCredential.displayName;
    Map<String, dynamic> myDebts = Map<String, dynamic>.from(UserDocStore.userDoc['debts']);

    // attempt to perform transaction
    // update debts map
    myDebts.update(
        recipient,
            (var value) => value - amount,
        ifAbsent: () => -1 * amount);

    users.doc(userCredential.uid)
        .update({
      'balance': BalanceStore.balance - amount,
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

  @override
  Widget build(BuildContext context) {
    return Form(key: _formKey,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Scaffold(
          body: Builder(
            // create an inner BuildContext so that the onPressed methods
            // can refer to the Scaffold with Scaffold.of()
            // TODO: padding is gone after refactoring to ScaffoldMessenger (also gone in transaction_request.dart) - fix this
            builder: (BuildContext innerContext) {
              return Center(
                child: Column(
                  children: <Widget>[
                    Spacer(),
                    /*Padding(
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
                    ),*/
                    StreamBuilder<QuerySnapshot>(
                      stream: users.where('pending_user', isEqualTo: FirebaseAuth.instance.currentUser.displayName).snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        String textMessage;

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          textMessage = "Loading...";
                        } else if (snapshot.hasData) {
                          if (snapshot.data.docs.length == 0) {
                            textMessage = "Waiting for requests from other users...";
                          } else if (snapshot.data.docs.length == 1){
                            // YES - there is exactly one request targeted at the user right now
                            // this is the desired state for a transaction
                            Map<String, dynamic> documentData = snapshot.data.docs[0].data();
                            return ElevatedButton(
                                onPressed: () {
                                  dispatchRequest(innerContext, documentData["username"], documentData["pending_amount"]);
                                },
                                child: Text('Send £${documentData["pending_amount"].toStringAsFixed(2)} to ${documentData["username"]}'),
                            );
                          } else {
                            textMessage = "Err05: Multiple requests in progress.";
                          }
                        } else if (snapshot.hasError) {
                          textMessage = "Err06: " + snapshot.error.toString();
                        }

                        else {
                          textMessage = "Err07: Please report this error.";
                        }

                        return Text(textMessage);
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
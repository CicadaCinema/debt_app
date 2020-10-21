import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'misc.dart';

Widget dispatchForm(context) {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final _formKey = GlobalKey<FormState>();

  String _recipient;
  double _amount;

  void dispatchRequest(){
    String _uid = FirebaseAuth.instance.currentUser.uid;
    Future<QuerySnapshot> _future = users
        .where('username', isEqualTo: _recipient)
        .get();

    _future.then((QuerySnapshot value) {
      if(value.size == 0){
        showDialogBox('Error processing request', 'Invalid username', context);
        return;
      } else if (value.docs.first.data()['pending_amount'] != _amount){
        showDialogBox('Error processing request', 'Amount does not match', context);
      } else {
        showDialogBox('Transaction', 'Perform transaction!', context);
      }
    })
        .catchError((error) {
      showDialogBox('Cloud Firestore error', 'Error retrieving data: ' + error, context);
    });
  }

  return Form(key: _formKey,
      child: Container(
        padding: EdgeInsets.all(10),
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
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  dispatchRequest();
                }
              },
            ),
            Spacer()
          ],
        ),
      )
  );
}
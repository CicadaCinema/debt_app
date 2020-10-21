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

  void receiveRequest() async {
    // TODO: this block needs more error checking
    // wait for the uid of the sender
    String senderUid;
    Future<QuerySnapshot> _future = users
        .where('username', isEqualTo: _sender)
        .get();
    await _future.then((QuerySnapshot value) {
      if(value.size == 0) {
        showDialogBox('Error processing request', 'Invalid username', context);
        return;
      }
      senderUid = value.docs.first.id;
    });

    // write out the request - pending status is now true
    User userCredential = FirebaseAuth.instance.currentUser;
    users
        .doc(userCredential.uid)
        .update({
      'pending': true,
      'pending_user': _sender,
      'pending_amount': _amount
    });

    // subscribe to changes in the sender's document
    Stream senderDocumentStream = FirebaseFirestore.instance.collection('users').doc(senderUid).snapshots();

    // this could be used in conjunction with the block below to time out - break the for loop somehow?
    // or maybe the sender's document is checked just once, after this time interval has completed?
    var timeoutFuture = Future.delayed(Duration(seconds: 30));
    timeoutFuture.then((value) {
      print('TIMED OUT');
      return;
    });

    // senderDocumentStream always fires once, even without any updates
    int patience = 0;
    await for (var value in senderDocumentStream) {
      patience ++;
      if (patience == 2){
        // check to see if value matches what we were expecting
        return;
      }
    }
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
              // TODO: add a snack bar here or something?
              if (_submitEnabled && _formKey.currentState.validate()) {
                _submitEnabled = false;
                await receiveRequest();
                _submitEnabled = true;
              }
            },
          ),
          Spacer()
        ],
      ),
    )
  );
}
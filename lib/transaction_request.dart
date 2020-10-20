import 'package:flutter/material.dart';

Widget requestForm() {
  final _formKey = GlobalKey<FormState>();

  return Form(key: _formKey,
    child: Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
            child: TextFormField(
              validator: (value) {
                if (value == '') {
                  return 'Empty field';
                }
                return null;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Destination user',
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
            child: TextFormField(
              validator: (value) {
                if (value == '') {
                  return 'Empty field';
                }
                return null;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Amount',
              ),
            ),
          ),
          RaisedButton(
            child: Text('Submit'),
            onPressed: () {
              if (_formKey.currentState.validate()) {

              }
            },
          ),
        ],
      ),
    )
  );
}
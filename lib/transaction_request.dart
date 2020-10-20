import 'package:flutter/material.dart';

Widget requestForm() {
  final _formKey = GlobalKey<FormState>();

  return Form(key: _formKey,
    child: Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          TextFormField(
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
          SizedBox(height:32),
          TextFormField(
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
          SizedBox(height:64),
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
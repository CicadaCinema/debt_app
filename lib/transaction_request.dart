import 'package:flutter/material.dart';

import 'misc.dart';

Widget requestForm(context) {
  final _formKey = GlobalKey<FormState>();

  String _sender;
  double _amount;

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
            onPressed: () {
              if (_formKey.currentState.validate()) {

              }
            },
          ),
          Spacer()
        ],
      ),
    )
  );
}
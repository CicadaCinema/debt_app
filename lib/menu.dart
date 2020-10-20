import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'misc.dart';
import 'transaction_request.dart';

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  String _uid = FirebaseAuth.instance.currentUser.uid;
  String _username = "My";
  String _balance = "loading ...";

  Map<String, num> _map = {
    "UserA": -99.99,
    "UserB": 0.5,
    "UserC" : 90,
  };

  // not really sure how this returns a nice table from a map
  // but it does do that quite nicely
  Widget _showTable(Map<String, num> inputMap) {
    return DataTable(
      columns: const <DataColumn>[
        DataColumn(label: Text('User')),
        DataColumn(label: Text('Amount')),
      ],
      rows: inputMap.entries
          .map((e) => DataRow(cells: [
        DataCell(Text(e.key.toString())),
        DataCell(Text(e.value.toString())),
      ]))
          .toList(),
    );
  }

  void _getBalance() {
    Future<DocumentSnapshot> _future = users.doc(_uid).get();
    _future.then((DocumentSnapshot value) {
      Map<String, dynamic> retrievedData = value.data();
      _username =retrievedData['username'] + '\'s';
      _balance = '£' + value.data()['balance'].toStringAsFixed(2);
      setState(() {});
    })
        .catchError((error) {
          showDialogBox('Cloud Firestore error', 'Error retrieving user data', context);
        });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        bottomNavigationBar: Container(
          // TODO: theme this according to the main app theme
          color: Colors.green,
          child: TabBar(
            indicatorColor: Colors.greenAccent,
            tabs: [
              Tab(text: 'Wallet', icon: Icon(Icons.account_balance)),
              Tab(text: 'Transaction', icon: Icon(Icons.attach_money)),
              Tab(text: 'Breakdown', icon: Icon(Icons.search)),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text('Debt App'),
          automaticallyImplyLeading: false,
        ),
        body: TabBarView(
          children: [
            Center(
              child: Column(
                children: [
                  Spacer(flex: 3),
                  //Text('Current route:' + ModalRoute.of(context).settings.name),
                  Text(
                    '${_username} balance:',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _balance,
                    style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
                  ),
                  Spacer(flex: 3),
                  RaisedButton(
                    onPressed: (){
                      _getBalance();
                    },
                    child: Text(
                      'Update',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Spacer(),
                ],
              )
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  requestForm(),
                  Spacer(flex: 3),
                  FlatButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    child: Text('Sign out'),
                  ),
                  Spacer()
                ],
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: _showTable(_map),
              )
            ),
          ],
        ),
      ),
    );
  }
}
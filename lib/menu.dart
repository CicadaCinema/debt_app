import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'misc.dart';
import 'wallet.dart';
import 'transaction_dispatch.dart';
import 'transaction_request.dart';

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        bottomNavigationBar: Container(
          // TODO: theme this according to the main app theme
          color: Colors.green,
          child: TabBar(
            indicatorColor: Colors.greenAccent,
            tabs: [
              Tab(text: 'Wallet', icon: Icon(Icons.account_balance)),
              Tab(text: 'Send', icon: Icon(Icons.send)),
              Tab(text: 'Receive', icon: Icon(Icons.done_all)),
              Tab(text: 'Detail', icon: Icon(Icons.search)),
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
              child: Wallet(),
            ),
            dispatchForm(context),
            requestForm(context),
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
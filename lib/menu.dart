import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'misc.dart';
import 'wallet.dart';
import 'transaction_dispatch.dart';
import 'transaction_request.dart';
import 'detail_menu.dart';

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

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
              Tab(text: 'Wallet', icon: Icon(Icons.account_balance), key: Key("tab_wallet"),),
              Tab(text: 'Send', icon: Icon(Icons.send), key: Key("tab_send"),),
              Tab(text: 'Receive', icon: Icon(Icons.done_all), key: Key("tab_receive"),),
              Tab(text: 'Detail', icon: Icon(Icons.search), key: Key("tab_detail"),),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text('Debt App'),
          automaticallyImplyLeading: false,
        ),
        body: TabBarView(
          children: [
            Wallet(),
            DispatchScreen(),
            RequestScreen(),
            DetailMenu(),
          ],
        ),
      ),
    );
  }
}
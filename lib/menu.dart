import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

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
          // TODO: abstract dialog box further in misc.dart
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (String value) {
                print(value + " button pressed");
                showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("debt_app"),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text(
                                "This project is licensed under the The GNU General Public License (Version 3)."),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Source'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            launch(
                                'https://github.com/ColonisationCaptain/debt_app');
                          },
                        ),
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              itemBuilder: (BuildContext context) {
                return {'About'}.map(
                  (String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  },
                ).toList();
              },
            ),
          ],
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

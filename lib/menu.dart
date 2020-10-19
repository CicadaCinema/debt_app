import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
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
              Tab(text: 'DOGS', icon: Icon(Icons.favorite)),
              Tab(text: 'CATS', icon: Icon(Icons.music_note)),
              Tab(text: 'BIRDS', icon: Icon(Icons.search)),
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
                child: Text('Current route:' + ModalRoute.of(context).settings.name)
            ),
            Center(
              child: RaisedButton(
                onPressed: () {
                },
                child: Text('Go back!'),
              ),
            ),
            Center(
              child: RaisedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                child: Text('Sign out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
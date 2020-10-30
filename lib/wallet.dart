import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// create separate class for storing balance so that _MainMenuState can remain private
class BalanceStore {
  static double balance;
}

class Wallet extends StatefulWidget {
  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  String _usernameReadout = "My balance:";
  String _balanceReadout = "£0.00";

  // keep updating user's username and balance
  void updateBalance() async {
    if (FirebaseAuth.instance.currentUser != null){
      Stream ownDocumentStream = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).snapshots();
      ownDocumentStream.listen((var value) {
        //print("updating");
        Map<String, dynamic> retrievedData = value.data();
        _usernameReadout = '${retrievedData['username']}\'s balance:';
        BalanceStore.balance = value.data()['balance'] * 1.0; // ENSURE this is a double
        _balanceReadout = '£' + value.data()['balance'].toStringAsFixed(2);
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  // launch update function before building
  @override
  void initState() {
    super.initState();
    updateBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacer(flex: 3),
        //Text('Current route:' + ModalRoute.of(context).settings.name),
        Text(
          _usernameReadout,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        Text(
          _balanceReadout,
          style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
        ),
        Spacer(flex: 3),
        FlatButton(
          onPressed: () {
            FirebaseAuth.instance.signOut();
          },
          child: Text('Sign out'),
        ),
        Spacer(),
      ],
    );
  }
}
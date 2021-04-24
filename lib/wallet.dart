import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// separate class for storing balance - any widget can call this and get the balance
class BalanceStore {
  static late double balance;
}

// separate class for storing the current state of the user doc - any widget can call this and get the doc
class UserDocStore {
  static var userDoc;
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
      Stream ownDocumentStream = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).snapshots();
      ownDocumentStream.listen((var value) {
        // update global stores
        BalanceStore.balance = value.data()['balance'] * 1.0; // ENSURE this is a double
        UserDocStore.userDoc = value.data();

        //print("updating");
        Map<String, dynamic> retrievedData = value.data();
        _usernameReadout = '${retrievedData['username']}\'s balance:';
        // ensure negative sign in the correct position
        if (value.data()['balance'] < 0) {
          _balanceReadout = '-£' + (value.data()['balance'] * -1).toStringAsFixed(2);
        } else {
          _balanceReadout = '£' + value.data()['balance'].toStringAsFixed(2);
        }
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
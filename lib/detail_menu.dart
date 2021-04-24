import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailMenu extends StatefulWidget {
  @override
  _DetailMenuState createState() => _DetailMenuState();
}

class _DetailMenuState extends State<DetailMenu> {
  // TODO: is it fine if this is null?????
  Map<String, dynamic>? _map = {};

  // keep updating user's debt table
  void updateTable() async {
    if (FirebaseAuth.instance.currentUser != null) {
      Stream ownDocumentStream = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots();
      ownDocumentStream.listen((var value) {
        //print("updating");
        Map<String, dynamic> retrievedData = value.data();
        _map = retrievedData['debts'];
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
    updateTable();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      // not really sure how this returns a nice table from a map
      // but it does do that quite nicely
      child: DataTable(
        columns: const <DataColumn>[
          DataColumn(label: Text('User')),
          DataColumn(label: Text('Amount')),
        ],
        rows: _map!.entries
            .map((e) => DataRow(cells: [
                  DataCell(Text(e.key.toString())),
                  DataCell(Text(e.value.toStringAsFixed(2))),
                ]))
            .toList(),
      ),
    );
  }
}

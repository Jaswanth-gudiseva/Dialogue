import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:teams_app/services/firestore_db.dart';
import 'package:teams_app/widgets/loading_widget.dart';

class RoomStream extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  late final String username;
  RoomStream({required this.username});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('meetingCodes')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: AnimatedLoader(
              text: 'fetching your chats',
            ),
          );
        }
        final codes = snapshot.data!.docs;
        return FutureBuilder(
          future: FireStoreDB().later(codes, username),
          builder: (context, snapshot1) {
            if (snapshot1.hasData) {
              List<Widget> data1 = snapshot1.data as List<Widget>;

              return ListView.builder(
                itemCount: data1.length,
                itemBuilder: (context, index) => data1[index],
              );
            } else {
              return Center(
                child: AnimatedLoader(text: 'fetching your chats'),
              );
            }
          },
        );
      },
    );
  }
}

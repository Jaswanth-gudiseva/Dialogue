import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teams_app/widgets/home_screen/room_widget.dart';

class FireStoreDB {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> createRoom(
      bool isInstant, String createMeetingCode, String roomName) async {
    if (!isInstant) {
      await _firebaseFirestore
          .collection('meetingRoom')
          .doc(createMeetingCode)
          .set({'roomName': roomName});
      await _firebaseFirestore
          .collection('meetingRoom')
          .doc(createMeetingCode)
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .set({});
      await _firebaseFirestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('meetingCodes')
          .doc(createMeetingCode)
          .set({});
    } else {
      await _firebaseFirestore
          .collection('instantMeeting')
          .doc(createMeetingCode)
          .set({});
    }
  }

  Future later(List codes, String username) async {
    List<Widget> roomWidgets = [];
    for (var code in codes) {
      var documents = await FirebaseFirestore.instance
          .collection('meetingRoom')
          .doc(code.id)
          .get();
      final roomWidget = RoomWidget(
          code: code.id,
          username: username,
          roomName: documents.data()!['roomName']);
      roomWidgets.add(roomWidget);
    }
    return roomWidgets;
  }
}

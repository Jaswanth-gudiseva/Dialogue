import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:teams_app/screens/call_screen.dart';
import 'package:teams_app/utils/constants.dart';

late User? loggedInUser;

class ChatScreen extends StatefulWidget {
  final String username;
  final String chatCode;
  final bool isInstant;
  final bool fromRoom;
  final String roomName;
  ChatScreen(
      {required this.chatCode,
      required this.username,
      required this.isInstant,
      required this.roomName,
      required this.fromRoom});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  late String messageText;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<void> onJoin() async {
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          roomName: widget.roomName,
          meetCode: widget.chatCode,
          username: widget.username,
          isInstant: false,
        ),
      ),
    );
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    // ignore: avoid_print
    print(status);
  }

  void handleClick(String value) {
    switch (value) {
      case 'Copy Room Code':
        Clipboard.setData(
          ClipboardData(
            text: widget.chatCode,
          ),
        );
        break;
      case 'Leave Room':
        _showMyDialog(context, widget.chatCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Visibility(
            visible: (widget.fromRoom == true),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(
                  FontAwesomeIcons.video,
                  size: 20,
                ),
                onPressed: () {
                  onJoin();
                },
              ),
            ),
          ),
          Visibility(
            visible: (widget.fromRoom == true),
            child: PopupMenuButton<String>(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              padding: EdgeInsets.zero,
              color: Color(0xff4d3f5d),
              onSelected: handleClick,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'Copy Room Code',
                  child: ListTile(
                    dense: true,
                    title: Text(
                      'Copy Room Code: ${widget.chatCode}',
                      style: TextStyle(
                        color: Color(0xfff0e3e3),
                        fontFamily: 'Mons',
                      ),
                    ),
                    leading: Icon(
                      Icons.copy,
                      color: Color(0xfff0e3e3),
                    ),
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'Leave Room',
                  child: ListTile(
                    dense: true,
                    title: Text(
                      'Leave Room',
                      style: TextStyle(
                        color: Color(0xfff0e3e3),
                        fontFamily: 'Mons',
                      ),
                    ),
                    leading: Icon(
                      Icons.exit_to_app_rounded,
                      color: Color(0xfff0e3e3),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
        title: Text(
          widget.roomName,
          style: TextStyle(fontFamily: 'Mons'),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(
              isInstant: widget.isInstant,
              user: widget.username,
              chatCodeStream: widget.chatCode,
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageTextController,
                        style: TextStyle(
                          color: Color(0xfff0e3e3),
                          fontFamily: 'Mons',
                        ),
                        onChanged: (value) {
                          messageText = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        messageTextController.clear();
                        FirebaseFirestore.instance
                            .collection(widget.isInstant
                                ? 'instantMeeting'
                                : 'meetingRoom')
                            .doc(widget.chatCode)
                            .collection(widget.chatCode)
                            .add({
                          "message": messageText,
                          'sender': widget.username,
                          'time': DateTime.now()
                        }).then((_) {
                          print("success!");
                        });
                      },
                      child: (Icon(
                        Icons.send,
                        color: Color(0xffdee1e6),
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: use_key_in_widget_constructors
class MessagesStream extends StatelessWidget {
  final chatCodeStream;
  final String user;
  final bool isInstant;
  MessagesStream(
      {required this.chatCodeStream,
      required this.user,
      required this.isInstant});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(isInstant ? 'instantMeeting' : 'meetingRoom')
          .doc(chatCodeStream)
          .collection(chatCodeStream)
          .orderBy('time')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).accentColor,
            ),
          );
        }
        final messages = snapshot.data!.docs.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          Map<String, dynamic> data = message.data() as Map<String, dynamic>;
          final currentUser = user;

          final messageBubble = MessageBubble(
            data: data,
            isMe: currentUser == data['sender'],
          );
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const MessageBubble({required this.data, required this.isMe});
  final Map data;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: (!isMe),
            child: Text(
              data['sender'],
              style: const TextStyle(
                fontFamily: 'Mons',
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          Material(
            color: isMe ? Color(0xfff0e3e3) : Theme.of(context).accentColor,
            elevation: 2,
            borderRadius: BorderRadius.only(
              topLeft:
                  isMe ? const Radius.circular(15) : const Radius.circular(2),
              bottomLeft: const Radius.circular(15),
              bottomRight: const Radius.circular(15),
              topRight:
                  isMe ? const Radius.circular(2) : const Radius.circular(15),
            ),
            child: InkWell(
              onLongPress: () {
                showMenu(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  ),
                  color: Color(0xff4d3f5d),
                  context: context,
                  position: RelativeRect.fromLTRB(75, 75, 0, 100),
                  items: [
                    PopupMenuItem(
                      value: 1,
                      child: ListTile(
                        dense: true,
                        title: Text(
                          'Copy Message',
                          style: TextStyle(
                            color: Color(0xfff0e3e3),
                            fontFamily: 'Mons',
                          ),
                        ),
                        leading: Icon(
                          Icons.copy,
                          color: Color(0xfff0e3e3),
                        ),
                      ),
                    ),
                  ],
                  elevation: 8.0,
                ).then(
                  (value) {
                    Clipboard.setData(
                      ClipboardData(
                        text: data['message'],
                      ),
                    );
                  },
                );
              },
              borderRadius: BorderRadius.only(
                topLeft:
                    isMe ? const Radius.circular(15) : const Radius.circular(2),
                bottomLeft: const Radius.circular(15),
                bottomRight: const Radius.circular(15),
                topRight:
                    isMe ? const Radius.circular(2) : const Radius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 15.0),
                child: Text(
                  '${data['message']}',
                  style: TextStyle(
                      color: isMe
                          ? Colors.black54
                          : Colors.white.withOpacity(0.85),
                      fontFamily: 'Mons',
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showMyDialog(BuildContext context, String code) {
  final _auth = FirebaseAuth.instance;
  final firebaseFirestore = FirebaseFirestore.instance;
  String user = _auth.currentUser!.uid;
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Leave Room'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('Are you sure you want to leave this room?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            child: const Text('Leave'),
            onPressed: () async {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              await firebaseFirestore
                  .collection('meetingRoom')
                  .doc(code)
                  .collection('users')
                  .doc(user)
                  .delete();
              await firebaseFirestore
                  .collection('users')
                  .doc(user)
                  .collection('meetingCodes')
                  .doc(code)
                  .delete();
              var snapshot = await firebaseFirestore
                  .collection('meetingRoom')
                  .doc(code)
                  .collection('users')
                  .limit(1)
                  .get();
              if (snapshot.docs.length == 0) {
                await firebaseFirestore
                    .collection('meetingRoom')
                    .doc(code)
                    .delete();
                firebaseFirestore
                    .collection('meetingRoom')
                    .doc(code)
                    .collection(code)
                    .get()
                    .then(
                  (snapshot) {
                    for (DocumentSnapshot doc in snapshot.docs) {
                      doc.reference.delete();
                    }
                  },
                );
              }
            },
          ),
        ],
      );
    },
  );
}

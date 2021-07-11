import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants.dart';
import 'call_screen.dart';

late User? loggedInUser;

class ChatScreen extends StatefulWidget {
  final String user;
  final String chatCode;
  final bool isInstant;
  ChatScreen(
      {required this.chatCode, required this.user, required this.isInstant});

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
          channelId: widget.chatCode,
          user: widget.user,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: const Icon(Icons.video_call, size: 30),
              onPressed: () {
                onJoin();
              },
            ),
          ),
        ],
        title: const Text('Chat'),
        backgroundColor: Color(0xff121212),
      ),
      body: Container(
        color: Color(0xff121212),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(
              isInstant: widget.isInstant,
              user: widget.user,
              chatCodeStream: widget.chatCode,
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      style: TextStyle(color: Colors.white.withOpacity(0.87)),
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
                        'sender': widget.user,
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
          return const Center(
            child: CircularProgressIndicator(
                // backgroundColor: Colors.lightBlueAccent,
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
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            data['sender'],
            style: const TextStyle(
              // color: Colors.black54,
              fontSize: 12,
            ),
          ),
          Material(
            // color: isMe ? Colors.deepPurpleAccent : Colors.white,
            elevation: 2,
            borderRadius: BorderRadius.only(
              topLeft:
                  isMe ? const Radius.circular(15) : const Radius.circular(2),
              bottomLeft: const Radius.circular(15),
              bottomRight: const Radius.circular(15),
              topRight:
                  isMe ? const Radius.circular(2) : const Radius.circular(15),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              child: Text(
                '${data['message']}',
                // style: TextStyle(color: isMe ? Colors.white : Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

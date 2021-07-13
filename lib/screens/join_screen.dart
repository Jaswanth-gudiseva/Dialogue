import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:teams_app/screens/call_screen.dart';
import 'package:teams_app/screens/chat_screen.dart';
import 'package:teams_app/services/firestore_db.dart';
import 'package:teams_app/widgets/input_page/reusable_card.dart';
import 'package:teams_app/widgets/loading_widget.dart';

String joinCode = '';
bool returnValue = false;
bool isLoading = false;

class JoinMeeting extends StatefulWidget {
  final String username;
  final bool isInstant;
  JoinMeeting({required this.username, required this.isInstant});
  @override
  _JoinMeetingState createState() => _JoinMeetingState();
}

class _JoinMeetingState extends State<JoinMeeting> {
  final _auth = FirebaseAuth.instance;

  //Validates the code entered by user and allows them into the room
  void _trySubmit() async {
    if (joinCode.length == 7) {
      setState(() {
        isLoading = true;
      });
      await joinRoom();
      setState(() {
        isLoading = false;
      });
      print(widget.username);
      if (!widget.isInstant && returnValue) {
        Navigator.pop(context);
        var pushRoomName = await FireStoreDB().getRoomName(joinCode);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              fromRoom: widget.isInstant ? false : true,
              roomName: pushRoomName,
              isInstant: false,
              username: widget.username,
              chatCode: joinCode,
            ),
          ),
        );
      } else if (widget.isInstant && returnValue) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(
              roomName: '',
              isInstant: true,
              username: widget.username,
              meetCode: joinCode,
            ),
          ),
        );
      } else if (!returnValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Enter a Valid code'),
            backgroundColor: Color(0xffd54c4c),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enter a Valid code'),
          backgroundColor: Color(0xffd54c4c),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: (isLoading)
            ? Center(
                child: AnimatedLoader(
                text: 'joining room',
              ))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ReusableCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 60),
                      cardChild: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text('Enter Code:',
                                  style: TextStyle(
                                    fontFamily: 'Mons',
                                    color: Color(0xfff0e3e3),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 30,
                                  )),
                            ),
                          ),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: PinCodeTextField(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                textStyle: TextStyle(
                                  fontFamily: 'Mons',
                                  fontSize: 40,
                                  color: Theme.of(context).accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                length: 7,
                                animationDuration:
                                    const Duration(milliseconds: 0),
                                onChanged: (value) => joinCode = value,
                                appContext: context,
                                pastedTextStyle: TextStyle(
                                  fontFamily: 'Mons',
                                  color: Color(0xff2f576e),
                                  fontWeight: FontWeight.w500,
                                ),
                                animationType: AnimationType.none,
                                pinTheme: PinTheme(
                                  activeFillColor: Colors.indigo,
                                  shape: PinCodeFieldShape.underline,
                                  activeColor: Theme.of(context).accentColor,
                                  inactiveColor: Color(0xffa2b1bd),
                                  selectedColor: Color(0xfff0e3e3),
                                ),
                                cursorColor: Color(0xfff0e3e3),
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                color: Theme.of(context).accentColor,
                                highlightColor: Color(0xff485966),
                                highlightElevation: 0,
                                splashColor: Color(0xff596d7c),
                                height: 50,
                                minWidth: 200,
                                elevation: 0,
                                textColor: Color(0xfff0e3e3),
                                child: Text(
                                  widget.isInstant
                                      ? 'Join Meeting'
                                      : 'Join Room',
                                  style: TextStyle(
                                    fontFamily: 'Mons',
                                    color: Color(0xfff0e3e3),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 25,
                                  ),
                                ),
                                onPressed: _trySubmit,
                              ),
                            ),
                          )
                        ],
                      ),
                      onPress: () {},
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> joinRoom() async {
    if (!widget.isInstant) {
      await FirebaseFirestore.instance
          .collection('meetingRoom')
          .doc(joinCode)
          .get()
          .then(
        (DocumentSnapshot documentSnapshot) async {
          if (documentSnapshot.exists) {
            setState(() {
              returnValue = true;
            });
            await FirebaseFirestore.instance
                .collection('meetingRoom')
                .doc(joinCode)
                .collection('users')
                .doc(_auth.currentUser!.uid)
                .set({});
            await FirebaseFirestore.instance
                .collection('users')
                .doc(_auth.currentUser!.uid)
                .collection('meetingCodes')
                .doc(joinCode)
                .set({});
          } else {
            setState(() {
              returnValue = false;
            });
          }
        },
      );
    } else {
      await FirebaseFirestore.instance
          .collection('instantMeeting')
          .doc(joinCode)
          .get()
          .then(
        (DocumentSnapshot documentSnapshot) async {
          if (documentSnapshot.exists) {
            setState(
              () {
                returnValue = true;
              },
            );
          }
        },
      );
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:teams_app/screens/call_screen.dart';

import 'chat_screen.dart';
import 'input_page.dart';

String joinCode = '';
String username = '';
bool returnValue = false;
bool isLoading = false;

class JoinMeeting extends StatefulWidget {
  final String user;
  final bool isInstant;
  JoinMeeting({required this.user, required this.isInstant});
  @override
  _JoinMeetingState createState() => _JoinMeetingState();
}

class _JoinMeetingState extends State<JoinMeeting> {
  final _auth = FirebaseAuth.instance;

  void _trySubmit() async {
    if (joinCode.length == 7) {
      setState(() {
        isLoading = true;
      });
      await joinRoom();
      setState(() {
        isLoading = false;
      });
      print(username);
      // Navigator.pop(context);
      if (!widget.isInstant && returnValue) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              isInstant: false,
              user: username,
              chatCode: joinCode,
            ),
          ),
        );
      } else if (!widget.isInstant && !returnValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Enter a Valid room code'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(
              isInstant: widget.isInstant,
              user: username,
              channelId: joinCode,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enter a Valid room code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.indigo[300],
        body: (isLoading)
            ? Center(child: CircularProgressIndicator(color: Colors.white))
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
                              child: Text(
                                'Enter Code:',
                                style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 30,
                                )),
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: PinCodeTextField(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                textStyle: GoogleFonts.poppins(
                                  fontSize: 40,
                                  color: Colors.indigo[400],
                                ),
                                length: 7,
                                animationDuration:
                                    const Duration(milliseconds: 0),
                                onChanged: (value) => joinCode = value,
                                appContext: context,
                                pastedTextStyle: TextStyle(
                                  color: Colors.indigo[400],
                                  fontWeight: FontWeight.bold,
                                ),
                                animationType: AnimationType.none,
                                pinTheme: PinTheme(
                                  activeFillColor: Colors.indigo,
                                  shape: PinCodeFieldShape.underline,
                                  activeColor: Colors.indigo[400],
                                  inactiveColor: Colors.indigo[200],
                                  selectedColor: Colors.indigo[100],
                                ),
                                cursorColor: Colors.indigo[100],
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                color: Colors.indigo[400],
                                highlightColor: Colors.indigo[300],
                                highlightElevation: 0,
                                splashColor: Colors.indigo[300],
                                height: 50,
                                minWidth: 200,
                                elevation: 0,
                                textColor: Colors.white60,
                                child: Text(
                                  'Join Meeting',
                                  style: GoogleFonts.raleway(
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 25,
                                    ),
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
  }
}


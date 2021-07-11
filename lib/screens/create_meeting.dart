import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:teams_app/screens/call_screen.dart';
import 'package:teams_app/screens/chat_screen.dart';
import 'package:teams_app/services/firestore_db.dart';
import 'package:teams_app/services/functions.dart';

import 'input_page.dart';

class CreateMeeting extends StatefulWidget {
  final String user;
  final bool isInstant;
  String roomName = '';
  String userName = '';
  String _createMeetingCode = getRandomString(7);
  CreateMeeting({required this.user, required this.isInstant});
  @override
  _CreateMeetingState createState() => _CreateMeetingState();
}

class _CreateMeetingState extends State<CreateMeeting> {
  final _formKey = GlobalKey<FormState>();
  final _fireStoreDB = FireStoreDB();

  var errorVariable = '';

  @override
  void initState() {
    super.initState();
    widget.userName = widget.user;
  }

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (!widget.isInstant && isValid) {
      if (isValid) {
        _formKey.currentState!.save();
      }
      _fireStoreDB.createRoom(
          widget.isInstant, widget._createMeetingCode, widget.roomName);
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            isInstant: false,
            user: widget.userName,
            chatCode: widget._createMeetingCode,
          ),
        ),
      );
    } else if (widget.isInstant) {
      Navigator.pop(context);
      _fireStoreDB.createRoom(
          widget.isInstant, widget._createMeetingCode, widget.roomName);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
            isInstant: widget.isInstant,
            user: widget.userName,
            channelId: widget._createMeetingCode,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xff121212),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ReusableCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                cardChild: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Room Code',
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          onPressed: () {
                            setState(() {
                              widget._createMeetingCode = getRandomString(7);
                            });
                            print(widget._createMeetingCode);
                          },
                        ),
                      ],
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget._createMeetingCode,
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                letterSpacing: 5,
                                fontWeight: FontWeight.w500,
                                fontSize: 60,
                                color: Colors.indigo[400],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                  text: widget._createMeetingCode));
                            },
                            child: Icon(
                              FontAwesomeIcons.copy,
                              color: Colors.indigo[400],
                              size: 35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextFormField(
                          key: ValueKey('Room Name'),
                          autocorrect: true,
                          textCapitalization: TextCapitalization.words,
                          enableSuggestions: false,
                          validator: !widget.isInstant
                              ? (value) {
                                  if (value!.trim().isEmpty) {
                                    return 'Please don\'t leave it empty';
                                  }
                                  return null;
                                }
                              : null,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.indigo[100],
                            contentPadding: EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.indigo.shade300, width: 1.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.indigo.shade300, width: 2.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            ),
                            hintText: widget.isInstant
                                ? 'Enter your Name'
                                : 'Enter Room Name',
                          ),
                          onSaved: (value) {
                            if (!widget.isInstant) {
                              widget.roomName = value!.trim();
                            } else {
                              if (value != null) {
                                widget.userName = value.trim();
                              } else
                                return;
                            }
                          },
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: Color(0xff121212),
                          highlightColor: Colors.indigo[300],
                          highlightElevation: 0,
                          splashColor: Colors.indigo[300],
                          height: 50,
                          minWidth: 200,
                          elevation: 0,
                          textColor: Colors.white60,
                          child: Text(
                            widget.isInstant ? 'Start Meeting' : 'Create Room',
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
}

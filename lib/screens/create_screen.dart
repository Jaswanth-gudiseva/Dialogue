import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:teams_app/screens/call_screen.dart';
import 'package:teams_app/screens/chat_screen.dart';
import 'package:teams_app/services/firestore_db.dart';
import 'package:teams_app/services/functions.dart';
import 'package:teams_app/utils/constants.dart';
import 'package:teams_app/widgets/input_page/reusable_card.dart';

class CreateMeeting extends StatefulWidget {
  final String username;
  final bool isInstant;
  String roomName = '';
  String createCode = getRandomString(7);
  CreateMeeting({required this.username, required this.isInstant});
  @override
  _CreateMeetingState createState() => _CreateMeetingState();
}

class _CreateMeetingState extends State<CreateMeeting> {
  final _formKey = GlobalKey<FormState>();
  final _fireStoreDB = FireStoreDB();

  var errorVariable = '';

  ///Creates a Room or Instant meeting and stores the data related to it in
  ///Firestore
  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    //checks if it's an Instant meeting and Validates the roomname
    if (!widget.isInstant && isValid) {
      if (isValid) {
        _formKey.currentState!.save();
      }
      _fireStoreDB.createRoom(
          widget.isInstant, widget.createCode, widget.roomName);
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            fromRoom: widget.isInstant ? false : true,
            roomName: widget.roomName,
            isInstant: false,
            username: widget.username,
            chatCode: widget.createCode,
          ),
        ),
      );
    } else if (widget.isInstant) {
      Navigator.pop(context);
      _fireStoreDB.createRoom(
          widget.isInstant, widget.createCode, widget.roomName);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
            roomName: widget.roomName,
            isInstant: widget.isInstant,
            username: widget.username,
            meetCode: widget.createCode,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
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
                          style: TextStyle(
                            fontFamily: 'Mons',
                            color: Color(0xfff0e3e3),
                            fontWeight: FontWeight.w500,
                            fontSize: 30,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: Color(0xfff0e3e3),
                          ),
                          onPressed: () {
                            setState(() {
                              widget.createCode = getRandomString(7);
                            });
                            print(widget.createCode);
                          },
                        ),
                      ],
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.createCode,
                            style: TextStyle(
                              fontFamily: 'Mons',
                              letterSpacing: 5,
                              fontWeight: FontWeight.w500,
                              fontSize: 60,
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: widget.createCode),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Copied Code: ${widget.createCode}',
                                    style: TextStyle(fontFamily: 'Mons'),
                                  ),
                                  backgroundColor: Color(0xff485966),
                                ),
                              );
                            },
                            icon: Icon(
                              FontAwesomeIcons.copy,
                              color: Theme.of(context).accentColor,
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
                        child: (!widget.isInstant)
                            ? TextFormField(
                                style: TextStyle(
                                    color: Color(0xfff0e3e3),
                                    fontFamily: 'Mons'),
                                key: ValueKey('Room Name'),
                                autocorrect: true,
                                textCapitalization: TextCapitalization.words,
                                enableSuggestions: false,
                                validator: (value) {
                                  if (value!.trim().isEmpty) {
                                    return 'Please don\'t leave it empty';
                                  }
                                  return null;
                                },
                                decoration: kInputTextFieldDecoration.copyWith(
                                    hintText: 'Enter Room Name'),
                                onChanged: (value) {
                                  widget.roomName = value.trim();
                                },
                              )
                            : null,
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
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
                            widget.isInstant ? 'Start Meeting' : 'Create Room',
                            style: TextStyle(
                              fontFamily: 'Mons',
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
}

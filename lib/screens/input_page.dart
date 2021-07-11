import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

import 'create_meeting.dart';
import 'join_meeting.dart';

String _username = '';

class InputPage extends StatefulWidget {
  final String user;
  InputPage({required this.user});
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.indigo[300], //abc4ff
        appBar: AppBar(
          backgroundColor: Colors.indigo[300],
          title: const Center(
            child: Text('TeamsClone'),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            Expanded(
              child: ReusableCard(
                padding: const EdgeInsets.all(40),
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateMeeting(
                        isInstant: true,
                        user: widget.user,
                      ),
                    ),
                  );
                },
                cardChild: const IconPlace(
                  choice: 'Create Meeting',
                  icon: FontAwesomeIcons.plus,
                ),
              ),
            ),
            Divider(
              color: Colors.indigo[400],
              thickness: 0.8,
            ),
            Expanded(
              child: ReusableCard(
                padding: const EdgeInsets.all(40),
                onPress: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => JoinMeeting(
                                isInstant: true,
                                user: _username,
                              )));
                },
                cardChild: const IconPlace(
                  choice: 'Join Meeting',
                  icon: FontAwesomeIcons.signInAlt,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// // ignore: use_key_in_widget_constructors
class ReusableCard extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const ReusableCard(
      {required this.cardChild, required this.onPress, required this.padding});
  final Widget? cardChild;
  final VoidCallback onPress;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Padding(
        padding: padding,
        child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              blurRadius: 8,
              spreadRadius: 4,
              color: Colors.black.withOpacity(0.01),
            )
          ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 40.0,
                sigmaY: 40.0,
              ),
              child: Container(
                child: cardChild,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    width: 0.1,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class IconPlace extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const IconPlace({required this.choice, required this.icon});
  final String choice;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          icon,
          size: 120,
          color: Colors.indigo[400]!.withOpacity(0.75),
        ),
        const SizedBox(
          height: 40,
        ),
        Text(
          choice,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

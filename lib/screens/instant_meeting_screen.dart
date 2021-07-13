import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:teams_app/screens/create_screen.dart';
import 'package:teams_app/screens/join_screen.dart';
import 'package:teams_app/widgets/input_page/icon_place.dart';
import 'package:teams_app/widgets/input_page/reusable_card.dart';

class InputPage extends StatefulWidget {
  final String username;
  InputPage({required this.username});
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor, //abc4ff
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
                      username: widget.username,
                    ),
                  ),
                );
              },
              cardChild: const IconPlace(
                choice: 'Create Meeting',
                icon: FontAwesomeIcons.plusCircle,
              ),
            ),
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
                      username: widget.username,
                    ),
                  ),
                );
              },
              cardChild: const IconPlace(
                choice: 'Join Meeting',
                icon: FontAwesomeIcons.video,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

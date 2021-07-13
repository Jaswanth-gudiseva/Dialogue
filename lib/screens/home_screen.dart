import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:teams_app/screens/create_screen.dart';
import 'package:teams_app/screens/instant_meeting_screen.dart';
import 'package:teams_app/screens/join_screen.dart';
import 'package:teams_app/utils/ui_scaling.dart';
import 'package:teams_app/widgets/home_screen/drawer_tile.dart';
import 'package:teams_app/widgets/home_screen/room_stream.dart';

class HomeScreen extends StatefulWidget {
  /// Stores the username of the user logged in
  String username = '';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Stores the page index of current screen selected from bottom navigation
  /// bar
  int selectedPage = 0;
  @override
  void initState() {
    super.initState();
    _getUserName();
  }

  /// Fetches the username of the current user from Firestore
  Future<void> _getUserName() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen(
      (value) {
        if (mounted) {
          setState(() {
            widget.username = value.get('username').toString();
          });
        }
      },
    );
  }

  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final _pageOptions = [
      RoomStream(
        username: widget.username,
      ),
      InputPage(
        username: widget.username,
      ),
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            selectedPage = index;
          });
        },
        currentIndex: selectedPage,
        backgroundColor: Color(0xff4d3f5d),
        selectedItemColor: Color(0xffF0E3E3),
        unselectedItemColor: Color(0xffF0E3E3),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            title: Text(
              'Rooms',
              style: TextStyle(fontFamily: 'Mons', fontSize: 12),
            ),
            icon: Icon(Icons.group_rounded),
          ),
          BottomNavigationBarItem(
            title: Text(
              'Instant Meet',
              style: TextStyle(fontFamily: 'Mons', fontSize: 12),
            ),
            icon: Icon(Icons.video_call_rounded),
          ),
        ],
      ),
      floatingActionButton: selectedPage == 0
          ? FloatingActionButton.extended(
              icon: Icon(FontAwesomeIcons.solidArrowAltCircleRight),
              label: Text(
                "Join Room",
                style: TextStyle(fontFamily: 'Mons'),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JoinMeeting(
                      isInstant: false,
                      username: widget.username,
                    ),
                  ),
                );
              },
            )
          : null,
      drawer: Drawer(
        child: Container(
          color: Theme.of(context).primaryColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(7),
                      bottomRight: Radius.circular(7)),
                  color: Theme.of(context).accentColor,
                ),
                height: SizeConfig.safeBlockVertical! * 15,
                child: DrawerHeader(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.username,
                        style: TextStyle(
                          fontFamily: 'Mons',
                          fontSize: SizeConfig.safeBlockVertical! * 2.6,
                          color: Color(0xff234153),
                        ),
                      ),
                      Text(
                        _auth.currentUser!.email.toString(),
                        style: TextStyle(
                          fontFamily: 'Mons',
                          fontSize: SizeConfig.safeBlockVertical! * 1.8,
                          color: Color(0xff234153),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: DrawerListTile(
                  icon: FontAwesomeIcons.signOutAlt,
                  title: 'Logout',
                  widget: widget,
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                  },
                ),
              ),
              Divider(
                thickness: 1,
                color: Color(0xff70657d),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 10, left: 15),
                height: 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "V1.0.0",
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Mons',
                        color: Color(0xfff0e3e3),
                      ),
                    ),
                    Text(
                      "Made with 💜 under Microsoft Engage'21",
                      style: TextStyle(
                        fontFamily: 'Mons',
                        color: Color(0xff70657d),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          'DIALOGUE',
          style: TextStyle(
            fontFamily: 'Mons',
            fontWeight: FontWeight.w400,
            fontSize: 0.03 * SizeConfig.bodyScreenHeight!,
            color: Color(0xffdee1e6),
          ),
        ),
        elevation: 0,
        actions: [
          Visibility(
            visible: selectedPage == 0,
            child: FloatingActionButton.extended(
              heroTag: 'FBA',
              highlightElevation: 0,
              elevation: 0,
              splashColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              icon: Icon(
                FontAwesomeIcons.plusCircle,
                color: Color(0xfff0e3e3),
              ),
              label: Text(
                "Create Room",
                style: TextStyle(
                    fontFamily: 'Mons', color: Color(0xfff0e3e3), fontSize: 12),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateMeeting(
                      isInstant: false,
                      username: widget.username,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        color: Theme.of(context).primaryColor,
        child: _pageOptions[selectedPage],
      ),
    );
  }
}

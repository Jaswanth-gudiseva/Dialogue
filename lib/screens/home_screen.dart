import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teams_app/screens/create_meeting.dart';
import 'package:teams_app/screens/input_page.dart';
import 'package:teams_app/utils/ui_scaling.dart';
import 'package:teams_app/widgets/home_screen/drawer_tile.dart';
import 'package:teams_app/widgets/home_screen/room_stream.dart';
import 'join_meeting.dart';

class HomeScreen extends StatefulWidget {
  String _userName = '';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedPage = 0;

  // final _pageOptions = [
  //   HomeScreen(),
  //   InputPage(user: widget._userName,),

  // ];
  @override
  void initState() {
    super.initState();
    _getUserName();
  }

  Future<void> _getUserName() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen(
      (value) {
        if (mounted) {
          setState(() {
            widget._userName = value.get('username').toString();
          });
        }
      },
    );
  }

  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    final _pageOptions = [
      RoomStream(
        username: widget._userName,
      ),
      InputPage(
        user: widget._userName,
      ),
    ];
    SizeConfig().init(context);
    return Scaffold(
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
            label: "Rooms",
            icon: Icon(
              Icons.chat_rounded,
            ),
          ),
          BottomNavigationBarItem(
            label: "Video Call",
            icon: Icon(Icons.video_call_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(FontAwesomeIcons.userPlus),
        label: Text("Join Room"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JoinMeeting(
                isInstant: false,
                user: widget._userName,
              ),
            ),
          );
        },
      ),
      drawer: Drawer(
        child: Container(
          color: Color(0xff433751),
          child: ListView(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(7),
                      bottomRight: Radius.circular(7)),
                  color: Colors.indigo[500],
                ),
                height: SizeConfig.safeBlockVertical! * 15,
                child: DrawerHeader(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget._userName,
                        style: TextStyle(
                          fontSize: SizeConfig.safeBlockVertical! * 2.6,
                          color: Colors.white.withOpacity(0.87),
                        ),
                      ),
                      Text(
                        _auth.currentUser!.email.toString(),
                        style: TextStyle(
                          fontSize: SizeConfig.safeBlockVertical! * 1.8,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              DrawerListTile(
                icon: FontAwesomeIcons.users,
                title: 'Create Room',
                widget: widget,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateMeeting(
                        isInstant: false,
                        user: widget._userName,
                      ),
                    ),
                  );
                },
              ),
              DrawerListTile(
                icon: FontAwesomeIcons.userPlus,
                title: 'Join Room',
                widget: widget,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JoinMeeting(
                        isInstant: false,
                        user: widget._userName,
                      ),
                    ),
                  );
                },
              ),
              DrawerListTile(
                icon: FontAwesomeIcons.video,
                widget: widget,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InputPage(
                        user: widget._userName,
                      ),
                    ),
                  );
                },
                title: 'Instant Meeting',
              ),
              DrawerListTile(
                icon: FontAwesomeIcons.signOutAlt,
                title: 'Logout',
                widget: widget,
                onTap: () {
                  FirebaseAuth.instance.signOut();
                },
              )
            ],
          ),
        ),
      ),
      appBar: AppBar(
        actions: [],
        leading: Image.asset('images/dialogoapp.png'),
        title: Text(
          'DIALOGUE',
          style: TextStyle(
            color: Color(0xffdee1e6),
          ),
        ),
        backgroundColor: Color(0xff433751),
        elevation: 0,
      ),
      body: Container(
        color: Color(0xff433751),
        // child: RoomStream(
        //   username: widget._userName,
        // ),
        child: _pageOptions[selectedPage],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teams_app/screens/chat_screen.dart';
import 'package:teams_app/utils/ui_scaling.dart';

class RoomWidget extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const RoomWidget(
      {
      // required this.data,
      required this.code,
      required this.username,
      required this.roomName});
  // final Map data;
  final String code;
  final String username;
  final String roomName;

  @override
  _RoomWidgetState createState() => _RoomWidgetState();
}

class _RoomWidgetState extends State<RoomWidget> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  isInstant: false,
                  user: widget.username,
                  chatCode: widget.code,
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.safeBlockVertical! * 0.8),
            child: Material(
              borderRadius:
                  BorderRadius.circular(SizeConfig.safeBlockVertical! * 1),
              color: Color(0xff4d3f5d),
              child: Row(
                children: [
                  SizedBox(
                    width: SizeConfig.safeBlockHorizontal! * 5,
                  ),
                  Icon(
                    Icons.chat_rounded,
                    size: SizeConfig.safeBlockVertical! * 3,
                    color: Color(0xffdee1e6),
                  ),
                  SizedBox(
                    width: SizeConfig.safeBlockHorizontal! * 5,
                  ),
                  Padding(
                    padding: EdgeInsets.all(SizeConfig.safeBlockVertical! * 1),
                    child: Column(
                      children: [
                        Text(
                          widget.roomName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xffdee1e6),
                            fontSize: SizeConfig.safeBlockVertical! * 2,
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.safeBlockVertical! * 2,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

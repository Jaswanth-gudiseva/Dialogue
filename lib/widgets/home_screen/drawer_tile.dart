import 'package:flutter/material.dart';

import 'package:teams_app/screens/home_screen.dart';
import 'package:teams_app/utils/ui_scaling.dart';

class DrawerListTile extends StatelessWidget {
  DrawerListTile({
    Key? key,
    required this.widget,
    required this.title,
    required this.onTap,
    required this.icon,
  }) : super(key: key);

  final HomeScreen widget;
  final String title;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return ListTile(
      dense: true,
      leading: Icon(
        icon,
        size: SizeConfig.safeBlockVertical! * 2,
        color: Color(0xfff0e3e3),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Mons',
          fontSize: SizeConfig.safeBlockVertical! * 2.2,
          color: Color(0xfff0e3e3),
        ),
      ),
      onTap: onTap,
    );
  }
}

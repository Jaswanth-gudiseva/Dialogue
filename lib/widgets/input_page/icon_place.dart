import 'package:flutter/material.dart';

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
          color: Theme.of(context).accentColor,
        ),
        const SizedBox(
          height: 40,
        ),
        Text(
          choice,
          style: TextStyle(
            fontFamily: 'Mons',
            color: Color(0xfff0e3e3),
            fontSize: 30,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

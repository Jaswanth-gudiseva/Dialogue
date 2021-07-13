import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const RoundedButton(
      {required this.colour,
      required this.buttonText,
      required this.onPressed});
  final Color colour;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colour,
      borderRadius: BorderRadius.circular(30.0),
      elevation: 5.0,
      child: MaterialButton(
        onPressed: onPressed,
        minWidth: 400.0,
        height: 42.0,
        child: Text(
          buttonText,
          style: TextStyle(
              fontFamily: 'Mons',
              fontSize: 16,
              color: Color(0xff234153),
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

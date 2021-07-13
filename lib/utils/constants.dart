import 'package:flutter/material.dart';

const kSendButtonTextStyle = TextStyle(
  color: Color(0xfff0e3e3),
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  hintStyle: TextStyle(color: Color(0xffdee1e6)),
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  borderRadius: BorderRadius.all(Radius.circular(40)),
  color: Color(0xff4d3f5d),
);

final kInputTextFieldDecoration = InputDecoration(
  hintText: '',
  hintStyle: TextStyle(
    color: Color(0xfff0e3e3).withOpacity(0.5),
    fontFamily: 'Mons',
  ),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent),
    borderRadius: BorderRadius.all(
      Radius.circular(32.0),
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xfff0e3e3), width: 1.0),
    borderRadius: BorderRadius.all(
      Radius.circular(32.0),
    ),
  ),
  filled: true,
  fillColor: Color(0xff604f74),
);

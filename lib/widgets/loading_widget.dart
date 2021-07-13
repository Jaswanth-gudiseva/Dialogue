import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class AnimatedLoader extends StatefulWidget {
  final String text;
  AnimatedLoader({required this.text});
  @override
  _AnimatedLoaderState createState() => _AnimatedLoaderState();
}

class _AnimatedLoaderState extends State<AnimatedLoader> {
  @override
  Widget build(BuildContext context) {
    return TypewriterAnimatedTextKit(
      onTap: () {},
      text: [widget.text],
      textStyle:
          TextStyle(fontFamily: 'Mons', color: Theme.of(context).accentColor),
    );
  }
}

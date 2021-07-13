import 'package:flutter/material.dart';

class ReusableCard extends StatelessWidget {
  const ReusableCard(
      {required this.cardChild, required this.onPress, required this.padding});
  final Widget? cardChild;
  final VoidCallback onPress;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Material(
        color: Color(0xff4d3f5d),
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onPress,
          child: cardChild,
        ),
      ),
    );
  }
}

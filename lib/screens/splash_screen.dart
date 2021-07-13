import 'package:flutter/material.dart';

import 'package:teams_app/widgets/loading_widget.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: AnimatedLoader(text: 'loading'),
      ),
    );
  }
}

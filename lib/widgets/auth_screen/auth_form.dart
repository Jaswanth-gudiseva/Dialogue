import 'package:flutter/material.dart';

import 'package:teams_app/utils/constants.dart';
import 'package:teams_app/widgets/auth_screen/rounded_button.dart';
import 'package:teams_app/widgets/loading_widget.dart';

class AuthForm extends StatefulWidget {
  AuthForm(
    this.submitFn,
    this.isLoading,
  );

  final bool isLoading;
  final void Function(
    String email,
    String password,
    String username,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _userEmail = '';
  var _username = '';
  var _userPassword = '';

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      widget.submitFn(_userEmail.trim(), _userPassword.trim(), _username.trim(),
          _isLogin, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 200.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset('images/dialogo.png'),
              ),
            ),
            const SizedBox(
              height: 48.0,
            ),
            TextFormField(
              style: TextStyle(
                color: Color(0xfff0e3e3),
                fontFamily: 'Mons',
              ),
              validator: (value) {
                if (value!.isEmpty || !value.contains('@')) {
                  return 'please enter a valid Email address';
                } else {
                  return null;
                }
              },
              keyboardType: TextInputType.emailAddress,
              onSaved: (value) {
                _userEmail = value!;
              },
              decoration: kInputTextFieldDecoration.copyWith(
                  hintText: 'Enter your Email'),
            ),
            const SizedBox(
              height: 8.0,
            ),
            if (!_isLogin)
              TextFormField(
                style: TextStyle(
                  color: Color(0xfff0e3e3),
                  fontFamily: 'Mons',
                ),
                key: ValueKey('username'),
                validator: (value) {
                  if (value!.isEmpty || value.length < 4) {
                    return 'Please enter at least 4 characters';
                  }
                  return null;
                },
                decoration:
                    kInputTextFieldDecoration.copyWith(hintText: 'Username'),
                onSaved: (value) {
                  _username = value!;
                },
              ),
            if (!_isLogin)
              SizedBox(
                height: 8.0,
              ),
            TextFormField(
              style: TextStyle(
                color: Color(0xfff0e3e3),
                fontFamily: 'Mons',
              ),
              validator: (value) {
                if (value!.isEmpty || value.length < 7) {
                  return 'Password must be at least 7 characters long';
                } else {
                  return null;
                }
              },
              obscureText: true,
              onSaved: (value) {
                _userPassword = value!;
              },
              decoration: kInputTextFieldDecoration.copyWith(
                  hintText:
                      _isLogin ? 'Enter your Password' : 'Enter Password'),
            ),
            const SizedBox(
              height: 24.0,
            ),
            if (widget.isLoading)
              AnimatedLoader(
                text: 'logging you in',
              ),
            if (!widget.isLoading)
              RoundedButton(
                buttonText: _isLogin ? 'Login' : 'Signup',
                colour: Theme.of(context).accentColor,
                onPressed: _trySubmit,
              ),
            if (!widget.isLoading)
              TextButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                ),
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin ? 'Create new account' : 'I already have an account',
                  style:
                      TextStyle(color: Color(0xfff0e3e3), fontFamily: 'Mons'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

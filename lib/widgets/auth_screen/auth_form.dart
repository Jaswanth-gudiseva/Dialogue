import 'package:teams_app/constants.dart';
import 'package:teams_app/widgets/auth_screen/rounded_button.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  AuthForm(
    this.submitFn,
    this.isLoading,
  );

  final bool isLoading;
  final void Function(
    String email,
    String password,
    String userName,
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
  var _userName = '';
  var _userPassword = '';

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      widget.submitFn(_userEmail.trim(), _userPassword.trim(), _userName.trim(),
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
            // ignore: sized_box_for_whitespace
            Hero(
              tag: 'logo',
              child: SizedBox(
                height: 200.0,
                child: Image.asset('images/logo.png'),
              ),
            ),
            const SizedBox(
              height: 48.0,
            ),
            TextFormField(
              validator: (value) {
                if (value!.isEmpty || !value.contains('@')) {
                  return 'please enter a valid Email address';
                } else {
                  return null;
                }
              },
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.black87),
              onSaved: (value) {
                _userEmail = value!;
              },
              decoration: kLoginTextFieldDecoration.copyWith(
                  hintText: 'Enter your Email'),
            ),
            const SizedBox(
              height: 8.0,
            ),
            if (!_isLogin)
              TextFormField(
                key: ValueKey('username'),
                validator: (value) {
                  if (value!.isEmpty || value.length < 4) {
                    return 'Please enter at least 4 characters';
                  }
                  return null;
                },
                decoration:
                    kLoginTextFieldDecoration.copyWith(hintText: 'Username'),
                onSaved: (value) {
                  _userName = value!;
                },
              ),
            if (!_isLogin)
              SizedBox(
                height: 8.0,
              ),
            TextFormField(
              validator: (value) {
                if (value!.isEmpty || value.length < 7) {
                  return 'Password must be at least 7 characters long';
                } else {
                  return null;
                }
              },
              obscureText: true,
              style: const TextStyle(color: Colors.black87),
              onSaved: (value) {
                _userPassword = value!;
              },
              decoration: kLoginTextFieldDecoration.copyWith(
                  hintText: 'Enter your Password'),
            ),
            const SizedBox(
              height: 24.0,
            ),
            if (widget.isLoading) CircularProgressIndicator(),
            if (!widget.isLoading)
              RoundedButton(
                buttonText: _isLogin ? 'Login' : 'Signup',
                colour: Colors.lightBlueAccent,
                onPressed: _trySubmit,
              ),
            if (!widget.isLoading)
              TextButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.white.withOpacity(0)),
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(_isLogin
                    ? 'Create new account'
                    : 'I already have an account'),
              ),
          ],
        ),
      ),
    );
  }
}

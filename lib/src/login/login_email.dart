import 'package:flutter/material.dart';
import 'package:dvx_flutter/dvx_flutter_web.dart';
import 'package:dvx_flutter_firebase/src/firebase/auth.dart';

class LoginData {
  String email = '';
  String password = '';

  @override
  String toString() {
    return '$email $password';
  }
}

class LoginDialog extends StatefulWidget {
  @override
  _LoginDialogState createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final LoginData _data = LoginData();
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;
  String? _initialValue;
  String? _initialPassword;
  int sentResetEmail = 0;

  @override
  void initState() {
    super.initState();

    _initialValue = Utils.debugBuild ? 'test@user.org' : Preferences.loginEmail;

    _initialPassword = Utils.debugBuild ? 'password' : '';
  }

  void _doSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Navigator.of(context).pop(_data);
    } else {
      setState(() {
        _autovalidate = true;
      });
    }
  }

  String _resetEmailText() {
    switch (sentResetEmail) {
      case 0:
        break;
      case 1:
        return 'Email sent to: ${_data.email}';
      case 2:
        return 'Email is invalid';
    }

    return 'Forgot Password?';
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(
        'Login with Email',
        style: Theme.of(context).textTheme.headline5,
      ),
      contentPadding:
          const EdgeInsets.only(top: 12, bottom: 16, left: 16, right: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      children: [
        Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                autocorrect: false,
                autovalidateMode: _autovalidate
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                onChanged: (s) {
                  setState(() {
                    sentResetEmail = 0;
                  });
                },
                initialValue: _initialValue,
                keyboardType: TextInputType
                    .emailAddress, // Use email input type for emails.
                textInputAction: TextInputAction.next,

                decoration: const InputDecoration(
                  icon: Icon(Icons.email),
                  hintText: 'Email Address',
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (StrUtils.isEmailValid(value)) {
                    return null;
                  }

                  return 'Please enter your email address';
                },
                onSaved: (String? value) {
                  _data.email = value!.trim();
                },
              ),
              TextFormField(
                // The validator receives the text that the user has entered.
                autocorrect: false,
                textInputAction: TextInputAction.done,
                autovalidateMode: _autovalidate
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                enableSuggestions: false,
                obscureText: _obscureText,
                initialValue: _initialPassword,
                onFieldSubmitted: (s) => _doSubmit(),
                decoration: InputDecoration(
                  hintText: 'Password',
                  icon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (String? value) {
                  _data.password = value!.trim();
                },
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: InkWell(
            onTap: () {
              _formKey.currentState!.save();

              if (StrUtils.isEmailValid(_data.email)) {
                AuthService().sendPasswordResetEmail(_data.email);

                setState(() {
                  sentResetEmail = 1;
                });
              } else {
                setState(() {
                  sentResetEmail = 2;
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6),
              child: Text(
                _resetEmailText(),
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.lock_open, size: 16),
          onPressed: _doSubmit,
          label: const Text('Login'),
        ),
      ],
    );
  }
}

Future<LoginData?> showEmailLoginDialog(BuildContext context) async {
  return showGeneralDialog<LoginData>(
    barrierColor: Colors.black.withOpacity(0.5),
    transitionBuilder: (context, a1, a2, widget) {
      return Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: LoginDialog(),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      // never gets called, but is required
      return Container();
    },
  );
}

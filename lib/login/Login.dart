import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sequence/RoomScreen.dart';
import 'package:sequence/blocs/UserBloc.dart';
import 'package:sequence/blocs/WebsocketBloc.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/drive.readonly'
  ]);

  GoogleSignInAccount _googleUser;

  bool _isLoading = true;

  StreamSubscription _subs;

  @override
  void initState() {
    super.initState();
    _doSignIn();
  }

  _doSignIn() async {
    _googleUser = _googleSignIn.currentUser;
    _googleUser ??= await _googleSignIn.signInSilently();
    _googleUser ??= await _googleSignIn.signIn();
    if (_googleUser != null) {
      UserBloc().setCurrUser(_googleUser);
     // WebsocketBloc().connect();
     setState(() {
         _isLoading=false; 
     });

    }
  }

  @override
  void dispose() {
    super.dispose();
    WebsocketBloc().closeSocket();
    _subs?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : /*GameScreen(_user)*/RoomScreen();
  }
}

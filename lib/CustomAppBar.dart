import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sequence/blocs/CardBloc.dart';
import 'package:sequence/blocs/FirebaseDBListener.dart';
import 'package:sequence/blocs/GameController.dart';
import 'package:sequence/blocs/UserBloc.dart';
import 'package:sequence/model/FirebaseDBModel.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool isGameScreen;

  CustomAppBar(this.title, this.isGameScreen);

  @override
  State<StatefulWidget> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(50.0);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _isOn = false;

  String _title;

  StreamSubscription _subs;

  String _getPlayerName(String id) {
       return (id == UserBloc().getCurrUser().id)
            ? 'Your turn'
            : (id == GameController().getOtherPlayerDetails().id)
                ? GameController().getOtherPlayerDetails().name + "'s turn"
                : '';    
  }

  @override
  void initState() {
    _title = widget.isGameScreen?_getPlayerName(GameController().getPlayerTurn()):widget.title;
    _subs = FirebaseDBListener()
        .getController()
        .stream
        .where((item) =>
            item.type == FirebaseDBModel.PLAYER_TURN && widget.isGameScreen)
        .listen((data) {
      setState(() {
        _title = _getPlayerName(data.data);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _subs?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(color: Colors.green[700], boxShadow: [
          BoxShadow(color: Colors.green[500], blurRadius: 2, offset: Offset(1.0, 1.0))
        ]),
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              flex: 6,
                child: Container(
              margin: EdgeInsets.only(left: 15),
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(_title,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22)),
            )),
            Flexible(
              child: widget.isGameScreen
                  ? Switch(
                      value: _isOn,
                      onChanged: (value) {
                        setState(() {
                          _isOn = value;
                        });
                        CardBloc().addToController(value);
                      },
                      activeTrackColor: Colors.lightGreenAccent,
                      activeColor: Colors.green[400],
                    )
                  : Container(
                      width: 0,
                      height: 0,
                    ),
            )
          ],
        ),
      ),
    );
  }
}

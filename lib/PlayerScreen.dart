import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sequence/CustomAppBar.dart';
import 'package:sequence/RouteConstants.dart';
import 'package:sequence/blocs/FirebaseDBListener.dart';
import 'package:sequence/blocs/GameController.dart';
import 'package:sequence/blocs/UserBloc.dart';
import 'package:sequence/constants/GameConstants.dart';
import 'package:sequence/firebasedb/FirebaseRealtimeDB.dart';
import 'package:sequence/model/FirebaseDBModel.dart';
import 'package:sequence/model/RoomModel.dart';
import 'package:sequence/model/UserModel.dart';
import 'package:sequence/players/CurrPlayer.dart';
import 'package:sequence/players/OtherPlayer.dart';
import 'package:sequence/GameScreen.dart';

class PlayerScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  StreamSubscription _subs;
  StreamSubscription _roomSubs;
  StreamSubscription _userLeftSubs;

  checkForRoomRemoval() {
    _roomSubs = FirebaseDBListener()
        .getController()
        .stream
        .where((item) => item.type == FirebaseDBModel.ROOM)
        .listen((data) {
      if (null != data && null != data.data && data.data is List<RoomModel>) {
        List<RoomModel> list = data.data;
        int index = list.indexWhere(
            (item) => item.id == GameController().getRoomDetails().id);
        if (index < 0 && this.mounted) {
          GameController().popScreen(context, GameConstants.RESET_DATA);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseDBListener().listenForRoomChanges();
    if (null != FirebaseDBListener().getController()) {
      _subs = FirebaseDBListener()
          .getController()
          .stream
          .where((item) => item.type == FirebaseDBModel.ROOM_DETAILS)
          .listen((data) {
        if (data.data.status == RoomModel.IN_PROGRESS) {
          _startGame(context);
        }
      });
    }

    checkForRoomRemoval();

    if (null != FirebaseDBListener().getController()) {
      _userLeftSubs = FirebaseDBListener()
          .getController()
          .stream
          .where((item) => item.type == FirebaseDBModel.USER_LEFT)
          .listen((data) {
        String msg;
        String id;
        String name;
        if (data.data is UserModel) {
          id = data.data.id;
          name = data.data.name;
        } else {
          id = data.data;
        }
        if (id == UserBloc().getCurrUser().id) {
          msg = 'You got disconnected';
        } else {
          msg = (name != null) ? name : 'User' + ' left the game';
        }
        GameController().showToast(msg);
        GameController().popScreen(context, GameConstants.REMOVE_USER);
      });
    }
    FirebaseDBListener()
        .listenForGameRoomUsers(GameController().getRoomDetails().id);
  }

  @override
  dispose() {
    super.dispose();
    _subs?.cancel();
    _roomSubs?.cancel();
    _userLeftSubs?.cancel();
  }

  Widget _getButton(BuildContext context) {
    return StreamBuilder(
        initialData: GameController().getOtherPlayerDetails(),
        stream: FirebaseDBListener()
            .getController()
            .stream
            .where((item) => item.type == FirebaseDBModel.USER_ADD),
        builder: (BuildContext context, AsyncSnapshot snap) {
          if (snap.hasData && null != snap.data) {
            dynamic _user;
            if (snap.data is UserModel) {
              _user = snap.data;
            } else if (snap.data is FirebaseDBModel) {
              _user = snap.data.data;
            }
            return _getButtonIndicator(_user, context);
          }
          return _getButtonIndicator(
              GameController().getOtherPlayerDetails(), context);
        });
  }

  Widget _getButtonIndicator(dynamic otherPlayer, BuildContext context) {
    if (GameController().getRoomDetails().cBy == UserBloc().getCurrUser().id) {
      if (otherPlayer == null) {
        return showMsg('Waiting for other player to join');
      } else {
        return _startButton(context);
      }
    } else if (otherPlayer != null &&
            GameController().getRoomDetails().status ==
                RoomModel.YET_TO_START ||
        GameController().getRoomDetails().status == RoomModel.ON_HOLD) {
      String msg = (otherPlayer != null)
          ? 'Waiting for ' + otherPlayer.name + ' to start'
          : 'Waiting for other player to join';
      return showMsg(msg);
    } else {
      return Container(
        width: 0,
        height: 0,
      );
    }
  }

  Widget showMsg(String msg) {
    return Container(
      width: 300,
      height: 40,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.yellow, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          CircularProgressIndicator(
            strokeWidth: 2.0,
          ),
          Text(
            msg,
            style: TextStyle(color: Colors.black),
          )
        ],
      ),
    );
  }

  Widget _startButton(BuildContext context) {
    return RaisedButton(
      color: Colors.green[700],
      child: GameController().getRoomDetails().status == RoomModel.YET_TO_START
          ? Text(
              'Start',
              style: TextStyle(color: Colors.white),
            )
          : Text(
              'Continue',
              style: TextStyle(color: Colors.white),
            ),
      onPressed: () {
        if (GameController().getRoomDetails().status == RoomModel.IN_PROGRESS) {
          _startGame(context);
        } else {
          GameController().getRoomDetails().status = RoomModel.IN_PROGRESS;
          FirebaseRealtimeDB().setGameRoom(GameController().getRoomDetails());
        }
      },
    );
  }

  _startGame(BuildContext context) async {
    String roomId = GameController().getRoomDetails().id;
    List<String> list = await FirebaseRealtimeDB().getInitPanelCards(roomId);
    GameController()
        .setPlayerTurn(await FirebaseRealtimeDB().getInitGameTurn(roomId));
    GameController().getRoomDetails().status = RoomModel.IN_PROGRESS;
    Navigator.pushReplacementNamed(context, RouteConstants.GAME_PAGE,
        arguments: GameScreenArgs(list));
  }

  Future<bool> _onWillPop() {
    GameController().popScreen(context, GameConstants.REMOVE_USER);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          appBar: CustomAppBar('Sequence',false,70.0),
          backgroundColor: GameConstants.bgColor,
          body: Center(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(GameController().getRoomDetails().name,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w600)),
                  ),
                  Flex(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Flexible(
                        flex: 5,
                        child: CurrPlayer(false),
                      ),
                      OtherPlayer(false)
                    ],
                  ),
                  _getButton(context),
                ],
              ),
            ),
          )),
    );
  }
}

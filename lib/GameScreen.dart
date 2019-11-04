import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sequence/GameBoard.dart';
import 'package:sequence/GameResult.dart';
import 'package:sequence/PlayerTurn.dart';
import 'package:sequence/blocs/CheckSequenceBloc.dart';
import 'package:sequence/blocs/FirebaseDBListener.dart';
import 'package:sequence/blocs/GameController.dart';
import 'package:sequence/GameCardPanel.dart';
import 'package:sequence/blocs/GameBloc.dart';
import 'package:sequence/blocs/UserBloc.dart';
import 'package:sequence/cards/LastCard.dart';
import 'package:sequence/constants/GameConstants.dart';
import 'package:sequence/firebasedb/FirebaseRealtimeDB.dart';
import 'package:sequence/model/BlocModel.dart';
import 'package:sequence/model/FirebaseDBModel.dart';
import 'package:sequence/model/RoomModel.dart';
import 'package:sequence/model/UserModel.dart';
import 'package:sequence/players/CurrPlayer.dart';
import 'package:sequence/players/OtherPlayer.dart';

class GameScreen extends StatefulWidget {
  final List<String> panelList;

  GameScreen(this.panelList);

  @override
  State<StatefulWidget> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  StreamSubscription _userLeftSubs;

  StreamSubscription _userWonSubs;

  StreamSubscription _animSubs;

  StreamSubscription _roomSubs;

  bool _gameWon = false;

  RoomModel _model;

  doInit() {
    String roomId = GameController().getRoomDetails().id;
    FirebaseRealtimeDB().getInitGameTurn(roomId).then((data) {
      GameController().setPlayerTurn(data);
    });
  }

  checkForRoomRemoval() {
      _roomSubs = FirebaseDBListener().getController().stream.where((item) => item.type == FirebaseDBModel.ROOM)
      .listen((data) {
          if(null!=data && null!=data.data && data.data is List<RoomModel>) {
                   List<RoomModel> list = data.data;
                   int index = list.indexWhere((item) => item.id == GameController().getRoomDetails().id);
                   if(index <0  && this.mounted) {
                          GameController().popScreen(context, GameConstants.RESET_DATA);
                   }
          }
      });
  }

  openSubs() {
    if (null != FirebaseDBListener().getController()) {
      _userLeftSubs = FirebaseDBListener()
          .getController()
          .stream
          .where((item) =>
              item.type == FirebaseDBModel.USER_LEFT &&
              !_gameWon &&
              this.mounted)
          .listen((data) {
        String msg;
        String id;
        String name;
        if (data.data is UserModel) {
          id = data.data.id;
          name = data.data.name;
        } else {
          id = data.data['id'];
        }
        if (id == UserBloc().getCurrUser().id) {
          msg = 'You got disconnected';
        } else {
          msg = (name != null) ? name : 'User' + ' left the game';
        }
        GameController().showToast(msg);
        GameController().popScreen(context, GameConstants.REMOVE_USER);
      });

      _userWonSubs = FirebaseDBListener()
          .getController()
          .stream
          .where((item) => (item.type == FirebaseDBModel.ROOM_DETAILS))
          .listen((data) {
        if (GameController().getAnimRunning()) {
          _gameWon = data.data.status == RoomModel.GAME_WON;
          _model = data.data;
        } else {
          setState(() {
            _gameWon = data.data.status == RoomModel.GAME_WON;
            _model = data.data;
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    GameController().setGameCreationTime();
    GameBloc().openController();
    GameController().openResetGameController();
    FirebaseDBListener()
        .listenForPlayerTurns(GameController().getRoomDetails().id);
    openSubs();
    CheckSequenceBloc().setInitSeqCount();

    _animSubs = GameBloc()
        .getController()
        .stream
        .where((item) => (item.cardType == BlocModel.BOARD_CARD &&
            item.type == BlocModel.SEQ_COMPLETED_ANIM &&
            _gameWon))
        .listen((_) {
      setState(() {
        _gameWon = true;
        _model = _model;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => FirebaseDBListener()
        .listenForBoardCardChanges(GameController().getRoomDetails().id));
  }

  @override
  void dispose() {
    _userLeftSubs?.cancel();
    _userWonSubs?.cancel();
    _animSubs?.cancel();
    _roomSubs?.cancel();
    super.dispose();
  }

  Widget _dialogButtons(String name, BuildContext context) {
    return FlatButton(
      child: Text(name),
      onPressed: () {
        Navigator.pop(context, name);
      },
    );
  }
  
  Future<bool> _showAlertDialog(BuildContext context) async {
    dynamic val = await showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return AlertDialog(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: <Widget>[
                  Text('Exit Game?',style: TextStyle(color: Colors.blue),),
                  Text("You'll lose the game if you discard",style: TextStyle(color: Colors.grey,fontSize: 17
                  ,fontStyle: FontStyle.italic),)
               ],
            ),
            actions: <Widget>[
              _dialogButtons('Cancel', context),
              _dialogButtons('Save and Exit', context),
              _dialogButtons('Discard and Exit', context),
            ],
          );
        });
    if (val.toString() == 'Discard and Exit') {
      GameController().popScreen(context, GameConstants.REMOVE_GAME_DISCARD);
    } else if (val.toString() == 'Save and Exit') {
      GameController().popScreen(context, GameConstants.REMOVE_USER);
    }
    return false;
  }

  Future<bool> _onWillPop() {
    if (_gameWon) {
      return Future.value(true);
    }
    return _showAlertDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        child: Scaffold(
            backgroundColor: GameConstants.bgColor,
            body: Stack(
              children: <Widget>[
                Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    PlayerTurn(),
                    Flexible(
                      flex: 7,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 0.96 * MediaQuery.of(context).size.width,
                          height: 0.7 * MediaQuery.of(context).size.height,
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          decoration: BoxDecoration(
                              color: Colors.green[300],
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 1,
                                    offset: Offset(1.0, 1.0))
                              ]),
                          child: GameBoard(),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          CurrPlayer(true),
                          Stack(
                            children: <Widget>[
                              Positioned(
                                left: 80,
                                child: LastCard(),
                              ),
                              OtherPlayer(true),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GameCardPanel(widget.panelList)
                  ],
                ),
                (_model!= null)?GameResult(_model):Container(width: 0,height: 0,)
              ],
            )),
      ),
    );
  }
}

class GameScreenArgs {
  final List<String> panelList;

  GameScreenArgs(this.panelList);
}

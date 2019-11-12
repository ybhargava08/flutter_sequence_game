import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sequence/RouteConstants.dart';
import 'package:sequence/blocs/GameBloc.dart';
import 'package:sequence/blocs/UserBloc.dart';
import 'package:sequence/constants/GameConstants.dart';
import 'package:sequence/firebasedb/FirebaseRealtimeDB.dart';
import 'package:sequence/model/CardModel.dart';
import 'package:sequence/model/ResetGameModel.dart';
import 'package:sequence/model/RoomModel.dart';
import 'package:sequence/model/UserModel.dart';

class GameController {
  static GameController _resetGameController;

  factory GameController() => _resetGameController ??= GameController._();

  GameController._();

  StreamController<ResetGameModel> _controller;

  bool _animationRunning = false;

  RoomModel _roomModel;

  UserModel _otherPlayerDetails;

  String _playerTurnId;

  int _time;

  Future<void> navigateToPlayerScreen(
      RoomModel roomModel, BuildContext context) async {
    GameController().setRoomDetails(roomModel);
    //if(await WebsocketBloc().joinRoom()) {
    UserModel model = await FirebaseRealtimeDB()
        .getInitGameUser(GameController().getRoomDetails().id);

    UserBloc().getCurrUser().color = model.color;

    Navigator.pushNamed(context, RouteConstants.PLAYER_PAGE);
    //}
  }

  setOtherPlayerDetails(UserModel model) {
    _otherPlayerDetails = model;
  }

  setGameCreationTime() {
    _time = DateTime.now().millisecondsSinceEpoch;
  }

  getGameCreationTime() {
    return _time;
  }

  UserModel getOtherPlayerDetails() {
    if (null != _otherPlayerDetails) {
      return _otherPlayerDetails;
    }
    /*UserModel user = UserModel(
        /*UserBloc().getCurrUser().name*/'Yash Bhargava',
        UserBloc().getCurrUser().photoUrl,
        '99999',
        UserBloc().getCurrUser().email,
        'teal');
    return user;*/
  //  return UserBloc().getCurrUser();
    return null;
  }

  setRoomDetails(RoomModel model) {
    _roomModel = model;
  }

  RoomModel getRoomDetails() {
    return _roomModel;
  }

  setPlayerTurn(String id) {
    _playerTurnId = id;
  }

  getPlayerTurn() {
    return _playerTurnId;
  }

  bool isTapAllowed() {
    return (_playerTurnId == null ||
            _playerTurnId == UserBloc().getCurrUser().id) &&
        !_animationRunning;
  }

  setAnimRunning(bool animRunning) {
    _animationRunning = animRunning;
  }

  getAnimRunning() {
    return _animationRunning;
  }

  openResetGameController() {
    closeResetGameController();
    _controller = StreamController.broadcast();
  }

  addToResetGameController(ResetGameModel data) {
    if (_isResetGameControllerClosed()) {
      openResetGameController();
    }
    _controller.sink.add(data);
  }

  StreamController<ResetGameModel> getResetGameController() {
    if (_isResetGameControllerClosed()) {
      openResetGameController();
    }
    return _controller;
  }

  _isResetGameControllerClosed() {
    return _controller == null || _controller.isClosed;
  }

  closeResetGameController() {
    if (!_isResetGameControllerClosed()) {
      _controller.close();
    }
  }

  removeRoomDetails(String roomId) async {
    await FirebaseRealtimeDB().removeGame(roomId);
  }

  showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.black.withOpacity(0.8),
        fontSize: 15,
        textColor: Colors.white);
  }

  checkForGameDrawAndSetStatus() async {
    List<dynamic> list = GameBloc().getPanelCards();
    List<CardModel> valueList = GameBloc().getBoardCardMap().values.toList();
    bool isGameDraw = (null == list ||
        list.isEmpty ||
        list.indexWhere((item) => item is CardModel) < 0);

    if (!isGameDraw) {
      isGameDraw = !_canPlaceCard(list, valueList);
    }

    if (!isGameDraw) {
      List<CardModel> filterList =
          valueList.where((item) => !item.isChipPlaced).toList();
      isGameDraw = (filterList == null || filterList.isEmpty);
    }

    if (isGameDraw) {
      RoomModel model = getRoomDetails();
      model.winner = null;
      model.winnerPhotoUrl = null;
      model.status = RoomModel.GAME_DRAW;

      FirebaseRealtimeDB().setGameRoom(model);
      FirebaseRealtimeDB().setScoreCard('draw');
    }
  }

  bool _canPlaceCard(
      List<dynamic> panelCardList, List<CardModel> boardCardList) {
    for (var item in panelCardList) {
      if (item != null &&
          item is CardModel &&
          (item.value == 'J1' || item.value == 'J2')) {
        return true;
      }
    }

    for (CardModel card in boardCardList.where((c) => !c.isChipPlaced)) {
      for (var item in panelCardList) {
        if (item != null &&
            item is CardModel &&
            ((card.value == item.value && !card.isChipPlaced) ||
                item.value == 'J1')) {
          return true;
        }
      }
    }
    return false;
  }

  popScreen(BuildContext context, String data) {
    if (Navigator.canPop(context)) {
      bool isPopped = Navigator.of(context).pop(data);
      if(isPopped && null!=data) {
        _handlePopScreenDataWithDelay(data,500);
      }
    }
  }

  _handlePopScreenDataWithDelay(String data,int delay) async {
        await Future.delayed(Duration(milliseconds: delay),() => _handlePopScreenData(data));
  }

  _handlePopScreenData(String data) async {
    if (data == GameConstants.REMOVE_USER) {
      GameController().getRoomDetails().status = RoomModel.ON_HOLD;
      FirebaseRealtimeDB().setGameRoom(GameController().getRoomDetails());
      FirebaseRealtimeDB()
          .removeUser(getRoomDetails().id, UserBloc().getCurrUser().id);
          
    }else if(data == GameConstants.REMOVE_GAME) {
        await GameController().removeRoomDetails(GameController().getRoomDetails().id);
    }else if(data == GameConstants.REMOVE_GAME_DISCARD) {
         await FirebaseRealtimeDB().setScoreCard(GameController().getOtherPlayerDetails().id);
     await GameController().removeRoomDetails(GameController().getRoomDetails().id);
    }
    _resetData();
  }

  _resetData() {
       setOtherPlayerDetails(null);
       setRoomDetails(null);
       setAnimRunning(false);
       setPlayerTurn(null);
       _time =0;
  }

}

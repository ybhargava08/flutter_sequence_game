import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sequence/blocs/GameController.dart';
import 'package:sequence/blocs/UserBloc.dart';
import 'package:sequence/firebasedb/FirebaseRealtimeDB.dart';
import 'package:sequence/firebasedb/FirestoreDB.dart';
import 'package:sequence/model/CardModel.dart';
import 'package:sequence/model/FirebaseDBModel.dart';
import 'package:sequence/model/RoomModel.dart';
import 'package:sequence/model/UserModel.dart';

class FirebaseDBListener {
  static FirebaseDBListener _firebaseDBListener;

  factory FirebaseDBListener() =>
      _firebaseDBListener ??= FirebaseDBListener._();

  FirebaseDBListener._();

  StreamSubscription _boardSubs;

  StreamSubscription _userAddSubs;

  StreamSubscription _userRemoveSubs;

  StreamSubscription _roomAddSubs;

  StreamSubscription _roomChangeSubs;

  StreamSubscription _roomRemoveSubs;

  StreamSubscription _playerTurnSubs;

  StreamController<FirebaseDBModel> _controller;

  static List<RoomModel> _list = List();

  _openController() {
    if (_isControllerClosed()) {
      _controller = StreamController.broadcast();
    }
  }

  List<RoomModel> getRoomList() {
    return _list;
  }

  addToController(FirebaseDBModel model) {
    if (!_isControllerClosed()) {
      _controller.sink.add(model);
    }
  }

  StreamController<FirebaseDBModel> getController() {
    if (_isControllerClosed()) {
      _openController();
    }
    return _controller;
  }

  bool _isControllerClosed() {
    return null == _controller || _controller.isClosed;
  }

  listenForBoardCardChanges(String roomId) {
    _openController();
    _boardSubs = FirestoreDB()
        .getBoardCardRef(null)
        .where('time',
            isGreaterThanOrEqualTo: GameController().getGameCreationTime())
        .where('from', isEqualTo: GameController().getOtherPlayerDetails().id)
        .orderBy('time', descending: true)
        .limit(1)
        .snapshots()
        .listen((data) {
      data.documentChanges.forEach((change) {
        if (null != change.document &&
            (change.type == DocumentChangeType.added ||
                change.type == DocumentChangeType.modified)) {
          CardModel card = CardModel.fromDocumentSnapshot(change.document);
          addToController(FirebaseDBModel(FirebaseDBModel.CARD, card));
        }
      });
    });
  }

  listenForGameRoomUsers(String roomId) {
    _openController();
    _userAddSubs = FirebaseRealtimeDB()
        .getRoomUsersRef(roomId)
        .onChildAdded
        .where((e) =>
            snapShotValTest(e) && e.snapshot.key != UserBloc().getCurrUser().id)
        .listen((event) {
      print('key ' +
          event.snapshot.key +
          ' value ' +
          event.snapshot.value.toString());
      UserModel userModel = UserModel.fromJson(event.snapshot.value);
      if (userModel.id != UserBloc().getCurrUser().id) {
        GameController().setOtherPlayerDetails(userModel);
      }
      addToController(FirebaseDBModel(FirebaseDBModel.USER_ADD, userModel));
    });

    _userRemoveSubs = FirebaseRealtimeDB()
        .getRoomUsersRef(roomId)
        .onChildRemoved
        .where((e) => snapShotValTest(e))
        .listen((event) {
      print('key ' +
          event.snapshot.key +
          ' value ' +
          event.snapshot.value.toString());
          UserModel user = UserModel.fromJson(event.snapshot.value);
      addToController(
          FirebaseDBModel(FirebaseDBModel.USER_LEFT, user));
    });
  }

  listenForAllRooms() {
    _openController();
    _roomAddSubs = FirebaseRealtimeDB()
        .getAllRoomsRef()
        .onChildAdded
        .where((e) => snapShotValTest(e))
        .listen((event) {
      print('key ' +
          event.snapshot.key +
          ' value ' +
          event.snapshot.value.toString());
      RoomModel roomModel = RoomModel.fromJson(event.snapshot.value);
      _list.add(roomModel);
      addToController(FirebaseDBModel(FirebaseDBModel.ROOM, _list));
    });
    _roomRemoveSubs = FirebaseRealtimeDB()
        .getAllRoomsRef()
        .onChildRemoved
        .where((e) => snapShotValTest(e))
        .listen((event) {
      print('key ' +
          event.snapshot.key +
          ' value ' +
          event.snapshot.value.toString());
      RoomModel roomModel = RoomModel.fromJson(event.snapshot.value);
      _list.removeWhere((item) => item.id == roomModel.id);

      addToController(FirebaseDBModel(FirebaseDBModel.ROOM, _list));
    });
  }

  listenForRoomChanges() {
    if (GameController().getRoomDetails() != null &&
        GameController().getRoomDetails().id != null) {
      _roomChangeSubs = FirebaseRealtimeDB()
          .getAllRoomsRef()
          .child(GameController().getRoomDetails().id)
          .onValue
          .where((e) => snapShotValTest(e))
          .listen((event) {
        print(' room changes key ' +
            event.snapshot.key +
            ' value ' +
            event.snapshot.value.toString());
        RoomModel roomModel = RoomModel.fromJson(event.snapshot.value);
        GameController().setRoomDetails(roomModel);
        addToController(
            FirebaseDBModel(FirebaseDBModel.ROOM_DETAILS, roomModel));
      });
    }
  }

  listenForPlayerTurns(String roomId) {
    _openController();
    _playerTurnSubs = FirebaseRealtimeDB()
        .getPlayerTurnRef(roomId)
        .onChildChanged
        .where((e) => snapShotValTest(e))
        .listen((event) {
      print('key ' +
          event.snapshot.key +
          ' value ' +
          event.snapshot.value.toString());
      String turnId;
      if (event.snapshot.value is String) {
        turnId = event.snapshot.value;
      } else if (event.snapshot.value is Map) {
        turnId = event.snapshot.value['id'];
      }
      addToController(FirebaseDBModel(FirebaseDBModel.PLAYER_TURN, turnId));
      GameController().setPlayerTurn(turnId);
      if (turnId == UserBloc().getCurrUser().id) {
        GameController().checkForGameDrawAndSetStatus();
      }
    });
  }

  bool snapShotValTest(Event event) {
    return null != event &&
        null != event.snapshot &&
        null != event.snapshot.value;
  }

  closeBoardSubs() {
    _boardSubs?.cancel();
    _playerTurnSubs?.cancel();
  }

  closeAllSubs() {
    _boardSubs?.cancel();
    _userAddSubs?.cancel();
    _roomAddSubs?.cancel();
    _roomRemoveSubs?.cancel();
    _controller?.close();
    _playerTurnSubs?.cancel();
    _userRemoveSubs?.cancel();
    _roomChangeSubs?.cancel();
  }
}

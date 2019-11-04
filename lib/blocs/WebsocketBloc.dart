import 'dart:async';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:http/http.dart' as http;
import 'package:sequence/blocs/FirebaseDBListener.dart';
import 'package:sequence/blocs/GameController.dart';
import 'package:sequence/blocs/UserBloc.dart';
import 'package:sequence/model/FirebaseDBModel.dart';

class WebsocketBloc {
  static WebsocketBloc _websocketBloc;

  factory WebsocketBloc() => _websocketBloc ??= WebsocketBloc._();

  WebsocketBloc._();

  SocketIO socket;

  SocketIOManager manager;

  static const String USER_JOINED = 'userJoined';
  static const String USER_LEFT = 'userLeft';

  static const String uri = 'http://192.168.1.47:4000';

  connect() async {
    manager = SocketIOManager();
    socket = await manager.createInstance(SocketOptions(uri,
        query: {'userId': UserBloc().getCurrUser().id},
        enableLogging: true,
        nameSpace: '/'));

    socket.connect();

    socket.onDisconnect((data){
          FirebaseDBListener().addToController(
            FirebaseDBModel(FirebaseDBModel.USER_LEFT, UserBloc().getCurrUser().id));
    });

    socket.onConnect((data) async {
      print('connected');
      socket.emit(USER_JOINED, [UserBloc().getCurrUser().id]);
    });

    socket.onError((err) {
      print('error ' + err.toString());
    });

    socket.onConnectError((err) {
      print('error ' + err.toString());
    });

    /*socket.on(USER_JOINED, (data) {
      print(USER_JOINED + ' got data ' + data.toString());
    });*/
    socket.on(USER_LEFT, (data) {
      print(USER_LEFT + ' got data ' + data.toString());
      if (data['id'] == UserBloc().getCurrUser().id ||
          data['id'] == GameController().getOtherPlayerDetails().id) {
        FirebaseDBListener().addToController(
            FirebaseDBModel(FirebaseDBModel.USER_LEFT, data['id']));
      }
    });
  }

  Future<bool> joinRoom() async {
    var response;
    try {
      response = await http.get(uri +
          '/joinRoom?userid=' +
          UserBloc().getCurrUser().id +
          '&roomId=' +
          GameController().getRoomDetails().id);
    } on Exception catch (e) {
      print('got exception ' + e.toString());
      return false;
    }
    if (null != response && 200 == response.statusCode) {
      print('got response for join room ' + response.body);
      return true;
    }

    return false;
  }

  closeSocket() {
    if (null != manager && null != socket) {
      manager.clearInstance(socket);
    }
  }
}

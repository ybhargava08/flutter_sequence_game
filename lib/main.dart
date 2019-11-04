import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sequence/GameScreen.dart';
import 'package:sequence/PlayerScreen.dart';
import 'package:sequence/RoomScreen.dart';
import 'package:sequence/RouteConstants.dart';
import 'package:sequence/login/Login.dart';

main() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MaterialApp(
    home: Login(),
    debugShowCheckedModeBanner:false,
    onGenerateRoute: (RouteSettings settings) {
      switch (settings.name) {
        case RouteConstants.ROOM_PAGE:
          return MaterialPageRoute(builder: (context) => RoomScreen());
        case RouteConstants.PLAYER_PAGE:
          return MaterialPageRoute(builder: (context) => PlayerScreen());
        case RouteConstants.GAME_PAGE:
          GameScreenArgs args = settings.arguments;
          return MaterialPageRoute(
              builder: (context) => GameScreen(args.panelList));
        default:
          return MaterialPageRoute(builder: (context) => Login());
      }
    },
  ));
}

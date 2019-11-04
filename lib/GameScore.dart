import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sequence/blocs/GameBloc.dart';
import 'package:sequence/blocs/GameController.dart';
import 'package:sequence/blocs/UserBloc.dart';
import 'package:sequence/firebasedb/FirebaseRealtimeDB.dart';

class GameScore extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GameScoreState();
}

class _GameScoreState extends State<GameScore> {
  int _won = 0;
  int _lost = 0;
  int _draw = 0;

  double _boxDimension = 90;

  String _otherPlayerId = GameController().getOtherPlayerDetails().id;

  @override
  void initState() {
    super.initState();
    getScoreDetails();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GameController().removeRoomDetails(GameController().getRoomDetails().id);
    });
  }

  getScoreDetails() async {
    DataSnapshot data = await FirebaseRealtimeDB()
        .getScoreRef(GameBloc().getConcatenatedId(UserBloc().getCurrUser().id,
            _otherPlayerId))
        .once();
    if (null != data && null != data.value) {
      setState(() {
        _won = (data.value[UserBloc().getCurrUser().id] != null)
            ? data.value[UserBloc().getCurrUser().id]
            : _won;
        _lost =
            (data.value[_otherPlayerId] != null)
                ? data.value[_otherPlayerId]
                : _lost;
        _draw = (data.value['draw'] != null) ? data.value['draw'] : _draw;
      });
    }
  }

  Widget _displayScore(String type, int score, Color color) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(type,
              style: TextStyle(
                  color: color, fontSize: 25, fontWeight: FontWeight.bold)),
          Center(
            child: Text(score.toString(),
                style: TextStyle(
                    color: color, fontSize: 30, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3*_boxDimension,
      height: _boxDimension,
      margin: EdgeInsets.only(top: 40),
      decoration: BoxDecoration(
         color: Colors.white,
         boxShadow: [
            BoxShadow(
                color: Colors.grey[200], blurRadius: 10, offset: Offset(2.0, 2.0))
          ]
      ),
      
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: _displayScore('Won', _won, Colors.green),
          ),
          Flexible(
            flex: 1,
            child: _displayScore('Lost', _lost, Colors.red),
          ),
          Flexible(
            flex: 1,
            child: _displayScore('Draw', _draw, Colors.blue),
          )
        ],
      ),
    );
  }
}

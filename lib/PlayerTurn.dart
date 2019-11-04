import 'package:flutter/material.dart';
import 'package:sequence/blocs/FirebaseDBListener.dart';
import 'package:sequence/blocs/GameController.dart';
import 'package:sequence/blocs/UserBloc.dart';
import 'package:sequence/model/FirebaseDBModel.dart';

class PlayerTurn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDBListener()
          .getController()
          .stream
          .where((item) => item.type == FirebaseDBModel.PLAYER_TURN),
      initialData: GameController().getPlayerTurn(),
      builder: (BuildContext context, AsyncSnapshot snap) {
        if (snap.hasData) {
          String id;
          if (snap.data is String) {
            id = snap.data;
          } else if (snap.data is FirebaseDBModel) {
            id = snap.data.data;
          }
          String name = (id == UserBloc().getCurrUser().id)
              ? 'Your turn'
              : (id == GameController().getOtherPlayerDetails().id)
                  ? GameController().getOtherPlayerDetails().name+"'s turn"
                  : '';
          return Container(
            alignment: Alignment.topCenter,
            width: 0.96 * MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey,
                      blurRadius: 4,
                      offset: Offset(2.0, 2.0))
                ]),
            child: Text(
              name ,
              style: TextStyle(
                  fontSize: 25,
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400),
            ),
          );
        }
        return Container(
          width: 0,
          height: 0,
        );
      },
    );
  }
}

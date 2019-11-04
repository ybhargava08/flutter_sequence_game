import 'package:flutter/material.dart';
import 'package:sequence/blocs/FirebaseDBListener.dart';
import 'package:sequence/blocs/GameController.dart';
import 'package:sequence/blocs/UserBloc.dart';
import 'package:sequence/model/FirebaseDBModel.dart';
import 'package:sequence/model/UserModel.dart';
import 'package:sequence/players/Player.dart';

class OtherPlayer extends StatelessWidget{

   final bool showChip;

  OtherPlayer(this.showChip);

    @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        initialData: GameController().getOtherPlayerDetails(),
        stream: FirebaseDBListener().getController().stream.where((item) => item.type == FirebaseDBModel.USER_ADD
        && item.data is UserModel && item.data.id != UserBloc().getCurrUser().id),
        builder: (BuildContext context,AsyncSnapshot snap) {
               if(snap.hasData && snap.data!=null) {
                    if(snap.data is FirebaseDBModel) {
                          return Player(snap.data.data, showChip);
                    }else if (snap.data is UserModel) {
                       return Player(snap.data, showChip);
                    }
               }
               return Container(width: 0,height: 0,);
        },
    );
  }

}
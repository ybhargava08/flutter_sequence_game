import 'package:flutter/material.dart';
import 'package:sequence/AnimatedChip.dart';
import 'package:sequence/GameChip.dart';
import 'package:sequence/blocs/FirebaseDBListener.dart';
import 'package:sequence/blocs/GameController.dart';
import 'package:sequence/blocs/UserBloc.dart';
import 'package:sequence/model/FirebaseDBModel.dart';
import 'package:sequence/model/UserModel.dart';

class Player extends StatelessWidget {
  final UserModel user;

  final bool showChip;

  Player(this.user, this.showChip);

  Widget _showAnimChip() {
    return Stack(
      children: <Widget>[
        AnimatedChip(user),
        GameChip(user.color, user.id, false)
      ],
    );
  }

  List<Widget> getChildWidgets(BuildContext context) {
    List<Widget> list = List();
    list.add(getPlayerWidget(context));
    if (null != user &&
        null != GameController().getOtherPlayerDetails() &&
        user.id == GameController().getOtherPlayerDetails().id) {
      list.add(getChipWidget());
    } else {
      list.insert(0, getChipWidget());
    }
    return list;
  }

  Widget getChipWidget() {
    return showChip
        ? _showAnimChip()
        : Container(
            width: 0,
            height: 0,
          );
  }

  Widget getPlayerWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        StreamBuilder(
          initialData: GameController().getPlayerTurn(),
          stream: FirebaseDBListener()
              .getController()
              .stream
              .where((item) => item.type == FirebaseDBModel.PLAYER_TURN),
          builder: (BuildContext context, AsyncSnapshot snap) {
            if (snap.hasData) {
              String id;
              if (snap.data is String) {
                id = snap.data;
              } else if (snap.data is FirebaseDBModel) {
                id = snap.data.data;
              }
              return Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: (id == user.id && showChip)
                        ? Border.all(color: Colors.cyanAccent, width: 3)
                        : Border.all(width: 0),
                    image: DecorationImage(
                      image: NetworkImage(user.photoUrl),
                    )),
              );
            }
            return Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(user.photoUrl),
                  )),
            );
          },
        ),
        showChip
            ? Container(
                width: 0,
                height: 0,
              )
            : ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 0.4 * MediaQuery.of(context).size.width,
                  minWidth: 0,
                ),
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Text(
                    user.name,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return (null != user)
        ? Container(
            margin: user.id == UserBloc().getCurrUser().id
                ? EdgeInsets.only(left: 40)
                : EdgeInsets.only(right: 40),
            child: Row(children: getChildWidgets(context)),
          )
        : Container(
            width: 0,
            height: 0,
          );
  }
}

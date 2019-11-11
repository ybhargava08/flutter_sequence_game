import 'package:flutter/material.dart';
import 'package:sequence/blocs/GameController.dart';
import 'package:sequence/cards/BlankCard.dart';
import 'package:sequence/cards/PanelCard.dart';
import 'package:sequence/blocs/GameBloc.dart';
import 'package:sequence/constants/GameConstants.dart';
import 'package:sequence/model/CardModel.dart';
import 'package:sequence/model/ResetGameModel.dart';

class GameCardPanel extends StatelessWidget {

  final List<String> panelList;

  GameCardPanel(this.panelList);

  List<Widget> _getCardPanel(List<dynamic> list) {
    List<Flexible> result = List();
    list.forEach((card) {
      result.add(Flexible(
          flex: 1, child: (card is CardModel) ? PanelCard(UniqueKey(),card) : BlankCard(UniqueKey())));
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: GameBloc().getCardPanel(panelList),
      stream: GameController()
          .getResetGameController()
          .stream
          .where((item) => item.type == ResetGameModel.PANEL),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          List<dynamic> list;
          if (snapshot.data is ResetGameModel) {
            list = snapshot.data.data;
          } else if (snapshot.data is List<dynamic>) {
            list = snapshot.data;
          }
          return Container(
            width: list.length*GameConstants.CARD_WIDTH_FACTOR*MediaQuery.of(context).size.width,
            height: GameConstants.CARD_HEIGHT_FACTOR * MediaQuery.of(context).size.height,
            margin: EdgeInsets.only(bottom: 4),
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _getCardPanel(list),
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

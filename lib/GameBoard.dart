import 'package:flutter/widgets.dart';
import 'package:sequence/blocs/GameBloc.dart';
import 'package:sequence/cards/BoardCard.dart';
import 'package:sequence/model/CardModel.dart';

class GameBoard extends StatelessWidget {
  GameBoard();

  List<Flexible> _getCardList(List<CardModel> list) {
    List<Flexible> result = List();
    list.forEach((value) {
      result.add(Flexible(
        flex: 1,
        child: BoardCard(UniqueKey(), value),
      ));
    });

    return result;
  }

  List<Flexible> _getGameBoardCols(List<dynamic> gameBoard) {
    List<Flexible> list = List();
    gameBoard.forEach((itemList) {
      list.add(
        Flexible(
            flex: 1,
            child: Flex(
              direction: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _getCardList(itemList),
            )),
      );
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      children: _getGameBoardCols(GameBloc().createBoard()),
    );
  }
}

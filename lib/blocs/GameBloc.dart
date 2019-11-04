import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:sequence/blocs/GameController.dart';
import 'package:sequence/blocs/UserBloc.dart';
import 'package:sequence/firebasedb/FirebaseRealtimeDB.dart';
import 'package:sequence/model/BlocModel.dart';
import 'package:sequence/model/CardModel.dart';
import 'package:sequence/model/ResetGameModel.dart';

class GameBloc {
  static GameBloc _gamePanelBloc;
  factory GameBloc() => _gamePanelBloc ??= GameBloc._();
  GameBloc._();

  Map<String, GlobalKey> _globalKeyMap = Map();

  Map<String, CardModel> _indexMap = Map();

  List<List<String>> _gameBoard = <List<String>>[
    <String>['wild', '6D', '7D', '8D', '9D', '10D', 'QD', 'KD', 'AD', 'wild'],
    <String>['5D', '3H', '2H', '2S', '3S', '4S', '5S', '6S', '7S', 'AC'],
    <String>['4D', '4H', 'KD', 'AD', 'AC', 'KC', 'QC', '10C', '8S', 'KC'],
    <String>['3D', '5H', 'QD', 'QH', '10H', '9H', '8H', '9C', '9S', 'QC'],
    <String>['2D', '6H', '10D', 'KH', '3H', '2H', '7H', '8C', '10S', '10C'],
    <String>['AS', '7H', '9D', 'AH', '4H', '5H', '6H', '7C', 'QS', '9C'],
    <String>['KS', '8H', '8D', '2C', '3C', '4C', '5C', '6C', 'KS', '8C'],
    <String>['QS', '9H', '7D', '6D', '5D', '4D', '3D', '2D', 'AS', '7C'],
    <String>['10S', '10H', 'QH', 'KH', 'AH', '2C', '3C', '4C', '5C', '6C'],
    <String>['wild', '9S', '8S', '7S', '6S', '5S', '4S', '3S', '2S', 'wild']
  ];

  StreamController<BlocModel> _controller;

  List<List<CardModel>> createBoard() {
    List<List<CardModel>> result = List();
    int i = 0;
    _gameBoard.forEach((listitem) {
      List<CardModel> list = List();
      int j = 0;
      listitem.forEach((item) {
        String key = i.toString() + j.toString();
        CardModel card = CardModel(UserBloc().getCurrUser().id, item, true, key,
            UserBloc().getCurrUser().color, false, false, false, false);
        list.add(card);
        _indexMap[key] = card;
        j++;
      });
      i++;
      result.add(list);
    });
    return result;
  }

  setCardInIndexMap(String key, CardModel value) {
    _indexMap[key] = value;
  }

  CardModel getCardFromMap(String key) {
    return _indexMap[key];
  }

  Map<String, CardModel> getBoardCardMap() {
    return _indexMap;
  }

  setGlobalKey(String key, GlobalKey value) {
    _globalKeyMap[key] = value;
  }

  GlobalKey findGlobalKey(String key) {
    if (_globalKeyMap.containsKey(key)) {
      return _globalKeyMap[key];
    }
    return null;
  }

  openController() {
    closeController();
    _controller = StreamController.broadcast();
  }

  bool _isControllerClosed() {
    return _controller == null || _controller.isClosed;
  }

  addToController(BlocModel model) async {
    if (_isControllerClosed()) {
      openController();
    }
    _controller.sink.add(model);
  }

  StreamController<BlocModel> getController() {
    if (_isControllerClosed()) {
      openController();
    }
    return _controller;
  }

  closeController() {
    if (!_isControllerClosed()) {
      _controller.close();
    }
  }

  CardModel _selectedCard;

  List<dynamic> _cardPanelList = List();

  List<dynamic> getPanelCards() {
    return _cardPanelList;
  }

  List<dynamic> getCardPanel(List<String> panelList) {
    _cardPanelList?.clear();
    int index = 0;
    panelList.forEach((item) {
      if (item != '') {
        _cardPanelList.add(CardModel(
            null,
            item,
            false,
            _getPanelCardPos(item, index),
            UserBloc().getCurrUser().color,
            false,
            false,
            false,
            false));
      } else {
        _cardPanelList.add('');
      }
      index++;
    });
    return _cardPanelList;
  }

  int getMissingCardsFromPanel() {
    return _cardPanelList
        .where((item) => item is String && item == '')
        .toList()
        .length;
  }

  replaceMissingPanelCard(List<dynamic> list) {
    if (null != list) {
      list.forEach((card) {
        int index =
            _cardPanelList.indexWhere((item) => item is String && item == '');
        if (index >= 0) {
          _cardPanelList[index] = CardModel(null, card, false,
              _getPanelCardPos(card, index), '', false, false, false, false);
        }
      });
      ResetGameModel resetGameModel =
          ResetGameModel(ResetGameModel.PANEL, _cardPanelList);
      GameController().addToResetGameController(resetGameModel);

      String strList = _cardPanelList
          .map((item) => (item is CardModel) ? item.value : '')
          .toList()
          .join(',');
      FirebaseRealtimeDB().setPanelCard(strList);
    }
  }

  removePanelCard() {
    int index = _cardPanelList.indexWhere(
        (item) => item is CardModel && item.value == _selectedCard.value);
    if (index >= 0) {
      _cardPanelList[index] = '';
      ResetGameModel resetGameModel =
          ResetGameModel(ResetGameModel.PANEL, _cardPanelList);
      GameController().addToResetGameController(resetGameModel);
    }
  }

  setSelectedCard(CardModel cardModel) {
    if (_selectedCard == null ||
        cardModel.position.compareTo(_selectedCard.position) != 0) {
      _selectedCard = cardModel;

      _cardPanelList.forEach((panelCard) {
        if (panelCard is CardModel &&
            panelCard.position != _selectedCard.position) {
          addToController(BlocModel(panelCard.position, BlocModel.PANEL_CARD,
              BlocModel.PANEL_CARD_UNSELECT, null));
        }
      });

      addToController(BlocModel(_selectedCard.value, BlocModel.BOARD_CARD,
          BlocModel.HIGHLIGHT_BOARD_CARD, null));
    }
  }

  clearSelectedCard() {
    _selectedCard = null;
  }

  CardModel getSelectedCard() {
    return _selectedCard;
  }

  String _getPanelCardPos(String val, int index) {
    return 'Panel-' + val + '-' + index.toString();
  }

  String getConcatenatedId(String id1, String id2) {
    if (id1.compareTo(id2) < 0) {
      return id1 + id2;
    } else {
      return id2 + id1;
    }
  }
}

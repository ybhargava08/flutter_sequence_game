import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sequence/blocs/GameBloc.dart';
import 'package:sequence/blocs/GameController.dart';
import 'package:sequence/cards/BaseCard.dart';
import 'package:sequence/model/BlocModel.dart';
import 'package:sequence/model/CardModel.dart';

class PanelCard extends StatefulWidget {
  final CardModel panelCardModel;

  PanelCard(Key key, this.panelCardModel) : super(key: key);
  @override
  State<StatefulWidget> createState() => _PanelCardState();
}

class _PanelCardState extends State<PanelCard> {
  CardModel _panelCardModel;

  double _translateY;

  StreamSubscription _subs;

  setTranslate(double translateY) {
    if (_translateY != translateY) {
      setState(() {
        _translateY = translateY;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _translateY = 0;
    _panelCardModel = widget.panelCardModel;
    if (null != GameBloc().getController()) {
      _subs = GameBloc()
          .getController()
          .stream
          .where((data) =>
              data.cardType == BlocModel.PANEL_CARD &&
              data.id != null &&
              data.id == _panelCardModel.position)
          .listen((data) {
        if (data.type == BlocModel.PANEL_CARD_UNSELECT) {
          setTranslate(0);
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _subs?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (GameController().isTapAllowed()) {
          setTranslate(-15);
          GameBloc().setSelectedCard(_panelCardModel);
        }else{
          GameController().showToast('Wait for your turn');
        }
      },
      child: Transform.translate(
        offset: Offset(0, _translateY),
        child: BaseCard(UniqueKey(),_panelCardModel),
      ),
    );
  }
}

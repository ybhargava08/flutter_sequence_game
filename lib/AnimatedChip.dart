import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sequence/GameChip.dart';
import 'package:sequence/blocs/AnimationBloc.dart';
import 'package:sequence/blocs/FirebaseDBListener.dart';
import 'package:sequence/blocs/GameBloc.dart';
import 'package:sequence/blocs/GameController.dart';
import 'package:sequence/model/BlocModel.dart';
import 'package:sequence/model/CardModel.dart';
import 'package:sequence/model/FirebaseDBModel.dart';
import 'package:sequence/model/UserModel.dart';

class AnimatedChip extends StatefulWidget {
  final UserModel user;

  AnimatedChip(this.user);

  @override
  State<StatefulWidget> createState() => _AnimatedChipState();
}

class _AnimatedChipState extends State<AnimatedChip>
    with TickerProviderStateMixin {
  Animation _posAnimation;
  Animation _sizeAnimation;
  AnimationController _controller;

  CardModel _lastCard;

  bool _showAnim = false;

  static const double _chipSize = 23;
  static const double _chipPadding = 5;

  double _opacity = 0.0;

  StreamSubscription _subs;

  @override
  void initState() {
    super.initState();
    if (null != FirebaseDBListener().getController()) {
      _subs = FirebaseDBListener()
          .getController()
          .stream
          .where((item) =>
              item.type == FirebaseDBModel.CARD &&
              item.data is CardModel &&
              item.data.from == widget.user.id)
          .listen((data) {
        CardModel model = data.data;

        if (model.isRemovedJ1) {
          GameBloc().addToController(BlocModel(model.position,
              BlocModel.BOARD_CARD, BlocModel.OTHER_PLAYER_CARD, model));
        } else {
          if (_lastCard == null || _lastCard.position != model.position && model.time > _lastCard.time) {
            _lastCard = model; 
            _doAnim(model);
          }
        }
      });
    }
  }

  Offset _calcEndPos(CardModel cardModel) {
    final GlobalKey cardKey = GameBloc().findGlobalKey(cardModel.position);
    final Offset posChip = AnimationBloc().getChipKey(widget.user.id);
    Offset posCard = _getPosition(cardKey, 'card');

    Size size = _getSize(cardKey);

    Offset endPos = Offset(
        (posCard.dx - posChip.dx + _chipPadding) / _chipSize,
        (posCard.dy - posChip.dy + (size.height - _chipSize - _chipPadding)) /
            23);

    return endPos;
  }

  Offset _getPosition(GlobalKey key, String type) {
    if (null != key && null != key.currentContext) {
      final RenderBox renderBox = key.currentContext.findRenderObject();
      Offset position = renderBox.localToGlobal(Offset.zero);
      return position;
    }
    return null;
  }

  Size _getSize(GlobalKey key) {
    if (null != key && null != key.currentContext) {
      final RenderBox renderBox = key.currentContext.findRenderObject();
      return renderBox.size;
    }
    return null;
  }

  _doAnim(CardModel cardModel) {
    GameController().setAnimRunning(true);
    Offset endPos = _calcEndPos(cardModel);
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _sizeAnimation = Tween(begin: 2.5, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.ease));
    _posAnimation = Tween(begin: Offset(0, 0), end: endPos).animate(
        CurvedAnimation(parent: _controller, curve: Curves.decelerate));
    _controller.forward();
    setState(() {
      _showAnim = true;
      _opacity = 1.0;
    });
    _controller.addListener(() {
      if (_controller.isCompleted) {
        GameBloc().addToController(BlocModel(cardModel.position,
            BlocModel.BOARD_CARD, BlocModel.OTHER_PLAYER_CARD, cardModel));
        setState(() {
          _showAnim = false;
          _opacity = 0.0;
        });
      }
      GameController().setAnimRunning(false);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subs?.cancel();
    _lastCard = null;
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _opacity,
      child: (_showAnim && _posAnimation != null && _sizeAnimation != null)
          ? ScaleTransition(
              scale: _sizeAnimation,
              child: SlideTransition(
                position: _posAnimation,
                child: GameChip(widget.user.color, widget.user.id, false),
              ),
            )
          : GameChip(widget.user.color, widget.user.id, true),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sequence/GameChip.dart';
import 'package:sequence/blocs/AnimationBloc.dart';
import 'package:sequence/blocs/CheckSequenceBloc.dart';
import 'package:sequence/blocs/GameBloc.dart';
import 'package:sequence/blocs/GameController.dart';
import 'package:sequence/blocs/SystemControl.dart';
import 'package:sequence/blocs/UserBloc.dart';
import 'package:sequence/cards/CardStructure.dart';
import 'package:sequence/firebasedb/FirebaseRealtimeDB.dart';
import 'package:sequence/firebasedb/FirestoreDB.dart';
import 'package:sequence/model/BlocModel.dart';
import 'package:sequence/model/CardModel.dart';

class BoardCard extends StatefulWidget {
  final CardModel cardModel;

  BoardCard(Key key, this.cardModel) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BoardCardState();
}

class _BoardCardState extends State<BoardCard>
    with SingleTickerProviderStateMixin {
  CardModel _boardCardModel;

  bool _isHighlighted = false;

  bool _seqCompletedAnim = false;

  bool _seqProgressAnim = false;

  static final Color _highlightColor = Colors.amberAccent;

  GlobalKey _globalKey = GlobalKey();

  StreamSubscription _subs;

  AnimationController _animationController;

  Animation _j1RemoveAnim;

  setInitBoardState() {
    FirestoreDB().getInitBoardCard(_boardCardModel.position).then((data) {
      if (null != data && this.mounted) {
        setState(() {
          _boardCardModel = data;
        });
        _seqCompletedAnim = data.isPartOfSeq;
        GameBloc().setCardInIndexMap(_boardCardModel.position, data);
      }
    });
  }

  _initAnim() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 550));
    _j1RemoveAnim = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOutQuad));
    _animationController.addListener(() {
      if (_animationController.isCompleted) {
        _animationController.reverse();
      }
    });
  }

  _doJ1Anim() {
    if (null != _animationController && null != _j1RemoveAnim) {
      SystemControl().doVibrate(400);
      _animationController.forward();
    }
  }

  @override
  void initState() {
    super.initState();
    _boardCardModel = widget.cardModel;

    setInitBoardState();
    _initAnim();
    GameBloc().setGlobalKey(_boardCardModel.position, _globalKey);

    if (null != GameBloc().getController()) {
      _subs = GameBloc()
          .getController()
          .stream
          .where((item) => item.cardType == BlocModel.BOARD_CARD)
          .listen((data) {
        if (data.type == BlocModel.HIGHLIGHT_BOARD_CARD) {
          if (null != data.id &&
              data.id == _boardCardModel.value &&
              !_boardCardModel.isChipPlaced) {
            if (!_isHighlighted) {
              setState(() {
                _isHighlighted = true;
              });
            }
          } else {
            setState(() {
              _isHighlighted = false;
            });
          }
        } else if (data.type == BlocModel.SEQ_START_ANIM &&
            data.id == _boardCardModel.position) {
          doSequenceAnimationTask(false);
        } else if (data.type == BlocModel.SEQ_COMPLETED_ANIM &&
            _seqProgressAnim) {
          doSequenceAnimationTask(true);
        } else if (data.type == BlocModel.OTHER_PLAYER_CARD &&
            data.id == _boardCardModel.position &&
            data.value is CardModel) {
          _placedCardOnBoard(data.value, !data.value.isRemovedJ1,
              data.value.isRemovedJ1, false);
        }
      });
    }
  }

  doSequenceAnimationTask(bool isAnimCompleted) {
    if (isAnimCompleted) {
      setState(() {
        _isHighlighted = false;
        _seqProgressAnim = false;
        _seqCompletedAnim = true;
      });
    } else {
      setState(() {
        _isHighlighted = false;
        _seqProgressAnim = true;
        _seqCompletedAnim = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _subs?.cancel();
    _animationController?.dispose();
  }

  _doChangesForSelectedCard() {
    GameBloc().removePanelCard();
    GameBloc().clearSelectedCard();
  }

  _sendCard(bool isCardAdd, bool isJ2) async {
    CardModel newModel = _boardCardModel.fromModel();
    newModel.color = UserBloc().getCurrUser().color;
    newModel.isChipPlaced = isCardAdd;
    newModel.isRemovedJ1 = !isCardAdd;
    newModel.isJ2 = isJ2;
    newModel.from = UserBloc().getCurrUser().id;

    _doChangesForSelectedCard();
    FirebaseRealtimeDB()
        .getCardsAndSetDeck(GameController().getRoomDetails().id, 1, false)
        .then((data) {
      GameBloc().replaceMissingPanelCard(data);
    });
    FirestoreDB().setBoardCard(newModel, !isCardAdd);

    _placedCardOnBoard(newModel, isCardAdd, false, true);
  }

  _placedCardOnBoard(CardModel model, bool checkForSeqCompletion, bool doJ1Anim,
      bool updateFirebase) async {
    GameBloc().addToController(BlocModel(
        null, BlocModel.BOARD_CARD, BlocModel.HIGHLIGHT_BOARD_CARD, null));
    GameBloc().setCardInIndexMap(_boardCardModel.position, model);
    setState(() {
      _boardCardModel = model;
    });
    if (checkForSeqCompletion) {
      CheckSequenceBloc().checkForSequence(model, updateFirebase);
    }
    if (doJ1Anim && !checkForSeqCompletion) {
      _doJ1Anim();
    }
    if (!updateFirebase) {
      String playerId = (model.from == UserBloc().getCurrUser().id)
          ? GameController().getOtherPlayerDetails().id
          : UserBloc().getCurrUser().id;
      FirebaseRealtimeDB()
          .setPlayerTurn(playerId, GameController().getRoomDetails().id);
    }
  }

  Color _getBlendColor() {
    if (_isHighlighted) {
      return _highlightColor;
    } else if (_seqProgressAnim) {
      return AnimationBloc()
          .getColor(AnimationBloc.ANIM_PROGRESS_COLOR, _boardCardModel.color);
    } else if (_seqCompletedAnim) {
      return AnimationBloc()
          .getColor(AnimationBloc.ANIM_END_COLOR, _boardCardModel.color);
    }
    return Colors.transparent;
  }

  Color _getBgColor() {
    if (_isHighlighted) {
      return _highlightColor;
    } else if (_seqProgressAnim) {
      return AnimationBloc()
          .getColor(AnimationBloc.ANIM_PROGRESS_COLOR, _boardCardModel.color);
    } else if (_seqCompletedAnim) {
      return AnimationBloc()
          .getColor(AnimationBloc.ANIM_END_COLOR, _boardCardModel.color);
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (GameController().isTapAllowed()) {
          if (null != GameBloc().getSelectedCard()) {
            if (!_boardCardModel.isChipPlaced &&
                (GameBloc().getSelectedCard().value == 'J2' ||
                    _boardCardModel.value ==
                        GameBloc().getSelectedCard().value)) {
              _sendCard(true, GameBloc().getSelectedCard().value == 'J2');
            } else if (GameBloc().getSelectedCard().value == 'J1' &&
                _boardCardModel.isChipPlaced &&
                !_boardCardModel.isPartOfSeq) {
              _sendCard(false, false);
            } else {
              GameController().showToast('Invalid selection');
            }
          } else {
            GameController().showToast('Select a card');
          }
        } else {
          GameController().showToast('Wait for your turn');
        }
      },
      child: ScaleTransition(
        scale: _j1RemoveAnim,
        child: Stack(
          children: <Widget>[
            SizedBox.expand(
                child: Container(
              key: _globalKey,
              margin: EdgeInsets.fromLTRB(1, 1, 0, 0),
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: _getBgColor(),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black, width: 1)),
              child: CardStructure(AnimationBloc.CARD_VAL_IMG, _boardCardModel,
                  _getBlendColor(), BlendMode.darken),
            )),
            (_boardCardModel != null &&
                    _boardCardModel.isOnBoard &&
                    _boardCardModel.isChipPlaced &&
                    !_seqProgressAnim)
                ? Positioned(
                    left: 5,
                    bottom: 5,
                    child: GameChip(
                        _boardCardModel.color, _boardCardModel.from, false))
                : Container(
                    width: 0,
                    height: 0,
                  )
          ],
        ),
      ),
    );
  }
}

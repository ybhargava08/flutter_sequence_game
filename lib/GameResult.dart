import 'package:flutter/material.dart';
import 'package:sequence/GameScore.dart';
import 'package:sequence/blocs/AnimationBloc.dart';
import 'package:sequence/blocs/GameController.dart';
import 'package:sequence/blocs/SystemControl.dart';
import 'package:sequence/constants/GameConstants.dart';
import 'package:sequence/model/RoomModel.dart';

class GameResult extends StatefulWidget {
  final RoomModel roomModel;

  GameResult(this.roomModel);

  @override
  State<StatefulWidget> createState() => _GameResultState();
}

class _GameResultState extends State<GameResult>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  Animation _sizeAnim;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 900));
    _sizeAnim = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (null != widget.roomModel && isGameWon()) {
        SystemControl().playSound('sound/game_winning.mp3');
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _getImage() {
    return (widget.roomModel.winnerPhotoUrl != null &&
            widget.roomModel.winnerPhotoUrl.startsWith('http'))
        ? Container(
            width: 80,
            height: 80,
            margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(widget.roomModel.winnerPhotoUrl),
                )),
          )
        : Container(
            width: 0,
            height: 0,
          );
  }

  Widget _getWinGif() {
    return ScaleTransition(
      scale: _sizeAnim,
      child: Container(
        width: 400,
        height: 300,
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
        child: AnimationBloc().getAssetImage('assets/images/Winner.png'),
      ),
    );
  }

  bool isGameWon() {
    return widget.roomModel.status == RoomModel.GAME_WON;
  }

  @override
  Widget build(BuildContext context) {
    return (widget.roomModel.status == RoomModel.GAME_WON ||
            widget.roomModel.status == RoomModel.GAME_DRAW)
        ? Positioned(
            top: 0,
            left: 0,
            child: GestureDetector(
              onTap: () {
                GameController().popScreen(context, GameConstants.REMOVE_GAME);
              },
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.black.withOpacity(0.9),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      isGameWon()
                          ? _getWinGif()
                          : Text(
                              'Game Drawn',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 70,
                                  fontWeight: FontWeight.bold),
                            ),
                      isGameWon()
                          ? _getImage()
                          : Container(
                              width: 0,
                              height: 0,
                            ),
                      isGameWon()
                          ? Text(
                              widget.roomModel.winner != null
                                  ? widget.roomModel.winner
                                  : '',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold))
                          : Container(
                              width: 0,
                              height: 0,
                            ),
                      GameScore()
                    ],
                  )),
            ),
          )
        : Container(
            width: 0,
            height: 0,
          );
  }
}

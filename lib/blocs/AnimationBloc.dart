import 'package:flutter/material.dart';
import 'package:sequence/model/CardModel.dart';

class AnimationBloc {
  Map<String, Color> _chipColorMap = Map();
  Map<String, Color> _animationProgressColor = Map();
  Map<String, Color> _animationEndColor = Map();

  Map<String, Offset> _chipKey = Map();

  static const String CHIP_COLOR = 'chipClr';
  static const String ANIM_PROGRESS_COLOR = 'progressClr';
  static const String ANIM_END_COLOR = 'endClr';

  static const String CARD_VAL_IMG = 'cvi';
  static const String BLANK_CARD_IMG = 'bci';
  static const String WINNER_IMG = 'wi';
  static const String CHIP_STAR_IMG = 'csi';

  static AnimationBloc _animationBloc;

  factory AnimationBloc() => _animationBloc ??= AnimationBloc._();

  AnimationBloc._() {
    _chipColorMap['red'] = Colors.red[900];
    _animationProgressColor['red'] = Colors.red[200];
    _animationEndColor['red'] = Colors.red[100];
    _chipColorMap['teal'] = Colors.teal[900];
    _animationProgressColor['teal'] = Colors.teal[200];
    _animationEndColor['teal'] = Colors.teal[100];
  }

  Color getColor(String type, String color) {
    if (type == ANIM_PROGRESS_COLOR) {
      return _animationProgressColor[color];
    } else if (type == ANIM_END_COLOR) {
      return _animationEndColor[color];
    }
    return _chipColorMap[color];
  }

  setChipKey(String key, Offset value) {
    _chipKey[key] = value;
  }

  Offset getChipKey(String key) {
    return _chipKey[key];
  }

  Widget getSimpleAssetImage(
      Color blendColor, BlendMode blendMode, CardModel card, String imgType) {
    if (imgType == CARD_VAL_IMG && null != card && _isNotEmpty(card.value)) {
      if (card.value == 'wild') {
        return getAssetImage(blendColor, blendMode, card, imgType);
      } else {
        String cardLetter = card.value.substring(0, card.value.length - 1);

        String suite = card.value[card.value.length - 1];
        Color col = (suite == 'D' || suite == 'H') ? Colors.red : Colors.black;
        return Container(
          color: blendColor,
          child: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                flex: 4,
                child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      cardLetter,
                      style: TextStyle(
                          color: col,
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                    )),
              ),
              Flexible(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.fromLTRB(17, 0, 0, 2),
                  width: 20,
                  height: 20,
                  alignment: Alignment.bottomRight,
                  child: _getImg('assets/suites/' + suite + '.png', null, null),
                ),
              ),
            ],
          ),
        );
      }
    }
    return Container(
      width: 0,
      height: 0,
    );
  }

  Widget getAssetImage(
      Color blendColor, BlendMode blendMode, CardModel card, String imgType) {
    String location;
    if (imgType == CARD_VAL_IMG && null != card && _isNotEmpty(card.value)) {
      location = 'assets/cards/' + card.value + '.png';
    } else if (imgType == BLANK_CARD_IMG) {
      location = 'assets/cards/purple_back.png';
    } else if (imgType == CHIP_STAR_IMG) {
      location = 'assets/chips/white-star.png';
    } else if (imgType == WINNER_IMG) {
      location = 'assets/images/Winner.png';
    }
    if (_isNotEmpty(location)) {
      return _getImg(location, blendColor, blendMode);
    }

    return Container(
      width: 0,
      height: 0,
    );
  }

  Widget _getImg(String location, Color blendColor, BlendMode blendMode) {
    if (null != blendColor && null != blendMode) {
      return Image.asset(
        location,
        color: blendColor,
        colorBlendMode: blendMode,
      );
    }
    return Image.asset(
      location,
    );
  }

  bool _isNotEmpty(String s) {
    return s != null && s.trim().length > 0;
  }
}

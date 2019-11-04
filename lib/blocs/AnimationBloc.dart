import 'package:flutter/material.dart';

class AnimationBloc {
  Map<String, Color> _chipColorMap = Map();
  Map<String, Color> _animationProgressColor = Map();
  Map<String, Color> _animationEndColor = Map();

  Map<String, Offset> _chipKey = Map();

  static const String CHIP_COLOR = 'chipClr';
  static const String ANIM_PROGRESS_COLOR = 'progressClr';
  static const String ANIM_END_COLOR = 'endClr';

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

  Widget getAssetImage(String location) {
       /*return Image.network('https://lh3.googleusercontent.com/a-/AAuE7mDK-hzjK6k1V5uBph6sIxbmSdvsQfmt8TqUpZnNzQ=s96-c'
       ,fit: BoxFit.contain,);*/
       return Image.asset(location,fit: BoxFit.contain,);
  } 

}

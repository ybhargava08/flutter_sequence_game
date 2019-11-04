import 'package:flutter/material.dart';
import 'package:sequence/blocs/AnimationBloc.dart';

class BlankCard extends StatelessWidget {

  BlankCard(Key key):super(key:key);
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
          child: Container(
            margin: EdgeInsets.fromLTRB(1, 1, 0, 0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.black, width: 1)),
            child:AnimationBloc().getAssetImage('assets/cards/purple_back.png'), 
          ),
        );
  }

}
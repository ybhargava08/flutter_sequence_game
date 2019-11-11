import 'package:flutter/material.dart';
import 'package:sequence/blocs/AnimationBloc.dart';
import 'package:sequence/cards/CardStructure.dart';
import 'package:sequence/model/CardModel.dart';

class BaseCard extends StatelessWidget {
 
  final CardModel cardModel;

  final Key key;

   BaseCard(this.key,this.cardModel):super(key:key);

  @override
  Widget build(BuildContext context) {
    return (cardModel ==  null)?Container(width: 0,height: 0,)
    :SizedBox.expand(
       child: Container(
            margin: EdgeInsets.fromLTRB(1, 1, 0, 0),
            decoration: BoxDecoration(
                color: (cardModel.value == 'J1')?Colors.red[50]:(cardModel.value == 'J2')?Colors.grey[300]:Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.black, width: 1)),
            child: (cardModel.value == 'J1')
                ? Center(
                    child: Text(
                    'J1',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ))
                : (cardModel.value == 'J2')
                    ? Center(
                        child: Text(
                        'J2',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                       ))
                    : CardStructure(AnimationBloc.CARD_VAL_IMG, cardModel,
                  null, null),
          ),
    );
  }

}
import 'package:flutter/material.dart';
import 'package:sequence/blocs/AnimationBloc.dart';
import 'package:sequence/blocs/CardBloc.dart';
import 'package:sequence/model/CardModel.dart';

class CardStructure extends StatelessWidget {

  final Color color;
  final BlendMode blendMode;
  final CardModel cardModel;
  final String imgType;

  CardStructure(this.imgType,this.cardModel,this.color,this.blendMode);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
         initialData: CardBloc().getCardType(),
         stream: CardBloc().getController().stream,
         builder: (BuildContext context,AsyncSnapshot<String> snap) {
               if(snap.hasData && null!=cardModel && AnimationBloc.CARD_VAL_IMG == imgType) {
                    if(snap.data == CardBloc.TEXT_CARD) {
                        return AnimationBloc().getSimpleAssetImage(color, blendMode, cardModel, imgType);
                    }else if(snap.data == CardBloc.PHOTO_CARD) {
                        return AnimationBloc().getAssetImage(color, blendMode, cardModel, imgType);
                    }
               }
               return  AnimationBloc().getAssetImage(color, blendMode, cardModel, imgType);;
               
         },
    );
  }

}
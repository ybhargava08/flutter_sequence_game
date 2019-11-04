import 'package:cloud_firestore/cloud_firestore.dart';

class CardModel {

  String from = '';
  String color;
  String value = '';
  String position = '';
  bool isPartOfSeq = false;
  bool isOnBoard = false;
  bool isChipPlaced = false;
  int time = DateTime.now().millisecondsSinceEpoch;
  bool isRemovedJ1 = false;
  bool isJ2 = false;

  CardModel(this.from,this.value,this.isOnBoard,this.position,this.color,this.isChipPlaced,this.isPartOfSeq,this.isRemovedJ1,
  this.isJ2);

  factory CardModel.fromJson(Map<dynamic,dynamic> map) {
      return CardModel(map['from'],map['value'], map['isOnBoard'], map['position'], map['color'], 
      map['isChipPlaced'], map['isPartOfSeq'],map['isRemovedJ1'],map['isJ2']);
  } 

  factory CardModel.fromDocumentSnapshot(DocumentSnapshot map) {
      return CardModel(map['from'],map['value'], map['isOnBoard'], map['position'], map['color'], 
      map['isChipPlaced'], map['isPartOfSeq'],map['isRemovedJ1'],map['isJ2']);
  } 

   CardModel fromModel() {
       return CardModel(from,value,isOnBoard,position,color,isChipPlaced,isPartOfSeq,isRemovedJ1,isJ2);
  }

  bool operator ==(dynamic other) {
      return other.value == value && other.position == position && other.isChipPlaced == isChipPlaced 
      && other.isPartOfSeq== isPartOfSeq;
  }

  @override
  String toString() {
    return 'value '+value+
    ' seq '+isPartOfSeq.toString()+' onBaord '+isOnBoard.toString()+' isChip placed '+isChipPlaced.toString()
    +' pos '+position;
  }

  Map<String,dynamic> toJson() {
           Map<String,dynamic> map = Map();
           map['from'] = from;
           map['color'] = color;
           map['value'] = value;
           map['position'] = position;
           map['isPartOfSeq'] = isPartOfSeq;
           map['isOnBoard'] = isOnBoard;
           map['isChipPlaced'] = isChipPlaced;
           map['time'] = time;
           map['isRemovedJ1'] = isRemovedJ1;
           map['isJ2'] = isJ2;
           return map;
     }


}
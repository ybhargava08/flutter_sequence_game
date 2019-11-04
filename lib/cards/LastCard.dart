import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sequence/blocs/FirebaseDBListener.dart';
import 'package:sequence/blocs/GameController.dart';
import 'package:sequence/cards/BaseCard.dart';
import 'package:sequence/constants/GameConstants.dart';
import 'package:sequence/firebasedb/FirestoreDB.dart';
import 'package:sequence/model/CardModel.dart';
import 'package:sequence/model/FirebaseDBModel.dart';
import 'dart:math' as math;

class LastCard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LastCardState();
}

class _LastCardState extends State<LastCard> {
  CardModel _card;

  StreamSubscription _lastCardSubs;

  @override
  void initState() {
    FirestoreDB()
        .getBoardCardRef(null)
        .where('from', isEqualTo: GameController().getOtherPlayerDetails().id)
        .orderBy('time', descending: true)
        .limit(1)
        .getDocuments()
        .then((data) {
      if (data != null && data.documents.length > 0) {
        DocumentSnapshot snap = data.documents[0];
        if (snap != null) {
          CardModel model = CardModel.fromDocumentSnapshot(snap);
          setStateCard(model);
        }
      }
    });

    _lastCardSubs = FirebaseDBListener()
        .getController()
        .stream
        .where((item) =>
            item.type == FirebaseDBModel.CARD && item.data is CardModel)
        .listen((data) {
      setStateCard(data.data);
    });

    super.initState();
  }

  setStateCard(CardModel model) {
    if (this.mounted) {
      CardModel newModel = model.fromModel();
      newModel.value = (newModel.isRemovedJ1)
          ? 'J1'
          : (newModel.isJ2) ? 'J2' : newModel.value;
      setState(() {
        _card = newModel;
      });
    }
  }

  @override
  void dispose() {
    print('last card dispose called');
    _lastCardSubs?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (null != _card)
        ? Transform.rotate(
            angle: math.pi / 9,
            child: Container(
              width: 1.1 *
                  GameConstants.CARD_WIDTH_FACTOR *
                  MediaQuery.of(context).size.width,
              height: 1.1 *
                  GameConstants.CARD_HEIGHT_FACTOR *
                  MediaQuery.of(context).size.height,
              child: BaseCard(UniqueKey(), _card),
            ),
          )
        : Container(
            width: 0,
            height: 0,
          );
  }
}

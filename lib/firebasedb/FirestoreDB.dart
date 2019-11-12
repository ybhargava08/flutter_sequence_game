import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sequence/blocs/GameController.dart';
import 'package:sequence/blocs/UserBloc.dart';
import 'package:sequence/firebasedb/DBConstants.dart';
import 'package:sequence/model/CardModel.dart';

class FirestoreDB {

    static FirestoreDB _firestoreDB;

    static Firestore _firestore = Firestore.instance;

    factory FirestoreDB() => _firestoreDB??FirestoreDB._internal();

    FirestoreDB._internal() {
          _firestore.settings(persistenceEnabled: false);
    }

    DocumentReference _getRoomRef(String roomId) {
        return _firestore.collection(DBConstants.ROOM).document(roomId);
    }

   CollectionReference getBoardCardRef(String roomId) {
        roomId = (null == roomId)?GameController().getRoomDetails().id:roomId;
        return _getRoomRef(roomId).collection(DBConstants.BOARD_CARD);
    }

    Future setBoardCardFirestore(CardModel card,bool merge) async {
        await getBoardCardRef(null).document(UserBloc().getCurrUser().id).setData(card.toJson(),merge: merge);
    }

   /* Future<CardModel> getInitBoardCard(String position) async {
         DocumentSnapshot snap = await getBoardCardRef(null).document(position).get();
         if(snap !=null && snap.data!=null) {
               return CardModel.fromDocumentSnapshot(snap);
         }
       return null;    
    }*/

    Future removeAllBoardCardsFirestore(String roomId) async {
        QuerySnapshot querySnapshot =  await getBoardCardRef(roomId).getDocuments();
        if(null!=querySnapshot) {
             querySnapshot.documents.forEach((doc)async{
                     await doc.reference.delete();
         });
        }
         await _getRoomRef(roomId).delete();
    } 
}
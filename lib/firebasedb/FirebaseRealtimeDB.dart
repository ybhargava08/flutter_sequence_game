import 'package:firebase_database/firebase_database.dart';
import 'package:sequence/blocs/GameBloc.dart';
import 'package:sequence/blocs/GameController.dart';
import 'package:sequence/blocs/UserBloc.dart';
import 'package:sequence/constants/GameConstants.dart';
import 'package:sequence/firebasedb/DBConstants.dart';
import 'package:sequence/model/RoomModel.dart';
import 'package:sequence/model/UserModel.dart';

class FirebaseRealtimeDB {
  static FirebaseRealtimeDB _firebaseRealtimeDB;


  static FirebaseDatabase _database = FirebaseDatabase.instance;
  factory FirebaseRealtimeDB() =>
      _firebaseRealtimeDB ??= FirebaseRealtimeDB._();

  FirebaseRealtimeDB._() {
    _database.setPersistenceEnabled(false);
  }

  DatabaseReference getRoomRef(String roomId) {
    return _database.reference().child(DBConstants.GAMES).child(roomId);
  }

  DatabaseReference getAllRoomsRef() {
    return _database.reference().child(DBConstants.GAMES).child(DBConstants.ROOM);
  }

  DatabaseReference getRoomUsersRef(String roomId) {
    return _database.reference().child(DBConstants.GAMES).child(roomId).child(DBConstants.USERS);
  }

  DatabaseReference getPanelCardRef(String roomId) {
    return getRoomRef(roomId)
        .child(DBConstants.PANEL_CARD)
        .child(UserBloc().getCurrUser().id);
  }

  DatabaseReference getPlayerTurnRef(String roomId) {
    return getRoomRef(roomId).child(DBConstants.TURN);
  }

  DatabaseReference getDeckRef(String roomId) {
    return getRoomRef(roomId).child(DBConstants.DECK);
  }

  DatabaseReference getGameColorRef(String roomId) {
    return getRoomRef(roomId).child(DBConstants.COLOR);
  }

  DatabaseReference getSeqCountRef() {
       return getRoomRef(GameController().getRoomDetails().id).child(DBConstants.SEQ_COUNT);
  }

  DatabaseReference getScoreRef(String child) {
       return _database.reference().child(DBConstants.SCORE).child(child);
  }

  setPanelCard(String panelCards) async {
    await getPanelCardRef(GameController().getRoomDetails().id)
        .set({'cards': panelCards});
  }

  setGameRoomUser(UserModel user, roomId) async {
    await getRoomUsersRef(roomId).child(user.id).set(user.toJson());
  }

  setGameRoom(RoomModel roomModel) async {
    await getAllRoomsRef().child(roomModel.id).set(roomModel.toJson());
  }

  setGameSeqCount(String userId,int seqCount) async {
       await getSeqCountRef().child(userId).set({'count':seqCount});
  }

  setPlayerTurn(String id, String roomId) async {
    await getPlayerTurnRef(roomId).set({'id': id});
  }

  setScoreCard(String id) async {
      await FirebaseRealtimeDB().getScoreRef(GameBloc().getConcatenatedId(UserBloc().getCurrUser().id, 
            GameController().getOtherPlayerDetails().id)).child(id)
            .runTransaction((MutableData data) async {
                data.value??=0;
                data.value = data.value+1;
                return data;
            });
  }

  Future<List<String>> getCardsAndSetDeck(String roomId, int cards,bool isInit) async {
    List<String> result;
    await getDeckRef(roomId).runTransaction((MutableData data) async {
      List<String> list;

      if (isInit && (data.value == null || '' == data.value)) {
        list = List.from(GameConstants.GAME_DECK);
        list.shuffle();
       /* list = List.generate(108, (i) {
          /* if(i%2==0) {
               return 'J2';
           }else{
             return 'J1';
           }*/
           return 'J2';
        });*/
      } else {
        list = (data.value!=null && data.value.length > 0)? data.value.split(','):list;
      }
      if (list != null && list.length >= cards) {
        result = list.getRange(0, cards).toList();
        list.removeRange(0, cards);
        data.value = list.join(',');
      }
      return data;
    });
    return result;
  }

  Future<String> getAndSetGameColor(String roomId) async {
    String color;
    await getGameColorRef(roomId).runTransaction((MutableData data) async {
      List<String> list;
      if (data.value == null || '' == data.value) {
        list = List.from(GameConstants.PLAYER_COLOR);
      } else {
        list = data.value.split(',');
      }
      color = (GameController().getRoomDetails().cBy == UserBloc().getCurrUser().id)?list[0]:list[1];
      return data;
    });
    return color;
  }

  Future<List<String>> getInitPanelCards(String roomId) async {
    DataSnapshot data = await getPanelCardRef(roomId).once();
    if (null != data && data.value != null && '' != data.value) {
      return data.value['cards'].split(',');
    }

    List<String> result = await getCardsAndSetDeck(roomId, 5,true);
    setPanelCard(result.join(','));

    return result;
  }

  Future<UserModel> getInitGameUser(String roomId) async {
    DataSnapshot data =
        await getRoomUsersRef(roomId).child(UserBloc().getCurrUser().id).once();
    if (null != data && data.value != null && '' != data.value) {
      return UserModel.fromJson(data.value);
    }
    String color = await getAndSetGameColor(roomId);
    UserBloc().getCurrUser().color = color;
    setGameRoomUser(UserBloc().getCurrUser(), roomId);
    return UserBloc().getCurrUser();
  }

  Future<String> getInitGameTurn(String roomId) async {
    DataSnapshot data = await getPlayerTurnRef(roomId).once();
    if (null != data && data.value != null && '' != data.value) {
      return data.value['id'];
    }
    setPlayerTurn(GameController().getRoomDetails().cBy, roomId);
    return GameController().getRoomDetails().cBy;
  }

  Future<int> getInitSeqCount(String id) async {
     DataSnapshot data = await getSeqCountRef().child(id).once();
     if (null != data && data.value != null && '' != data.value) {
            return data.value['count'];
     }
     return null;
  }

  Future removeGame(String roomId) async {
    await getRoomRef(roomId).remove();
    await getAllRoomsRef().child(roomId).remove();
  }

  Future removeUser(String roomId,String userId) async {
       await getRoomUsersRef(roomId).child(userId).remove();
  }
}

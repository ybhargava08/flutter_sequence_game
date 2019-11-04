class RoomModel {

    static const String YET_TO_START = 'YTS';
    static const String IN_PROGRESS = 'IP';
    static const String ON_HOLD = 'OH';
    static const String GAME_WON = 'WON';
    static const String GAME_DRAW = 'DRAW';

     String id;
     String name;
     String cBy;
     String status;
     String winner;
     String winnerPhotoUrl;

     RoomModel(this.id,this.name,this.cBy,this.status,this.winner,this.winnerPhotoUrl);

     factory RoomModel.fromJson(Map<dynamic,dynamic> map) {
          return RoomModel(map['id'],map['name'],map['cBy'],map['status'],map['winner'],map['winnerPhotoUrl']);
     } 

     Map<String,String> toJson() {
          Map<String,String> map = Map();
          map['id'] = id;
          map['name'] = name;
          map['cBy'] = cBy;
          map['status'] = status;
          map['winner'] = winner;
          map['winnerPhotoUrl'] = winnerPhotoUrl;
          return map;
     }

     @override
  String toString() {
    return 'id '+id+' name '+name;
  } 
}
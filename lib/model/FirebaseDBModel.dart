class FirebaseDBModel{

    static const String CARD = 'card';
    static const String USER_ADD = 'userAdd';
    static const String ROOM = 'room';
    static const String USER_LEFT = 'userLeft';
    static const String PLAYER_TURN = 'pturn';
    static const String ROOM_DETAILS = 'roomDetails';

    String type;

    dynamic data;

    FirebaseDBModel(this.type,this.data);
}
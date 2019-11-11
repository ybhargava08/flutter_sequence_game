import 'package:flutter/material.dart';
import 'package:sequence/CustomAppBar.dart';
import 'package:sequence/blocs/CardBloc.dart';
import 'package:sequence/blocs/FirebaseDBListener.dart';
import 'package:sequence/blocs/GameBloc.dart';
import 'package:sequence/blocs/GameController.dart';
import 'package:sequence/blocs/SystemControl.dart';
import 'package:sequence/blocs/UserBloc.dart';
import 'package:sequence/constants/GameConstants.dart';
import 'package:sequence/firebasedb/FirebaseRealtimeDB.dart';
import 'package:sequence/model/FirebaseDBModel.dart';
import 'package:sequence/model/RoomModel.dart';
import 'package:sequence/room/RoomDetails.dart';

class RoomScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  TextEditingController _textEditingController = TextEditingController();

  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _showLoader = false;

  @override
  void initState() {
    super.initState();
    FirebaseDBListener().listenForAllRooms();
    GameController().setOtherPlayerDetails(null);
    SystemControl().alwaysScreenLit();
    CardBloc().openController();
  }

  @override
  void dispose() {
    FirebaseDBListener().closeAllSubs();
    GameBloc().closeController();
    GameController().closeResetGameController();
    CardBloc().closeController();
    _textEditingController?.dispose();
    super.dispose();
  }

  _doCreateGame() async {
    if (_textEditingController.text != null &&
        _textEditingController.text.length > 0) {
      setState(() {
        _showLoader = true;
      });
      String room = 'room-' + DateTime.now().millisecondsSinceEpoch.toString();
      RoomModel roomModel = RoomModel(room, _textEditingController.text,
          UserBloc().getCurrUser().id, RoomModel.YET_TO_START, null, null);
      await FirebaseRealtimeDB().setGameRoom(roomModel);
      navigatetoPlayerScreen(roomModel);
    }
  }

  navigatetoPlayerScreen(RoomModel roomModel) async {
    await GameController().navigateToPlayerScreen(roomModel, context);
    if (this.mounted) {
      setState(() {
        _showLoader = false;
      });
    }
  }

  Widget _roomList() {
    return StreamBuilder(
      stream: FirebaseDBListener()
          .getController()
          .stream
          .where((item) => item.type == FirebaseDBModel.ROOM),
      initialData: FirebaseDBListener().getRoomList(),
      builder: (BuildContext context, AsyncSnapshot snap) {
        if (snap.hasData && snap.data != null) {
          List<RoomModel> list;
          if (snap.data is FirebaseDBModel) {
            list = snap.data.data;
          } else if (snap.data is List) {
            list = snap.data;
          }
          return ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                  maxWidth: 0.9 * MediaQuery.of(context).size.width,
                  maxHeight: 0.7 * MediaQuery.of(context).size.height),
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return RoomDetails(list[index],_scaffoldKey);
                },
                itemCount: list.length,
              ));
        }
        return Container(
          width: 0,
          height: 0,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('Sequence',false),
      key: _scaffoldKey,
      backgroundColor: GameConstants.bgColor,
      body: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
            flex: 7,
            child: _roomList(),
          ),
          Flexible(
            flex: 1,
            child: SizedBox(
              width: 200,
              child: TextField(
                decoration: InputDecoration(
                    helperStyle: TextStyle(color: GameConstants.textColor),
                    enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: GameConstants.textColor))),
                cursorColor: GameConstants.textColor,
                controller: _textEditingController,
                style: TextStyle(fontSize: 20, color: GameConstants.textColor),
                maxLength: 15,
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: _showLoader
                ? CircularProgressIndicator()
                : RaisedButton(
                    elevation: 8,
                    color: Colors.green[700],
                    child: Text(
                      'Create Game',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      _doCreateGame();
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sequence/blocs/GameController.dart';
import 'package:sequence/blocs/SystemControl.dart';
import 'package:sequence/constants/GameConstants.dart';
import 'package:sequence/model/RoomModel.dart';

class RoomDetails extends StatelessWidget {
  final RoomModel roomModel;

  final GlobalKey<ScaffoldState> scaffoldKey;

  RoomDetails(this.roomModel,this.scaffoldKey);

  _doOnDismiss() async {
       SystemControl().doVibrate(300);
       await GameController().removeRoomDetails(roomModel.id);
       scaffoldKey.currentState.showSnackBar(SnackBar(content: Row(
           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
           children: <Widget>[
               Text(roomModel.name+' removed',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w500),),
               Icon(Icons.delete)
           ],
       )));
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
       key: UniqueKey(),
       direction: DismissDirection.horizontal,
       onDismissed: (direction) {
            _doOnDismiss();
       },
       child: GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10.0),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.green[700],
            boxShadow: [
              BoxShadow(
                  color: Colors.green[500],
                  blurRadius: 4,
                  offset: Offset(3.0, 3.0))
            ]),
        child: Center(
              child: Text(
                roomModel.name,
                style: TextStyle(
                    color: GameConstants.textColor,
                    fontSize: 25,
                    fontWeight: FontWeight.w500),
              ),
            ),
         
      ),
      onTap: () {
        GameController().navigateToPlayerScreen(roomModel, context);
      },
    ),
    )
    
    ;
  }
}

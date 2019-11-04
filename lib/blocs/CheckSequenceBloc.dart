import 'dart:async';

import 'package:sequence/blocs/GameBloc.dart';
import 'package:sequence/blocs/GameController.dart';
import 'package:sequence/blocs/SystemControl.dart';
import 'package:sequence/blocs/UserBloc.dart';
import 'package:sequence/firebasedb/FirebaseRealtimeDB.dart';
import 'package:sequence/firebasedb/FirestoreDB.dart';
import 'package:sequence/model/BlocModel.dart';
import 'package:sequence/model/CardModel.dart';
import 'package:sequence/model/RoomModel.dart';

class CheckSequenceBloc {
  static CheckSequenceBloc _checkSequenceBloc;

  factory CheckSequenceBloc() => _checkSequenceBloc ??= CheckSequenceBloc._();

  static const maxSequence = 2;

  Map<String, int> _sequenceCount = Map();
  CheckSequenceBloc._() {
    _sequenceCount[UserBloc().getCurrUser().id] = 0;
    _sequenceCount[GameController().getOtherPlayerDetails().id] = 0;
  }

  static const String VERT_TOP = 'vt';
  static const String VERT_BOTTOM = 'vb';
  static const String HORI_LEFT = 'hl';
  static const String HORI_RIGHT = 'hr';
  static const String TOP_LEFT = 'tl';
  static const String TOP_RIGHT = 'tr';
  static const String BOTTOM_LEFT = 'bl';
  static const String BOTTOM_RIGHT = 'br';

  static const int maxRows = 10;
  static const int maxCols = 10;
  static const int seqNumber = 5;

  static int existingSeqCardIncluded = 0;
  static int count = 0;

  List<String> seqTypes = [VERT_TOP,VERT_BOTTOM,HORI_LEFT,HORI_RIGHT,TOP_LEFT,BOTTOM_LEFT,TOP_RIGHT,BOTTOM_RIGHT];

  checkForSequence(CardModel card,bool updateFirestore) {
           int seqCount =0;
           for(String type in seqTypes) {
                seqCount = checkIfSequenceCompleted(card, updateFirestore, type, seqCount);
                if(seqCount >= maxSequence) {
                    break;
                }
           }
  }

  int checkIfSequenceCompleted(CardModel currCard, bool updateFirestore,String type,int count) {
    
    List<String> result = findSeq(currCard, type);

    if (result != null && result.length > 0) {
      SystemControl().playSound('sound/sequence_completed.mp3');
      SystemControl().doVibrate(2000);
      result.forEach((pos) {
        CardModel card = GameBloc().getCardFromMap(pos);
        card.isPartOfSeq = true;
        GameBloc().setCardInIndexMap(card.position, card);
        if (updateFirestore) {
          FirestoreDB().setBoardCard(card, false);
        }
      });
      getNextPosForSeq(result, 500).listen((data) {
        GameBloc().addToController(BlocModel(
            data, BlocModel.BOARD_CARD, BlocModel.SEQ_START_ANIM, null));
      }, onDone: () {
        GameBloc().addToController(BlocModel(
            null, BlocModel.BOARD_CARD, BlocModel.SEQ_COMPLETED_ANIM, null));
        _sequenceCount[currCard.from] = _sequenceCount[currCard.from] + 1;
        FirebaseRealtimeDB()
            .setGameSeqCount(currCard.from, _sequenceCount[currCard.from]);
        if (_sequenceCount[currCard.from] >= maxSequence) {
          if (updateFirestore) {
            GameController().getRoomDetails().status = RoomModel.GAME_WON;
            GameController().getRoomDetails().winner =
                (currCard.from == UserBloc().getCurrUser().id)
                    ? UserBloc().getCurrUser().name
                    : GameController().getOtherPlayerDetails().name;
            GameController().getRoomDetails().winnerPhotoUrl =
                (currCard.from == UserBloc().getCurrUser().id)
                    ? UserBloc().getCurrUser().photoUrl
                    : GameController().getOtherPlayerDetails().photoUrl;
            FirebaseRealtimeDB().setGameRoom(GameController().getRoomDetails());
            
            FirebaseRealtimeDB().setScoreCard(currCard.from);
          
          }
        }
      });
      return count+1;
    } else {
      print('seq not formed');
      return count;
    }
    
  }

  setInitSeqCount() async {
    int currUserCount =
        await FirebaseRealtimeDB().getInitSeqCount(UserBloc().getCurrUser().id);
    int otherUserCount = await FirebaseRealtimeDB()
        .getInitSeqCount(GameController().getOtherPlayerDetails().id);
    _sequenceCount[UserBloc().getCurrUser().id] = currUserCount ?? 0;
    _sequenceCount[GameController().getOtherPlayerDetails().id] =
        otherUserCount ?? 0;
  }

  getSequenceCountForId(String id) {
    return _sequenceCount[id];
  }

  Stream<String> getNextPosForSeq(List<String> result, int timeGap) async* {
    for (String pos in result) {
      yield pos;
      await Future.delayed(Duration(milliseconds: timeGap));
    }
  }

  List<String> findSeq(CardModel card, String type) {
    existingSeqCardIncluded = 0;
    String position = card.position;
    int startRow = int.parse(position.substring(0, 1));
    int startCol = int.parse(position.substring(1));

    int resultRow = startRow;
    int resultCol = startCol;

    if (type == VERT_TOP) {
      while (isValid(--startRow, startCol, card.color, card.from)) {
        resultCol = startCol;
        resultRow = startRow;
      }
    } else if (type == VERT_BOTTOM) {
      while (isValid(++startRow, startCol, card.color, card.from)) {
        resultCol = startCol;
        resultRow = startRow;
      }
    } else if (type == HORI_LEFT) {
      while (isValid(startRow, --startCol, card.color, card.from)) {
        resultCol = startCol;
        resultRow = startRow;
      }
    } else if (type == HORI_RIGHT) {
      while (isValid(startRow, ++startCol, card.color, card.from)) {
        resultCol = startCol;
        resultRow = startRow;
      }
    } else if (type == TOP_LEFT) {
      while (isValid(--startRow, --startCol, card.color, card.from)) {
        resultCol = startCol;
        resultRow = startRow;
      }
    } else if (type == BOTTOM_LEFT) {
      while (isValid(++startRow, --startCol, card.color, card.from)) {
        resultCol = startCol;
        resultRow = startRow;
      }
    } else if (type == TOP_RIGHT) {
      while (isValid(--startRow, ++startCol, card.color, card.from)) {
        resultCol = startCol;
        resultRow = startRow;
      }
    } else if (type == BOTTOM_RIGHT) {
      while (isValid(++startRow, ++startCol, card.color, card.from)) {
        resultCol = startCol;
        resultRow = startRow;
      }
    }
    return checkForSeq(resultRow, resultCol, card.color, card.from, type);
  }

  List<String> checkForSeq(
      int row, int col, String color, String from, String type) {
    existingSeqCardIncluded = 0;
    count = 0;
    List<String> list = List();
    int i = row;
    int j = col;
    if (type == VERT_TOP) {
      while (i < row + seqNumber) {
        list = addSeqToList(i, j, color, from, list);
        if (list == null) {
          return list;
        } else if (count == seqNumber) {
          break;
        }
        i++;
      }
    } else if (type == VERT_BOTTOM) {
      while (i > row - seqNumber) {
        list = addSeqToList(i, j, color, from, list);
        if (list == null) {
          return list;
        } else if (count == seqNumber) {
          break;
        }
        i--;
      }
    } else if (type == HORI_LEFT) {
      while (j < col + seqNumber) {
        list = addSeqToList(i, j, color, from, list);
        if (list == null) {
          return list;
        } else if (count == seqNumber) {
          break;
        }
        j++;
      }
    } else if (type == HORI_RIGHT) {
      while (j > col - seqNumber) {
        list = addSeqToList(i, j, color, from, list);
        if (list == null) {
          return list;
        } else if (count == seqNumber) {
          break;
        }
        j--;
      }
    } else if (type == TOP_LEFT) {
      while (i < row + seqNumber && j < col + seqNumber) {
        list = addSeqToList(i, j, color, from, list);
        if (list == null) {
          return list;
        } else if (count == seqNumber) {
          break;
        }
        i++;
        j++;
      }
    } else if (type == BOTTOM_LEFT) {
      while (i > row - seqNumber && j < col + seqNumber) {
        list = addSeqToList(i, j, color, from, list);
        if (list == null) {
          return list;
        } else if (count == seqNumber) {
          break;
        }
        i--;
        j++;
      }
    } else if (type == TOP_RIGHT) {
      while (i > row - seqNumber && j > col - seqNumber) {
        list = addSeqToList(i, j, color, from, list);
        if (list == null) {
          return list;
        } else if (count == seqNumber) {
          break;
        }
        i--;
        j--;
      }
    } else if (type == BOTTOM_RIGHT) {
      while (i < row + seqNumber && j > col - seqNumber) {
        list = addSeqToList(i, j, color, from, list);
        if (list == null) {
          return list;
        } else if (count == seqNumber) {
          break;
        }
        i++;
        j--;
      }
    }
    return list != null && list.length > 0 ? list : null;
  }

  List<String> addSeqToList(
      int row, int col, String color, String from, List<String> list) {
    if (isValid(row, col, color, from)) {
      String key = row.toString() + col.toString();
      if (GameBloc().getCardFromMap(key).value == 'wild') {
        count += 2;
      } else {
        count++;
      }
      list.add(key);
      return list;
    } else {
      list.clear();
      return null;
    }
  }

  bool isValid(int row, int col, String color, String from) {
    String key = row.toString() + col.toString();
    bool isValid = row >= 0 &&
        col >= 0 &&
        row < maxRows &&
        col < maxCols &&
        GameBloc().getCardFromMap(key).isOnBoard &&
        GameBloc().getCardFromMap(key).isChipPlaced &&
        GameBloc().getCardFromMap(key).color == color &&
        GameBloc().getCardFromMap(key).from == from;
    if (isValid &&
        (GameBloc().getCardFromMap(key).isPartOfSeq &&
            existingSeqCardIncluded == 0)) {
      existingSeqCardIncluded++;
      isValid = true;
    } else if (isValid && !GameBloc().getCardFromMap(key).isPartOfSeq) {
      isValid = true;
    } else {
      isValid = false;
    }
    return isValid;
  }
}

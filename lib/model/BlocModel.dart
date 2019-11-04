class BlocModel {
  static const String PANEL_CARD_SELECT = 'panelcardselect';
  static const String PANEL_CARD_UNSELECT = 'panelcardunselect';
  static const String PANEL_LIST = 'panelList';
  static const String HIGHLIGHT_BOARD_CARD = 'highlight';
  static const String SEQ_START_ANIM = 'seqDoneAnim';
  static const String SEQ_COMPLETED_ANIM = 'seqComplAnim';
  static const String OTHER_PLAYER_CARD = 'otherPlayerCard';
  
  static const String PANEL_CARD = 'panelcard';
  static const String BOARD_CARD = 'boardCard';

  String id;
  String cardType;
  String type;
  dynamic value;

  BlocModel(this.id,this.cardType, this.type, this.value);

  @override
  String toString() {
    return id + ' ' + type + ' ' + value.toString();
  }
}

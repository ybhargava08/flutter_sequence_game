class ResetGameModel {

    static const String PANEL = 'panel';
    static const String BOARD = 'board';
    
    String type;
    List<dynamic> data;

    ResetGameModel(this.type,this.data);

    @override
  String toString() {
    return 'type '+' data '+data.length.toString();
  }
}
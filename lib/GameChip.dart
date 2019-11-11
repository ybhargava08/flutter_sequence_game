import 'package:flutter/material.dart';
import 'package:sequence/blocs/AnimationBloc.dart';
import 'package:sequence/cards/CardStructure.dart';

class GameChip extends StatefulWidget {
  final String color;
  final String id;

  final bool addKey;

  GameChip(this.color,this.id, this.addKey);

  @override
  State<StatefulWidget> createState() => _GameChipState();
}

class _GameChipState extends State<GameChip> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_doAfterWidgetCreation);
    super.initState();
  }

  _doAfterWidgetCreation(_) {
    if (widget.addKey) {
      final RenderBox renderBox = _key.currentContext.findRenderObject();
      Offset position = renderBox.localToGlobal(Offset.zero);
      AnimationBloc().setChipKey(widget.id, position);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      width: 23,
      height: 23,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: AnimationBloc().getColor(null, widget.color),
          border: Border.all(width: 1, color: Colors.black),
          boxShadow: [
            BoxShadow(
                color: Colors.grey, blurRadius: 4, offset: Offset(1.0, 1.0))
          ]),
      padding: EdgeInsets.all(3),
      child: Center(
        child: CardStructure(AnimationBloc.CHIP_STAR_IMG, null,
                  null,null),
      ),
    );
  }
}

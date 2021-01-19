import 'package:flutter/material.dart';
import 'package:next_hour/model/video_data.dart';

class GridVideoBox extends StatelessWidget {

  GridVideoBox(this.buildContext, this.game);
  final BuildContext buildContext;
  final VideoDataModel game;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ClipRRect(
        borderRadius: new BorderRadius.circular(8.0),
        child: new FadeInImage.assetNetwork(
          image: game.box,
          placeholder: "assets/placeholder_box.jpg",
          height: 200,
          width: 60.0,
          imageScale: 1.0,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

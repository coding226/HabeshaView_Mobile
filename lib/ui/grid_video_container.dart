import 'package:flutter/material.dart';

import 'package:next_hour/model/video_data.dart';
import 'package:next_hour/ui/deatiledViewPage.dart';
import 'package:next_hour/ui/grid_video_box.dart';
import "package:next_hour/utils/item_video_box.dart";

class GridVideoContainer extends StatelessWidget {
  GridVideoContainer(this.buildContext, this.game);
  final BuildContext buildContext;
  final VideoDataModel game;

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () => _goGameDetailsPage(context, game),
      child: videoColumn(context),
    );
  }

  void _goGameDetailsPage(BuildContext context, VideoDataModel game) {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (c) {
          return new DetailedViewPage(game);
        },
      ),
    );
  }

  Widget videoColumn(context){
    return Hero(
      tag: game.name,
      child: new GridVideoBox(context, game),
    );
  }
}
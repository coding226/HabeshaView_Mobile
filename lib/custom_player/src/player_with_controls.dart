import 'dart:ui';

//import 'package:flutter/services.dart';
import 'package:next_hour/custom_player/src/chewie_player.dart';
import 'package:next_hour/custom_player/src/cupertino_controls.dart';
import 'package:next_hour/custom_player/src/material_controls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayerWithControls extends StatefulWidget {
  PlayerWithControls({Key key, this.title}) : super(key: key);
  final title;
  @override
  State<StatefulWidget> createState() {
    return _PlayerWithControlsState();
  }
}

class _PlayerWithControlsState extends State<PlayerWithControls> {
  bool zoom = false;
  @override
  Widget build(BuildContext context) {
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    final ChewieController chewieController = ChewieController.of(context);
    var r = chewieController.videoPlayerController.value.aspectRatio;
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: AspectRatio(
          aspectRatio:
              chewieController.aspectRatio ?? _calculateAspectRatio(context),
          child: _buildPlayerWithControls(r,w, h, currentOrientation, chewieController, context),
        ),
      ),
    );
  }

  GestureDetector _buildPlayerWithControls(
      r,w, h, currentOrientation, ChewieController chewieController, BuildContext context) {
    print(currentOrientation);
    return GestureDetector(
      onDoubleTap: (){
        print(zoom);
        if(zoom == true){
          setState(() {
            zoom = false;
          });
        }else{
         setState(() {
           zoom = true;
         });
        }
      },
      child: Container(
        child: Stack(
          children: <Widget>[
            chewieController.placeholder ?? Container(),
            Center(
              child: AspectRatio(
                aspectRatio:
                zoom == true ? currentOrientation == Orientation.portrait ? chewieController.aspectRatio ?? _calculateAspectRatio(context) : w/h :
//                r,
                chewieController.aspectRatio ?? _calculateAspectRatio(context),
                child: VideoPlayer(chewieController.videoPlayerController),
              ),
            ),
            chewieController.overlay ?? Container(),
            _buildControls(context, chewieController),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(
    BuildContext context,
    ChewieController chewieController,
  ) {
    return chewieController.showControls
        ? chewieController.customControls != null
            ? chewieController.customControls
            : Theme.of(context).platform == TargetPlatform.android
                ? MaterialControls(title: widget.title,)
                :
//    MaterialControls(title: widget.title,)
    CupertinoControls(
                    backgroundColor: Color.fromRGBO(41, 41, 41, 0.7),
                    iconColor: Color.fromARGB(255, 200, 200, 200),
                  )
        : Container();
  }

  double _calculateAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return width > height ? width / height : height / width;
  }
}

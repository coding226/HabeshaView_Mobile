import 'dart:io';
import 'package:flutter/services.dart';
import 'package:next_hour/custom_player/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';
import '../global.dart';

class CustomPlayer extends StatefulWidget {
  CustomPlayer({this.title, this.url, this.live});

  final String title;
  final String url;
  final String live;

  @override
  State<StatefulWidget> createState() {
    return _CustomPlayerState();
  }
}

class _CustomPlayerState extends State<CustomPlayer> with WidgetsBindingObserver {
  TargetPlatform _platform;
  VideoPlayerController _videoPlayerController1;
  ChewieController _chewieController;
  bool _isPlaying = true;
  void stopScreenLock() async{
    Wakelock.enable();
  }
  void stopScreenLock2() async{
    Wakelock.disable();
  }

  @override
  void initState() {
    super.initState();
    stopScreenLock();
    setState(() {
      playerTitle = widget.title;
    });
    print("dwugfuwdf");
    WidgetsBinding.instance.addObserver(this);
    _videoPlayerController1 =    VideoPlayerController.network(
        widget.url
    )..addListener(() {
      final bool isPlaying = _videoPlayerController1.value.isPlaying;
      if (isPlaying != _isPlaying) {
        setState(() {
          _isPlaying = isPlaying;
        });
      }
      if (_videoPlayerController1.value.hasError) {
        print("error: ${_videoPlayerController1.value.errorDescription}");
      }
    })
      ..initialize().then((_) {
        setState(() {
          _videoPlayerController1.play();
        });
      });
//    VideoPlayerController.network(widget.url)
//      ..initialize().then((_) {
//        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
//        setState(() {});
//      });
//

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      aspectRatio: 3/2,
      autoPlay: widget.live == "1" ? false : true,
      looping: true,
      isLive: widget.live == "1" ? true : false,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.red,
        handleColor: Colors.red,
        backgroundColor: Colors.white.withOpacity(0.6),
        bufferedColor: Colors.white,
      ),

      placeholder: Container(
        color: Colors.black,
      ),
      // autoInitialize: true,
    );


    var r = _videoPlayerController1.value.aspectRatio;
    String os = Platform.operatingSystem;

    if(os == 'android'){
      setState(() {
        _platform = TargetPlatform.android;
      });
    }else{
      setState(() {
        _platform = TargetPlatform.iOS;
      });
    }

  }

  @override
  void dispose() {
    super.dispose();
    print('sdfsf');
    stopScreenLock2();
    _videoPlayerController1.dispose();
    _chewieController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
  }

  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch(state){
      case AppLifecycleState.inactive:
        _chewieController.pause();
        break;

      case AppLifecycleState.resumed:
        _chewieController.pause();
        // TODO: Handle this case.
        break;
      case AppLifecycleState.paused:
      // TODO: Handle this case.
        break;
      case AppLifecycleState.detached:
      // TODO: Handle this case.
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Chewie(
                controller: _chewieController,
                title: widget.title,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
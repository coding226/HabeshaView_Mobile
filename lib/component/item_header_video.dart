import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:next_hour/apidata/apidata.dart';
import 'package:next_hour/global.dart';
import 'package:next_hour/player/iframe_player.dart';
import 'package:next_hour/player/m_player.dart';
import 'package:next_hour/player/player.dart';
import 'package:next_hour/utils/icons.dart';
import 'package:next_hour/model/video_data.dart';
import 'package:next_hour/ui/no_network.dart';
import 'package:next_hour/player/playerMovieTrailer.dart';
import 'package:next_hour/utils/item_video_box.dart';
import 'package:next_hour/utils/item_header_diagonal.dart';
import 'package:next_hour/utils/item_rating.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoDetailHeader extends StatefulWidget {

  VideoDetailHeader(this.game);
  final VideoDataModel game;
  @override
  VideoDetailHeaderState createState() => VideoDetailHeaderState();
}

class VideoDetailHeaderState extends State<VideoDetailHeader> {
  Connectivity connectivity;
  // ignore: cancel_subscriptions
  StreamSubscription<ConnectivityResult> subscription;
  var _connectionStatus = 'Unknown';
  var mReadyUrl;
  var mIFrameUrl;
  var mUrl360;
  var mUrl480;
  var mUrl720;
  var mUrl1080;
  var youtubeUrl;
  var vimeoUrl;

  getValuesSF() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      boolValue = prefs.getBool('boolValue');
    });

    print("va2 $boolValue");
  }

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    connectivity = new Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
          _connectionStatus = result.toString();
          print(_connectionStatus);
          getValuesSF();
          checkConnectionStatus = result.toString();
          if (result == ConnectivityResult.wifi) {

            setState(() {
              _connectionStatus='Wi-Fi';
            });

          }else if( result == ConnectivityResult.mobile){
            _connectionStatus='Mobile';
          }
          else {
            var router = new MaterialPageRoute(
                builder: (BuildContext context) => new NoNetwork());
            Navigator.of(context).push(router);
          }
        });
  }

  void _showMsg(){
    Fluttertoast.showToast(msg: "You are not subscribed.");
  }

  Future<String> addWatchHistory() async{
    final addWatchHisRes = await http.get(Uri.encodeFull(APIData.addWatchHistory+"/"+"${widget.game.datatype}"+"/"+"${widget.game.id}"), headers: {
      // ignore: deprecated_member_use
      HttpHeaders.AUTHORIZATION: fullData
    });
    print(addWatchHisRes.statusCode);
    return null;
  }

  void _onTapPlay(){
    mIFrameUrl = widget.game.iFrameLink;
    print("Iframe: $mIFrameUrl");
    mReadyUrl = widget.game.readyUrl;
    print("Ready Url: $mReadyUrl");
    mUrl360 = widget.game.url360;
    print("Url 360: $mUrl360");
    mUrl480 = widget.game.url480;
    print("Url 480: $mUrl480");
    mUrl720 = widget.game.url720;
    print("Url 720: $mUrl720");
    mUrl1080 = widget.game.url1080;
    print("Url 1080: $mUrl1080");

    if(widget.game.datatype == 'T'){
      var router = new MaterialPageRoute(builder: (BuildContext context) => PlayerMovie(
          id : widget.game.id,
          type: widget.game.datatype
      ),
      );
      Navigator.of(context).push(router);

    } else {
      if(mIFrameUrl != "null" || mReadyUrl != "null" || mUrl360 != "null"
          || mUrl480 != "null" || mUrl720 != "null" || mUrl1080 != "null"){
        if(mIFrameUrl != "null"){
          print("Iframe Condition");
          var url= '${widget.game.iFrameLink}';
          var router = new MaterialPageRoute(
              builder: (BuildContext context) =>  IFramePlayerPage(url: url)
          );
          Navigator.of(context).push(router);

        }
        else if(mReadyUrl != "null"){
          print("Ready URL Condition");
          var matchUrl = mReadyUrl.substring(0, 29);

          var checkMp4 = mReadyUrl.substring(mReadyUrl.length - 4);
          var checkMpd = mReadyUrl.substring(mReadyUrl.length - 4);
          var checkWebm = mReadyUrl.substring(mReadyUrl.length - 5);
          var checkMkv = mReadyUrl.substring(mReadyUrl.length - 4);
          var checkM3u8 = mReadyUrl.substring(mReadyUrl.length - 5);

          if(matchUrl.substring(0, 18) == "https://vimeo.com/"){

            var router = new MaterialPageRoute(
              builder: (BuildContext context) => PlayerMovie(
                  id : widget.game.id,
                  type: widget.game.datatype
              ),
            );
            Navigator.of(context).push(router);

          }
          else if(matchUrl == 'https://www.youtube.com/embed'){
            var url= '${widget.game.readyUrl}';
            var router = new MaterialPageRoute(
                builder: (BuildContext context) =>  IFramePlayerPage(url: url)
            );
            Navigator.of(context).push(router);

          } else if(matchUrl.substring(0, 23) == 'https://www.youtube.com'){
            var router = new MaterialPageRoute(
              builder: (BuildContext context) => PlayerMovie(
                  id : widget.game.id,
                  type: widget.game.datatype
              ),
            );
            Navigator.of(context).push(router);

          } else if(checkMp4 == ".mp4" || checkMpd == ".mpd" ||
              checkWebm == ".webm" || checkMkv == ".mkv" ||
              checkM3u8 == ".m3u8"){
            var url= '${widget.game.readyUrl}';
            var router = new MaterialPageRoute(
                builder: (BuildContext context) =>  CustomPlayer(url: url, title: widget.game.name, live: widget.game.isLive,)
            );
            Navigator.of(context).push(router);
          }
          else{
            var router = new MaterialPageRoute(
              builder: (BuildContext context) => PlayerMovie(
                  id : widget.game.id,
                  type: widget.game.datatype
              ),
            );
            Navigator.of(context).push(router);
          }
        }
        else if(mUrl360 != "null" || mUrl480 != "null" || mUrl720 != "null" || mUrl1080 != "null"){
          var url= '${widget.game.url480}';
          var router = new MaterialPageRoute(
              builder: (BuildContext context) =>  CustomPlayer(url: url, title: widget.game.name, live: widget.game.isLive,)
          );
          Navigator.of(context).push(router);

        }
        else {
          var router = new MaterialPageRoute(
            builder: (BuildContext context) => PlayerMovie(
                id : widget.game.id,
                type: widget.game.datatype
            ),
          );
          Navigator.of(context).push(router);
        }
      }
      else{
        Fluttertoast.showToast(msg: "Video URL doesn't exist");
      }
    }
  }

  void _onTapTrailer(){
    var router = new MaterialPageRoute(
        builder: (BuildContext context) =>

        new PlayerMovieTrailer(
            id : widget.game.id,
            type : widget.game.datatype

        ));
      Navigator.of(context).push(router);
  }


  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return new Stack(
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(bottom: 130.0),
          child: _buildDiagonalImageBackground(context),
        ),
       headerDecorationContainer(),
        new Positioned(
          top: 26.0,
          left: 4.0,
          child: new BackButton(color: Colors.white),
        ),
        new Positioned(
          top: 180.0,
          bottom: 0.0,
          left: 16.0,
          right: 16.0,
          child: headerRow(theme),
        ),
      ],
    );
  }
  Widget headerRow(theme){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        new Hero(
            tag: widget.game.name,
            child: new VideoBoxItem(
              context,
              widget.game,
              height: 220.0,
            )),
        new Expanded(
          child: new Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new Text(
                  widget.game.name,
                  style: Theme.of(context).textTheme.subhead,
                  maxLines: 3,
                  overflow: TextOverflow.fade,
                ),
                Flex(direction: Axis.horizontal,children: <Widget>[
                  Flexible(flex:1,child: new RatingInformation(widget.game),)
                ],
                ),
                header(theme),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget headerDecorationContainer(){
    return  Container(
      height: 262.0,
      decoration: BoxDecoration(
        //                  color: Colors.white,
          gradient: LinearGradient(
              begin: FractionalOffset.topCenter,
              end: FractionalOffset.bottomCenter,
              colors: [
                primaryColor.withOpacity(0.1),
                primaryColor,
              ],
              stops: [
                0.3,
                0.8
              ])),
    );
  }

  Widget header(theme){

    return Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: new Column(
          children: <Widget>[
            new OutlineButton(
              onPressed: status== "1" ?_onTapPlay : _showMsg,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 0,
                    child: Icon(
                        Icons.play_arrow,
                        color: Color.fromRGBO(
                            72, 163, 198, 1.0)
                    ),
                  ),
                  new Padding(
                    padding: const EdgeInsets.fromLTRB(
                        0.0, 0.0, 5.0, 0.0),
                  ),
                  Expanded(
                    flex: 1,
                    child: new Text(
                      "Play",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 15.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.9,
                          color: Colors.white
                        // color: Colors.white
                      ),
                    ),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(
                  6.0, 0.0, 12.0, 0.0),
              shape: new RoundedRectangleBorder(
                  borderRadius:
                  new BorderRadius.circular(10.0)),
              borderSide: new BorderSide(
                  color:Color.fromRGBO(
                      72, 163, 198, 1.0), width: 2.0),
              color:Color.fromRGBO(
                  72, 163, 198, 1.0),
              highlightColor: theme.accentColor,
              highlightedBorderColor: theme.accentColor,
              splashColor: Colors.black12,
              highlightElevation: 0.0,
            ),
            widget.game.datatype == 'M' ? new OutlineButton(
              onPressed: _onTapTrailer,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 0,
                    child: new Icon(playOutlineIcon,
                        color: Colors.white70),
                  ),
                  new Padding(
                    padding: const EdgeInsets.fromLTRB(
                        0.0, 0.0, 5.0, 0.0),
                  ),
                  Expanded(
                    flex: 1,
                    child: new Text(
                      "Trailer",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 15.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.9,
                        color: Colors.white,
                        // color: Colors.white
                      ),
                    ),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(
                  6.0, 0.0, 12.0, 0.0),
              shape: new RoundedRectangleBorder(
                  borderRadius:
                  new BorderRadius.circular(10.0)),
              borderSide: new BorderSide(
                  color: Colors.white70, width: 2.0),
              highlightColor: theme.accentColor,
              highlightedBorderColor: theme.accentColor,
              splashColor: Colors.black12,
              highlightElevation: 0.0,
            ) : SizedBox.shrink(),
          ],
        )
    );
  }

  Widget _buildDiagonalImageBackground(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return new DiagonallyCutColoredImage(
      new FadeInImage.assetNetwork(
        image: widget.game.cover,
        placeholder: "assets/placeholder_cover.jpg",
        width: screenWidth,
        height: 260.0,
        fit: BoxFit.cover,
      ),
      color: const Color(0x00FFFFFF),
    );
  }
}

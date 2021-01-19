import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:next_hour/apidata/apidata.dart';
import 'package:next_hour/global.dart';
import 'package:next_hour/model/video_data.dart';
import 'package:next_hour/ui/deatiledViewPage.dart';
import 'package:next_hour/ui/download_videos.dart';
import 'package:next_hour/utils/color_loader.dart';
import 'package:next_hour/utils/popup.dart';
import 'package:next_hour/utils/popup_content.dart';
import 'package:next_hour/widget/seasons_tab.dart';
import 'package:http/http.dart' as http;

class DownloadPage extends StatefulWidget {
  DownloadPage(this.video, this.url, this.name);
  final video;
  final url;
  final name;

  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> with TickerProviderStateMixin{
  TabController _seasonsTabController;
  ScrollController _scrollViewController;
  int _currentIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _seasonsTabController = TabController(
        vsync: this,
        length: widget.video.seasons == null ? 0 : widget.video.seasons.length,
        initialIndex: 0);
    _scrollViewController = new ScrollController();
  }

  @override
  void dispose() {
    _scrollViewController.dispose();
    _seasonsTabController.dispose();
    super.dispose();
  }

//  Download text
  Widget downloadText(){
    return Text(
      "Download",
      style: TextStyle(
          fontFamily: 'Lato',
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.0,
          color: Colors.white
        // color: Colors.white
      ),
    );
  }

// download icon
  Widget downloadIcon(){
    return Icon(
      Icons.arrow_downward,
      size: 30.0,
      color: Colors.white,
    );
  }

//   Getting list of episodes of different seasons
  Future<String> getData(currentIndex) async {
    setState(() {
      seasonEpisodeData = null;
    });
    final episodesResponse = await http.get(
        Uri.encodeFull(
            APIData.episodeDataApi + "${widget.video.seasons[currentIndex].id}"),
        headers: {
          // ignore: deprecated_member_use
          HttpHeaders.AUTHORIZATION: fullData
        });

    var episodesData = json.decode(episodesResponse.body);

    setState(() {
      seasonEpisodeData = episodesData['episodes'];
    });

    episodesCount = episodesData['episodes'].length;

    return null;
  }

// column
  Widget column(){
    return Column(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: <Widget>[
        downloadIcon(),
        new Padding(
          padding:
          const EdgeInsets.fromLTRB(
              0.0, 0.0, 0.0, 10.0),
        ),
        downloadText(),
      ],
    );
  }

//  Seasons tab bar
  Widget seasonsTabBar(){
    return TabBar(
      onTap: (currentIndex) {
        setState(() {
          _currentIndex = currentIndex;
        });
        setState(() {
          seasonId =
              widget.video.seasons[currentIndex].id;
        });
        setState(() {
          ser = widget.video.seasons[currentIndex].id;
        });
        getData(currentIndex);
      },
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: new BubbleTabIndicator(
        indicatorHeight: 25.0,
        indicatorColor:
        Color.fromRGBO(125, 183, 91, 1.0),
        tabBarIndicatorSize: TabBarIndicatorSize.tab,
      ),
      controller: _seasonsTabController,
      isScrollable: true,

      tabs: List<Tab>.generate(
        widget.video.seasons == null
            ? 0
            : widget.video.seasons.length,
            (int index) {
          return Tab(
            child: SeasonsTab(widget.video.seasons[index].sSeasonNo),
          );
        },
      ),
    );
  }

  void downloadProcess(){
    final platform = Theme.of(context).platform;
    if(widget.video.datatype == 'T'){
      showPopup(context, _popupBody(), 'Episodes List');
    }
    else{
//      Navigator.push(
//          context,
//          MaterialPageRoute(builder: (context) =>
//          MyApp())
//      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(
          builder: (BuildContext context) =>
              MyApp()));
    }
  }

  void msgSubscribe(){
    Fluttertoast.showToast(msg: "You are no subscribed");
  }

//  Handle after clicking download button for movies

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        child: new InkWell(
          onTap: () {
            status == 1 ? downloadProcess() : msgSubscribe();
          },
          child: column(),
        ),
        color: Colors.transparent,
      ),
    );
  }

  showPopup(BuildContext context, Widget widget, String title,
      {BuildContext popupContext}) {
    Navigator.push(
      context,
      PopupLayout(
        top: 150,
        left: 40,
        right: 40,
        bottom: 150,
        child: PopupContent(
          content: Scaffold(
            appBar: AppBar(
              backgroundColor: Color.fromRGBO(72, 163, 198, 0.4).withOpacity(1.0),
              title: Text(title),
              leading: new Builder(builder: (context) {
                return IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    try {
                      Navigator.pop(context); //close the popup
                    } catch (e) {
                    }
                  },
                );
              }),
              brightness: Brightness.light,
            ),
            resizeToAvoidBottomPadding: false,
            body: widget,
          ),
        ),
      ),
    );
  }

  Widget _popupBody() {
    return Container(
      child: _seasonsScrollView(),
    );
  }

//  Detailed page for tv series
  Widget _seasonsScrollView() {
    return ListView(
     children: <Widget>[
       allEpisodes(),
     ],
    );
  }

  /*
    This widget show the list of all episodes of particular seasons .
    This widget should not be declared outside of this page other play creating issues.
*/
  Widget allEpisodes() {
    print(seasonEpisodeData);
    if (seasonEpisodeData == null) {
      return Container(
        child: ColorLoader(),
      );
    } else {
      List moreLikeThis = new List<VideoDataModel>.generate(
          newVideosListG == null ? 0 : newVideosListG.length, (int index) {
        var genreIds2Count = newVideosListG[index].genre.length;
        var genreIds2All = newVideosListG[index].genre;
        for (var j = 0; j < genreIds2Count; j++) {
          var genreIds2 = genreIds2All[j];
          var isAv = 0;
          for (var i = 0; i < widget.video.genre.length; i++) {
            var genreIds = widget.video.genre[i].toString();

            if (genreIds2 == genreIds) {
              isAv = 1;
              break;
            }
          }
          if (isAv == 1) {
            if (widget.video.datatype == newVideosListG[index].datatype) {
              if (widget.video.id != newVideosListG[index].id) {
                return newVideosListG[index];
              }
            }
          }
        }
        return null;
      });

      moreLikeThis.removeWhere((item) => item == null);
      return Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              episodesList(),
            ],
          ),
        ),
        color: primaryColor,
      );
    }
  }

  //  Episode title
  Widget episodeTitle(i){
    return Text(
        'Episode ${seasonEpisodeData[i]['episode_no']}',
        style: TextStyle(
            fontSize: 14.0,
            color: Colors.white));
  }

//  Episode subtitle
  Widget episodeSubtitle(i){
    return Text(
      '${seasonEpisodeData[i]['title']}',
      style: TextStyle(
        fontSize: 12.0,
      ),
    );
  }

//  Expansion tile for episodes
  Widget expansionTile(i){

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            episodeTitle(i),
            SizedBox(
              height: 5.0,
            ),
            episodeSubtitle(i)
          ],
        )
      ],
    );
  }

//  Generate list of episodes
  Widget episodesList(){
    return Padding(
      padding: const EdgeInsets.only(
          top: 0.0, bottom: 0.0, left: 0.0, right: 0.0),
      child: Column(
        children: List.generate(
            seasonEpisodeData == null ? 0 : seasonEpisodeData.length,
                (int i) {
              return Container(
                child: Column(
                  children: <Widget>[
                    new Container(
                      decoration: new BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            //                    <--- top side
                            color: primaryColor,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    new ExpansionTile(
                        title: expansionTile(i),
                          trailing: GestureDetector(
//                            padding: EdgeInsets.all(0.0),
                          child: Icon(Icons.arrow_downward),
                          onTap: (){

                          }),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomRight,
                    stops: [0.1, 0.5, 0.7, 0.9],
                    colors: [
                      Color.fromRGBO(72, 163, 198, 0.4).withOpacity(0.0),
                      Color.fromRGBO(72, 163, 198, 0.3).withOpacity(0.1),
                      Color.fromRGBO(72, 163, 198, 0.2).withOpacity(0.2),
                      Color.fromRGBO(72, 163, 198, 0.1).withOpacity(0.3),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}

class _TaskInfo {
  final String name;
  final String link;

  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  _TaskInfo({this.name, this.link});
}

class _ItemHolder {
  final String name;
  final _TaskInfo task;

  _ItemHolder({this.name, this.task});
}

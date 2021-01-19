import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:next_hour/apidata/apidata.dart';
import 'package:next_hour/model/comments_model.dart';
import 'package:next_hour/model/lang_model.dart';
import 'package:next_hour/component/item_description.dart';
import 'package:next_hour/component/item_header_video.dart';
import 'package:next_hour/utils/color_loader.dart';
import 'package:next_hour/model/WatchlistModel.dart';
import 'package:next_hour/model/video_data.dart';
import 'package:next_hour/model/seasons.dart';
import 'package:http/http.dart' as http;
import 'package:next_hour/ui/no_network.dart';
import 'package:next_hour/player/player_episodes.dart';
import 'package:next_hour/widget/container_border.dart';
import 'package:next_hour/widget/rate_us.dart';
import 'package:next_hour/widget/seasons_tab.dart';
import 'package:next_hour/widget/share_page.dart';
import 'package:next_hour/widget/tab_widget.dart';
import 'package:next_hour/widget/watchlist_container.dart';
import 'package:next_hour/global.dart';

var seasonId;
var seasonCount;
var episodesCount;
int episodesCounting = 0;
int _currentIndex = 0;

class DetailedViewPage extends StatefulWidget {
  DetailedViewPage(this.game, {Key key}) : super(key: key);
  final VideoDataModel game;

  @override
  _DetailedViewPageState createState() => new _DetailedViewPageState();
}

class _DetailedViewPageState extends State<DetailedViewPage>
    with TickerProviderStateMixin, RouteAware {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _scrollViewController;
  TabController _tabController;
  int _currentIndex2 = 0;
  TabController _episodeTabController;
  TabController _seasonsTabController;
  bool horizontal = true;
  bool descTextShowFlag = false;
  Seasons selected;
  List<Widget> containers;
//  bool isAdded = true;
  var avId1;
  var avId2;
  Connectivity connectivity;
  // ignore: cancel_subscriptions
  StreamSubscription<ConnectivityResult> subscription;
  // ignore: unused_field
  var _connectionStatus = 'Unknown';
  var aLangFinalM;
  var aLangFinalS;
  var audioLangIdS;
  final _formKey = new GlobalKey<FormState>();
  final TextEditingController commentsController = new TextEditingController();
  List<CommentsModel> ls;
  List<VideoDataModel> tvSeList;
  List<VideoDataModel> movList;
  List<dynamic> seList;
  List <Widget> generatedMoviesList;
  var moviesCount;
  var itemLen;
  var singleIdMovies;
  var singleIdTvSeries;
  var  description;
  int commentsLen = 0;


  Widget tapOnMoreLikeThis(moreLikeThis) {
    return Container(
      height: 300.0,
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        scrollDirection: Axis.horizontal,
        children: new List<Padding>.generate(
            moreLikeThis == null
                ? 0
                : moreLikeThis.length, (int index) {
          return new Padding(
            padding: EdgeInsets.only(
                right: 2.5, left: 2.5, bottom: 5.0),
            child: moreLikeThis[index] == null
                ? Container()
                : cusPlaceHolder(moreLikeThis,index),
          );
        }),
      ),
    );
  }

// Sliver app bar tabs
  Widget _sliverAppBar(innerBoxIsScrolled) => SliverAppBar(
    titleSpacing: 0.00,
    elevation: 0.0,
    title: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CustomBorder(),
        new TabBar(
            onTap: (currentIndex) {
              setState(() {
                _currentIndex = currentIndex;
              });
            },
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                  color:
                  Color.fromRGBO(125, 183, 91, 1.0),
                  width: 2.5),
              insets: EdgeInsets.fromLTRB(
                  0.0, 0.0, 0.0, 46.0),
            ),
            indicatorColor: Colors.orangeAccent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3.0,
            indicatorPadding:
            EdgeInsets.fromLTRB(10, 0, 10, 0),
            unselectedLabelColor:
            Color.fromRGBO(95, 95, 95, 1.0),
            tabs: [
              TabWidget('MORE LIKE THIS'),
              TabWidget('MORE DETAILS'),
            ]),
      ],
    ),
    backgroundColor: primaryColor.withOpacity(1.0),
    pinned: true,
    floating: true,
    forceElevated: innerBoxIsScrolled,
    automaticallyImplyLeading: false,
  );

// Tab bar for similar movies or tv series
  Widget _tabBarView(moreLikeThis) => TabBarView(
      children: <Widget>[
        new ListView(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            tapOnMoreLikeThis(moreLikeThis),
          ],
        ),
        moreDetails()
      ]);

  Widget genresRow(genres){
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Text(
                'Genres:',
                style: TextStyle(
                    color: Colors.grey, fontSize: 13.0),
              ),
            ),
            Expanded(
              flex: 5,
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  "$genres",
                  style: TextStyle(
                      color: Colors.white, fontSize: 13.0),
                ),
              ),
            ),
          ],
        ));
  }

  Widget genresDetailsContainer(game, genres){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                left: 20.0, right: 20.0, bottom: 15.0, top: 15.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "About",
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                  ],
                ),
                Container(
                  height: 8.0,
                ),
                genreNameRow(game),
                genresRow(genres),
                game.datatype == "T"
                    ? Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Details:',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 13.0),
                          ),
                        ),
                        genreDetailsText(game),
                      ],
                    )
                )
                    : SizedBox(
                  width: 0.0,
                ),
                audioLangRow(game),
              ],
            ),
          ),
          Container(
            color: primaryDarkColor,
            height: 8.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0, bottom: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Comments", textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
                    ),
                    ButtonTheme(
                      minWidth: 60.0,
                      height: 25.0,
                      child: RaisedButton(
                          elevation: 10.0,
                          color: greenPrime,
                          padding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
                          child: Text("Add"),
                          onPressed: (){
                            addComment(context);
                          }),
                    ),
                  ],
                ),
                comments(),
              ],
            ),
          )
        ],
      ),
      color: Color.fromRGBO(45, 45, 45, 1.0),
    );
  }

  Widget genreNameRow(game){
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Text(
                'Name:',
                style: TextStyle(
                    color: Colors.grey, fontSize: 13.0),
              ),
            ),
            Expanded(
              flex: 5,
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  "${game.name}",
                  style: TextStyle(
                      color: Colors.white, fontSize: 13.0),
                ),
              ),
            ),
          ],
        )
    );
  }

  Widget audioLangRow(game){
    var audioList = mainData['audio'];
    List<LangModel> auLang = List.generate(audioList.length, (int index){
      return LangModel(
          id: audioList[index]['id'],
          aLanguage: "${audioList[index]['language']}"
      );
    });


    var audioLangIdM = widget.game.aLang;
    if(audioLangIdM == null){
      audioLangIdM = "Not Available";
    }

    for(var i=0; i<auLang.length; i++){
      if("${auLang[i].id}" == audioLangIdM){
        aLangFinalM = auLang[i].aLanguage == null ? 'N/A' : auLang[i].aLanguage;
      }
    }


    if(audioLangIdS == null){
      audioLangIdS = "Not Available";
    }

    for(var i=0; i<auLang.length; i++){
      if("${auLang[i].id}" == audioLangIdS){
        aLangFinalS = auLang[i].aLanguage == null ? 'N/A' : auLang[i].aLanguage;
      }
    }
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Text(
                'Audio Language:',
                style: TextStyle(
                    color: Colors.grey, fontSize: 13.0),
              ),
            ),
            Expanded(
              flex: 5,
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  game.datatype == "M" ? "$aLangFinalM" :  "$aLangFinalS",
                  style: TextStyle(
                      color: Colors.white, fontSize: 13.0),
                ),
              ),
            ),
          ],
        )
    );
  }

  void getComments(){
    var com = widget.game.comments;
    ls= List<CommentsModel>.generate(com == null ? 0 : com.length, (int mComIndex){
      print(com[mComIndex].cComment);
      return CommentsModel(
        id: com[mComIndex].id,
        cName: com[mComIndex].cName,
        cEmail: com[mComIndex].cEmail,
        cMovieId: com[mComIndex].cMovieId,
        cTvSeriesId: com[mComIndex].cTvSeriesId,
        cComment: com[mComIndex].cComment,
        cCreatedAt: com[mComIndex].cCreatedAt,
        cUpdatedAt: com[mComIndex].cUpdatedAt,
      );
    }
    );
  }

  Widget comments(){
    return ListView.builder(
        itemCount: this.commentsLen,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, index) => this._buildRow(index));
  }


  Future <void> addComment(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding:  EdgeInsets.only(left: 25.0, right: 25.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0))),
          title: Container(
            alignment: Alignment.topLeft,
            child: Text('Add Comments',style: TextStyle(color: greenPrime, fontWeight: FontWeight.w600),),
          ),
          content: Container(
            height: MediaQuery.of(context).size.height / 4,
            child: Column(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Container(
                    margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextFormField(
                      controller: commentsController,
                      maxLines: 4,
                      decoration: new InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                        hintText: "Comment",
                        errorStyle: TextStyle(fontSize: 10),
                        hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.4), fontSize: 18),
                      ),
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.7), fontSize: 18),
                      validator: (val) {
                        if (val.length == 0) {
                          return "Comment can not be blank.";
                        }
                        return null;
                      },
                      onSaved: (val) => commentsController.text = val,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                InkWell(
                  child: Container(
                    color: greenPrime,
                    height: 45.0,
                    width: 100.0,
                    padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 5.0, bottom: 5.0),
                    child: Center(
                      child: Text("Post", textAlign: TextAlign.center,),
                    ),
                  ),
                  onTap: (){
                      final form = _formKey.currentState;
                      form.save();
                      if (form.validate() == true) {
                        postComment();
                      }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future <String> postComment() async{
    final postCommentResponse = await http.post(APIData.postBlogComment, body: {
      "type": '${widget.game.datatype}',
      "id": '${widget.game.id}',
      "comment": '${commentsController.text}',
      "name": '$name',
      "email": '$email',
    },
        headers: {
          // ignore: deprecated_member_use
          HttpHeaders.AUTHORIZATION: fullData,
        });
    print(postCommentResponse.statusCode);
    if(postCommentResponse.statusCode == 200){
      ls.add(CommentsModel(id: widget.game.id, cName: name, cEmail: email, cComment: commentsController.text));
      _updateComments();

      setState(() {
        commentsLen = ls.length;
      });
      commentsController.text = '';

      Fluttertoast.showToast(msg: "Commented Successfully");
      commentsController.text = '';
      Navigator.pop(context);
    }else{
      Fluttertoast.showToast(msg: "Error in commenting");
      commentsController.text = '';
      Navigator.pop(context);
    }

    return null;
  }

  _updateComments(){
    setState(() {
      commentsLen = commentsLen + 1;
    });
  }

  _buildRow(int position) {
//    return Text("Item " + position.toString());
    return Column(
      children: <Widget>[
        SizedBox(height: 10.0,),
        Row(
          children: <Widget>[
            ls[position].cName == null ? SizedBox.shrink():
            Text(ls[position].cName, style: TextStyle(fontSize: 13.0),),
          ],
        ),
        SizedBox(height: 3.0,),
        Row(
          children: <Widget>[
            ls[position].cComment == null ? SizedBox.shrink():
            Text(ls[position].cComment, style: TextStyle(fontSize: 12.0, color: whiteColor.withOpacity(0.6)),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _currentIndex2 = 0;

//     Check movies and tv shows in watchlist when page get called.
    if(widget.game.seasons.length !=0 ){
      if (widget.game.datatype == 'T') {
        this.getData(_currentIndex);
      }
    }
    getComments();
    setState(() {
      commentsLen = ls.length;
    });
    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);
    _seasonsTabController = TabController(
        vsync: this,
        length: widget.game.seasons == null ? 0 : widget.game.seasons.length,
        initialIndex: 0);
    _scrollViewController = new ScrollController();

    _episodeTabController =
        TabController(vsync: this, length: 2, initialIndex: 0);

    connectivity = new Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
          _connectionStatus = result.toString();
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


//   Add  movies or tv shows to watchlist.
  Future <String> addWishlist(type, id, value)async{
    try{
      // ignore: unused_local_variable
      final addWatchlistResponse = await http.post( APIData.addWatchlist, body: {
        "type": type,
        "id": '$id',
        "value": '$value'
      }, headers: {
        // ignore: deprecated_member_use
        HttpHeaders.AUTHORIZATION: fullData
      });

    }
    catch (e) {
      return null;
    }
    return null;
  }

//   Getting list of episodes of different seasons
  Future<String> getData(currentIndex) async {
    setState(() {
      seasonEpisodeData = null;
    });
    final episodesResponse = await http.get(
        Uri.encodeFull(
            APIData.episodeDataApi + "${widget.game.seasons[currentIndex].id}"),
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

  @override
  void dispose() {
    _scrollViewController.dispose();
    _tabController.dispose();
    _seasonsTabController.dispose();
    _episodeTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//  Set orientation of the page portrait up.
//    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

//  Check movies and tv shows in watchlist when page get called.
    var isAdded = 0;
    if(widget.game.seasons.length != 0) {
      ser= widget.game.datatype == 'T' ? widget.game.seasons[0].id : null;
    }
    for(var i=0; i<userWatchList.length; i++){
      for(var j=0; j<widget.game.seasons.length; j++){
        if(userWatchList[i].season_id==widget.game.seasons[j].id){
          isAdded = 1;
          avId1 = widget.game.seasons[j].id;
          break;
        }
      }
      if(isAdded == 1){
        break;
      }
    }

    var isMovieAdded = 0;
    for(var i=0; i<userWatchList.length; i++){
      if(userWatchList[i].wMovieId==widget.game.id){
        isMovieAdded = 1;
        avId2 = widget.game.id;
        break;
      }
    }

    List moreLikeThis = new List<VideoDataModel>.generate(
        newVideosListG == null ? 0 : newVideosListG.length, (int index) {
      var genreIds2Count = newVideosListG[index].genre.length;
      var genreIds2All = newVideosListG[index].genre;
      for (var j = 0; j < genreIds2Count; j++) {
        var genreIds2 = genreIds2All[j];
        var isAv = 0;
        for (var i = 0; i < widget.game.genre.length; i++) {
          var genreIds = widget.game.genre[i].toString();

          if (genreIds2 == genreIds) {
            isAv = 1;
            break;
          }
        }
        if (isAv == 1) {
          if (widget.game.datatype == newVideosListG[index].datatype) {
            if (widget.game.id != newVideosListG[index].id) {
              return newVideosListG[index];
            }
          }
        }
      }
      return null;
    }
    );

    moreLikeThis.removeWhere((item) => item == null);
    return  DefaultTabController(
        length: 2,
        child: scaffold(isAdded, isMovieAdded, moreLikeThis),
    );


  }

  Widget addWatchListSeasons(isAdded) {
    return Expanded(
      child: Material(
        child: InkWell(
          onTap: () async {
            var isAdded = 0;
            var setype, seid, sevalue;
            var avId;
            for (var i = 0; i < userWatchList.length; i++) {
              for (var j = 0; j < widget.game.seasons.length; j++) {
                if (userWatchList[i].season_id == widget.game.seasons[j].id) {
                  isAdded = 1;
                  avId = widget.game.seasons[j].id;
                  break;
                }
              }
              if (isAdded == 1) {
                break;
              }
            }
//          Add Seasons to watchlist
            if (isAdded != 1) {
              userWatchList.add(WatchlistModel(
                season_id: widget.game.seasons[0].id,
              )
              );
              setState(() {
                isAdded = 1;
              });
              setype = 'S';
              seid = widget.game.seasons[0].id;
              sevalue = 1;
              addWishlist(setype, seid, sevalue);
            } else {
              setState(() {
                isAdded = 0;
              });
              setype = 'S';
              seid = widget.game.seasons[0].id;
              sevalue = 0;
              addWishlist(setype, seid, sevalue);
              userWatchList.removeWhere((item) =>
              item.season_id == avId);
            }
          },
          child: WishListContainer(isAdded),
        ),
        color: Colors.transparent,
      ),
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
            widget.game.seasons[currentIndex].id;
            audioLangIdS = widget.game.seasons[currentIndex].language;
//          print(audioLangIdS);
        });
        setState(() {
          ser = widget.game.seasons[currentIndex].id;
          audioLangIdS = widget.game.seasons[currentIndex].language;
//          print(audioLangIdS);
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
        widget.game.seasons == null
            ? 0
            : widget.game.seasons.length,
            (int index) {
          return Tab(
            child: SeasonsTab(widget.game.seasons[index].sSeasonNo),
          );
        },
      ),
    );
  }

//  Sliver app bar that contains tab bar
    Widget sliverAppbarSeasons(innerBoxIsScrolled) {
    return SliverAppBar(
        elevation: 0.0,
        title: seasonsTabBar(),
        backgroundColor: primaryColor
            .withOpacity(1.0),
        pinned: false,
        floating: true,
        forceElevated: innerBoxIsScrolled,
        automaticallyImplyLeading: false,
    );
  }

//  SliverList including detail header and row of my list, rate, share and download.
    Widget sliverList(isAdded){
      if(widget.game.seasons.length != 0) {
        return SliverList(
            delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int j) {
                  return Container(
                    color: primaryColor,
                    child: Column(
                      children: <Widget>[
                        VideoDetailHeader(widget.game),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(
                                16.0, 0.0, 16.0, 0.0),
                            child: new DescriptionText(
                                widget.game.description)
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              16.0, 26.0, 16.0, 0.0),
                        ),

                        Row(
                          children: [
                            addWatchListSeasons(isAdded),

                            RateUs(widget.game.datatype, widget.game.id),
                            SharePage(APIData.shareSeasonsUri,
                                widget.game.seasons[0].id),
//                            DownloadPage(widget.game, "",""),


                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 20.0),
                        )
                      ],
                    ),
                  );
                }, childCount: 1)
        );
      }
      else{
        return SliverList(
            delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int j) {
                  return Container(
                    color: primaryColor,
                    child: Column(
                      children: <Widget>[
                        VideoDetailHeader(widget.game),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(
                                16.0, 0.0, 16.0, 0.0),
                            child: new DescriptionText(
                                widget.game.description)
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              16.0, 26.0, 16.0, 0.0),
                        ),

                        Padding(
                          padding: EdgeInsets.only(bottom: 20.0),
                        )
                      ],
                    ),
                  );
                }, childCount: 1)
        );
      }
    }

//  Detailed page for tv series
    Widget _seasonsScrollView(isAdded) {
      audioLangIdS = widget.game.seasons[_currentIndex].language;
      return NestedScrollView(
        controller: _scrollViewController,
          headerSliverBuilder:
              (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              sliverList(isAdded),

//     SliverAppBar contains header
              sliverAppbarSeasons(innerBoxIsScrolled),
            ];
          },
        body: _currentIndex2 == 0 ? allEpisodes() : moreDetails(),
    );
    }

//  Tab to add to remove watchlist
    Widget watchlistColumn(isMovieAdded){
    return Column(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: <Widget>[
        isMovieAdded == 1 ? Icon(
          Icons.check, size: 30.0, color: greenPrime,) : Icon(
          Icons.add, size: 30.0, color: Colors.white,),

        new Padding(
          padding:
          const EdgeInsets.fromLTRB(
              0.0, 0.0, 0.0, 10.0),
        ),
        myListText(),
      ],
    );
  }

//  Add or remove watchlist tab for movies
    Widget _watchListMovie(isMovieAdded) {
    return Expanded(
      child: Material(
        child: new InkWell(
//     Add and remove movies and tv shows in watchlist
          onTap: () {
            var isMovieAdded = 0;
            var motype, moid, movalue;
            var avId;
            for (var i = 0; i < userWatchList.length; i++) {
              if (userWatchList[i].wMovieId == widget.game.id) {
                isMovieAdded = 1;
                avId = widget.game.id;
                break;
              }
            }
            if (isMovieAdded != 1) {
              userWatchList.add(WatchlistModel(
                wMovieId: widget.game.id,
              ));

              motype = 'M';
              moid = widget.game.id;
              movalue = 1;
              setState(() {
                isMovieAdded = 1;
              });
              addWishlist(motype, moid, movalue);
            } else {
              motype = 'M';
              moid = widget.game.id;
              movalue = 0;
              setState(() {
                isMovieAdded = 0;
              });
              addWishlist(motype, moid, movalue);
              userWatchList.removeWhere((item) => item.wMovieId == avId);
            }
          },
          child: watchlistColumn(isMovieAdded),
        ),
        color: Colors.transparent,
      ),
    );
  }

//  Detailed page for movies
    Widget _movieScrollview(isMovieAdded, moreLikeThis) => NestedScrollView(
      controller: _scrollViewController,
      headerSliverBuilder:
          (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverList(
              delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int j) {
                    return Container(
                      color: primaryColor,
                      child: Column(
                        children: <Widget>[
                          new VideoDetailHeader(widget.game),
                          new Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16.0, 0.0, 16.0, 0.0),
                              child: new DescriptionText(
                                  widget.game.description)),

                          new Padding(
                            padding: const EdgeInsets.fromLTRB(
                                16.0, 26.0, 16.0, 0.0),
                          ),

                          new Row(
                            children: [
                              _watchListMovie(isMovieAdded),
                              RateUs(widget.game.datatype, widget.game.id),
                              SharePage(APIData.shareMovieUri,widget.game.id),
//                              DownloadPage(widget.game, "The Dark Night", "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
                            ],
                          ),

                          Padding(
                            padding: EdgeInsets.only(bottom: 20.0),
                          )
                        ],
                      ),
                    );
                  }, childCount: 1)
          ),

          _sliverAppBar(innerBoxIsScrolled),
        ];
      },
      body: _tabBarView(moreLikeThis),
    );

//  Episode title
    Widget episodeTitle(i){
      return Text(
          'Episode ${seasonEpisodeData[i]['episode_no']}',
          style: TextStyle(
              fontSize: 14.0, color: Colors.white));
    }

//  Play button for particular episode.
    Widget gestureDetector(i) {
      return GestureDetector(
        child: Icon(
          Icons.play_circle_outline,
          color: Colors.white,
          size: 35.0,
        ),
        onTap: () {
          if(status == "1"){
            var router = new MaterialPageRoute(
                builder: (BuildContext context) =>
                new PlayerEpisode(
                  id : seasonEpisodeData[i]['id'],
                ));
            Navigator.of(context).push(router);

          }else{
            Fluttertoast.showToast(msg: "You are not subscribed.");
          }
        },
      );
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
      return ListTile(
        leading: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            gestureDetector(i),
          ],
        ),
        contentPadding: EdgeInsets.all(0.0),
        title: episodeTitle(i),
        subtitle: episodeSubtitle(i),
      );
    }

//  Customer also watched text
    Widget cusAlsoWatchedText(){
      return Container(
        child: new Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 5.0),
          child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                new Text(
                  "Customers also watched",
                  style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.9,
                      color: Colors.white),
                ),
              ]),
        ),
      );
    }

//  More like this video for seasons
    Widget moreLikeThisSeasons(moreLikeThis){
      return ListView(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: <Widget>[
          Container(
            height: 300.0,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              scrollDirection: Axis.horizontal,
              children: List<Padding>.generate(
                  moreLikeThis == null ? 0 : moreLikeThis.length,
                      (int index) {
                    return new Padding(
                      padding: EdgeInsets.only(
                          right: 2.5, left: 2.5, bottom: 5.0),
                      child: moreLikeThis[index] == null
                          ? Container()
                          : InkWell(
                        child: FadeInImage.assetNetwork(
                          image: moreLikeThis[index].box,
                          placeholder: 'assets/placeholder_box.jpg',
                          height: 150.0,
                          fit: BoxFit.cover,
                        ),
                        onTap: () {
                          var router = new MaterialPageRoute(
                              builder: (BuildContext context) =>
                              new DetailedViewPage(
                                  moreLikeThis[index]));
                          Navigator.of(context).push(router);
                        },
                      ),
                    );
                  }),
            ),
          )
        ],
      );
    }

//  Episodes details like released date and description
    Widget episodeDetails(i){
      return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(
                10.0,
              ),
              child: Text(
                '${seasonEpisodeData[i]['detail']}',
                style: TextStyle(fontSize: 12.0),
              ),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(
                    10.0,
                  ),
                  child: Text(
                    'Released: ' +
                        '${seasonEpisodeData[i]['released']}',
                    style: TextStyle(fontSize: 12.0),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

//  Tab bar for seasons page and episodes and more details tabs
    Widget tabBar(){
      return TabBar(
          onTap: (currentIndex2) {
            setState(() {
              _currentIndex2 = currentIndex2;
            });
          },
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: Colors.white70, width: 2.5),
            insets: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
          ),
          indicatorColor: Colors.orangeAccent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3.0,
          unselectedLabelColor: Color.fromRGBO(95, 95, 95, 1.0),
          tabs: [
            TabWidget('EPISODES'),
            TabWidget('MORE DETAILS'),
          ]);
    }

//  Icon to expand episode to show more details
    Widget expansionIcon(){
      return GestureDetector(
        child: Icon(
          Icons.arrow_drop_down,
          color: Colors.white,
          size: 45.0,
        ),
        onTap: null,
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
                          trailing: expansionIcon(),
                          children: <Widget>[
                            episodeDetails(i),
                          ]),
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
/*
    This widget show the list of all episodes of particular seasons .
    This widget should not be declared outside of this page other play creating issues.
*/
    Widget allEpisodes() {
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
            for (var i = 0; i < widget.game.genre.length; i++) {
              var genreIds = widget.game.genre[i].toString();

              if (genreIds2 == genreIds) {
                isAv = 1;
                break;
              }
            }
            if (isAv == 1) {
              if (widget.game.datatype == newVideosListG[index].datatype) {
                if (widget.game.id != newVideosListG[index].id) {
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
                tabBar(),
                episodesList(),
                cusAlsoWatchedText(),
                moreLikeThisSeasons(moreLikeThis),
              ],
            ),
          ),
          color: primaryColor,
        );
      }
    }

//  My list text to add or remove to watchlist
    Widget myListText(){
    return Text(
      "My List",
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

//  Genre details text
    Widget genreDetailsText(game){
      return Expanded(
        flex: 5,
        child: GestureDetector(
          onTap: () {},
          child: Text(
            "${game.seasons[_currentIndex].description}",
            style: TextStyle(
                color: Colors.white,
                fontSize: 13.0),
          ),
        ),
      );
  }

//  Customer also watched videos place holder
    Widget cusPlaceHolder(moreLikeThis, index){
    return InkWell(
      child: FadeInImage.assetNetwork(
        image: moreLikeThis[index].box,
        placeholder: 'assets/placeholder_box.jpg',
        height: 150.0,
        fit: BoxFit.cover,
      ),
      onTap: () {
        var router =
        new MaterialPageRoute(
            builder: (BuildContext
            context) =>
            new DetailedViewPage(moreLikeThis[index]));
        Navigator.of(context).push(router);
      },
    );
  }

//  More like this grid view.
    Widget moreLikeThisGrid(moreLikeThis,index){
    return Container(
      height: 300.0,
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        scrollDirection: Axis.horizontal,
        children: new List<Padding>.generate(
            moreLikeThis == null
                ? 0
                : moreLikeThis.length, (int index) {
          return new Padding(
            padding: EdgeInsets.only(
                right: 2.5, left: 2.5, bottom: 5.0),
            child: moreLikeThis[index] == null
                ? Container()
                : cusPlaceHolder(moreLikeThis,index),
          );
        }),
      ),
    );
  }
/*
    This widget show the episodes  and genre details of particular seasons .
    This widget should not be declared outside of this page other play creating issues.
*/

    Widget moreDetails() {
      widget.game.genres.removeWhere((value) => value == null);
      String genres = widget.game.genres.toString();
      genres = genres.replaceAll("[", "").replaceAll("]", "");
      return new Container(
        child: new SingleChildScrollView(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              widget.game.datatype == "T"
                  ? new TabBar(
                  onTap: (currentIndex2) {
                    setState(() {
                      _currentIndex2 = currentIndex2;
                    });
                  },
                  indicator: UnderlineTabIndicator(
                    borderSide:
                    BorderSide(color: Colors.white70, width: 2.5),
                    insets: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  ),
                  indicatorColor: Colors.orangeAccent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 3.0,
                  unselectedLabelColor: Color.fromRGBO(95, 95, 95, 1.0),
                  tabs: [
                    TabWidget('EPISODES'),
                    TabWidget('MORE DETAILS'),
                  ])
                  : SizedBox(
                width: 0.0,
              ),
              genresDetailsContainer(widget.game, genres),
            ],
          ),
        ),
        color: primaryColor,
      );
    }

//  Scaffold that contains overall UI of his page
    Widget scaffold(isAdded, isMovieAdded, moreLikeThis){

      return Scaffold(
        key: _scaffoldKey,
        body: widget.game.datatype == "T"
            ? _seasonsScrollView(isAdded)
            : _movieScrollview(isMovieAdded, moreLikeThis),
        backgroundColor: primaryColor,
      );
    }
  }




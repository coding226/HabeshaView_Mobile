import 'package:flutter/material.dart';
import 'package:next_hour/apidata/apidata.dart';
import 'package:next_hour/global.dart';
import 'package:next_hour/model/comments_model.dart';
import 'package:next_hour/model/seasons.dart';
import 'package:next_hour/model/video_data.dart';
import 'package:next_hour/ui/grid_video_container.dart';

class GridVideosPageMt extends StatefulWidget {

  GridVideosPageMt(this.tmType, this.type, this.dataItems);
  final tmType;
  final type;
  final List<VideoDataModel> dataItems;

  @override
  _GridVideosPageMtState createState() => _GridVideosPageMtState();
}

class _GridVideosPageMtState extends State<GridVideosPageMt> {
  List<Widget> tmList;
  var data1;
  var type;
  var description;
  var t;
  var singleId;
  List<dynamic> se;

  Widget appBar(){
    return AppBar(
      title: Text('${widget.tmType}', style: TextStyle(
        fontSize: 16.0,
        color: Colors.white,
      ),),
      leading: IconButton(icon: Icon(Icons.arrow_back_ios, size: 18,), onPressed: (){
        Navigator.pop(context);
      }),
      backgroundColor: primaryDarkColor,
      centerTitle: true,
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar(),
        body: Padding(
            padding: const EdgeInsets.only(
                top: 10.0, bottom: 0.0, left: 0.0, right: 0.0),
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: menuDataListLength == null ? 0 : menuDataListLength,
                physics: ClampingScrollPhysics(),
                primary: true,
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.only(top: 0.0),
                itemBuilder: (BuildContext context, int index1) {
                  var type;
                  var description;
                  var t;
                  var singleId;
                  List<dynamic> se;

                  newVideosTM = List<VideoDataModel>.generate(
                      menuDataArray[index1].length == null ? 0 : menuDataArray[index1].length, (int index) {
                    data1 = menuDataArray[index1];
                    type = data1[index]['type'];
                    description = data1[index]['detail'];
                    t = description;
                    var genreIdByM = data1[index]['genre_id'];
                    singleId = genreIdByM.split(",");
                    var tmdbRating = searchIds2[index]['rating'];
                    double convrInStart = tmdbRating != null ? (tmdbRating) / 2 : 0;

                    var idTM;
                    if(type == "T"){
                      se = data1[index]['seasons'] as List<dynamic>;
                      idTM = data1[index]['comments'];
                    }else{
                      se = data1[index]['movie_series'] as List<dynamic>;
                      idTM = data1[index]['comments'];
                      videoLink = data1[index]['video_link'];
                      iFrameURL =  videoLink['iframeurl'];
                      iReadyUrl = videoLink['ready_url'];
                    }
                    return VideoDataModel(
                        id: data1[index]['id'],
                        name: '${data1[index]['title']}',
                        box: type == "T"
                            ? "${APIData.tvImageUriTv}" +
                            "${data1[index]['thumbnail']}" : "${APIData.movieImageUri}" + "${data1[index]['thumbnail']}",
                        cover: type == "T" ? "${APIData.tvImageUriPosterTv}" + "${data1[index]['poster']}"
                            : "${APIData.movieImageUriPosterMovie}" +
                            "${data1[index]['poster']}",
                        description: "$t",
                        datatype: type,
                        rating: convrInStart,
                        iFrameLink: "$iFrameURL",
                        readyUrl: '$iReadyUrl',
                        videoLink: "$videoLink",
                        screenshots: List.generate(3, (int xyz) {
                          return type == "T"
                              ? "${APIData.tvImageUriPosterTv}" +
                              "${data1[index]['poster']}"
                              : "${APIData.movieImageUriPosterMovie}" +
                              "${data1[index]['poster']}";
                        }),
                        url: '${data1[index]['trailer_url']}',
                        menuId: 1,
                        genre: List.generate(
                            singleId == null ? 0 : singleId.length,
                                (int xyz) {
                              return "${singleId[xyz]}";
                            }),

                        genres: List.generate(
                            genreData == null ? 0 : genreData.length,
                                (int genereIndex) {
                              var genreId2 = genreData[genereIndex]['id'].toString();

                              var genrelist = List.generate(
                                  singleId == null ? 0 : singleId.length,
                                      (int i) {
                                    return "${singleId[i]}";
                                  });
                              var isAv2 = 0;
                              for (var y in genrelist) {
                                if (genreId2 == y) {
                                  isAv2 = 1;
                                  break;
                                }
                              }
                              if (isAv2 == 1) {
                                if( genreData[genereIndex]['name'] == null){
                                }else{
                                  return "${genreData[genereIndex]['name']}";
                                }
                              }
                              return null;
                            }),

                        seasons: List<Seasons>.generate(se== null ? 0 : se.length, (int seasonIndex){
                          if(type == "T"){
                            return Seasons(
                              id: se[seasonIndex]['id'],
                              sTvSeriesId: se[seasonIndex]['tv_series_id'],
                              sSeasonNo: se[seasonIndex]['season_no'],
                              thumbnail: se[seasonIndex]['thumbnail'],
                              cover: se[seasonIndex]['poster'],
                              description: se[seasonIndex]['detail'],
                              sActorId: se[seasonIndex]['actor_id'],
                              language: se[seasonIndex]['a_language'],
                              type: se[seasonIndex]['type'],
                            );
                          } else{
                            return null;
                          }
                        }
                        ),

                        comments: List<CommentsModel>.generate(
                            idTM == null ? 0 : idTM.length, (int comIndex){
                          return CommentsModel(
                            id: idTM[comIndex]['id'],
                            cComment: idTM[comIndex]['comment'],
                            cMovieId: idTM[comIndex]['movie_id'],
                            cEmail: idTM[comIndex]['email'],
                            cName: idTM[comIndex]['name'],
                            cTvSeriesId: idTM[comIndex]['tv_series_id'],
                            cCreatedAt: idTM[comIndex]['created_at'],
                            cUpdatedAt: idTM[comIndex]['updated_at'],
                          );
                        }),
                        maturityRating: '${data1[index]['maturity_rating']}',
                        aLang: '${data1[index]['a_language']}'
                    );
                  }
                  );

                  allDataList.add(newVideosTM);
//                  print(newVideosTM);

                  tmList = List.generate( newVideosTM == null ? 0 : newVideosTM.length, (mIndex) {
                    if(type == widget.type){
                      return GridVideoContainer(context, newVideosTM[mIndex]);
                    }else{
                      return null;
                    }
                   });
                  tmList.removeWhere((value) => value == null);

                  return tmList.length == 0 ? SizedBox.shrink() : GridView.count(
                      padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: ClampingScrollPhysics(),
                      crossAxisCount: 3,
                      childAspectRatio: 18/28,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 8.0,
                      children: tmList
                  );
                })
        ),
      );
  }

}

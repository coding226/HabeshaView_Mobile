import 'package:flutter/material.dart';
import 'package:next_hour/global.dart';
import 'package:next_hour/model/video_data.dart';
import 'package:next_hour/ui/grid_video_container.dart';

class GridVideosPage extends StatefulWidget {

  GridVideosPage(this.genreName, this.genreId, this.dataItems);
  final genreId;
  final genreName;
  final List<VideoDataModel> dataItems;

  @override
  _GridVideosPageState createState() => _GridVideosPageState();
}

class _GridVideosPageState extends State<GridVideosPage> {

  List<Widget> genreList;
  Widget appBar(){
    return AppBar(
      title: Text('${widget.genreName}', style: TextStyle(
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

    genreList = List.generate( widget.dataItems == null ? 0 : widget.dataItems.length,
            (index) {
          var isAv = 0;
          for(var i=0; i<widget.dataItems[index].genre.length; i++ ){
            var genreListIndex = widget.dataItems[index].genre;

            if(widget.genreId == genreListIndex[i]) {
              isAv = 1;
              break;
            }
          }
          if(isAv == 1){
            return GridVideoContainer(context,widget.dataItems[index]);
          }else {
            return null;
          }
        });
    genreList.removeWhere((value) => value == null);


    return Scaffold(
      appBar: appBar(),
      body: GridView.count(
        padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: ClampingScrollPhysics(),
        crossAxisCount: 3,
        childAspectRatio: 18/28,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 8.0,
        children: genreList
      )
    );
  }

}

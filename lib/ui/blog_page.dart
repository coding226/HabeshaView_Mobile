import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:next_hour/apidata/apidata.dart';
import 'package:next_hour/global.dart';
import 'package:next_hour/ui/blog_details.dart';

class BlogPage extends StatefulWidget {
  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  var blogId;

  Widget appBar(){
    return AppBar(
      title: Text("Blog", style: TextStyle(fontSize: 16.0),),
      centerTitle: true,
      backgroundColor: primaryDarkColor.withOpacity(0.98),
    );
  }

  Widget blogDetails(index) {
   String str = "${blogResponse[index]['detail']}";
   String matches = str.replaceAll(new RegExp(r'[<p>\/]+'),'');
    return Row(
      children: <Widget>[
        Flexible(
          child: Container(
            padding: EdgeInsets.only(right: 13.0),
            child: Text(
              '$matches',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: whiteColor.withOpacity(0.6)),
            ),
          ),
        ),
      ],
    );
  }

  List buildCards(int count){
    List<InkWell> cards = List.generate(count, (index){
      blogId = blogResponse[index]['id'];
      return InkWell(
        child: Card(
          color: primaryDarkColor,
          child: Container(
            height: 100.0,
            padding: EdgeInsets.only(left: 10.0, right: 5.0, top: 10.0, bottom: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: AutoSizeText(
                          blogResponse[index]['title'],
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(height: 8.0,),
                      blogDetails(index),
                    ],
                  ),
                ),
                SizedBox(
                  width: 15.0,
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 100.0,
                    width: 100.0,
                    alignment: FractionalOffset.topCenter,
                    child: ClipRRect(
                      borderRadius:
                      new BorderRadius.circular(1.0),
                      child: new FadeInImage.assetNetwork(
                        image: APIData.blogImageUri+"${blogResponse[index]['image']}",
                        placeholder: "assets/placeholder_box.jpg",
                        height: 100.0,
                        width: 100.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
              ],
            ),),
        ),
        onTap: (){
          var router = new MaterialPageRoute(
              builder: (BuildContext context) =>
              new BlogDetailsPage(index, blogResponse[index]['id']));
          Navigator.of(context).push(router);
        },
      );
    });
    return cards;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: blogResponse.length == null ?
        Container(
          child: Center(
            child: Text("No Blog Available"),
          ),
        ) : buildCards(blogResponse.length),
      ),
    );
  }
}








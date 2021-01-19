import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:next_hour/apidata/apidata.dart';
import 'package:next_hour/global.dart';
import 'package:html/dom.dart' as dom;
import 'package:next_hour/model/blog_comments.dart';
import 'package:share/share.dart';

class BlogDetailsPage extends StatefulWidget {
  BlogDetailsPage(this.index, this.blogId);
  final index;
  final blogId;

  @override
  _BlogDetailsPageState createState() => _BlogDetailsPageState();
}

class _BlogDetailsPageState extends State<BlogDetailsPage> {
  final TextEditingController commentsController = new TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  int commentsCount = 0;
  List<BlogComments> ls;

  Widget appBar(){
    return AppBar(
      title: Text("Blog Details", style: TextStyle(fontSize: 16.0),),
      centerTitle: true,
      backgroundColor: primaryDarkColor.withOpacity(0.98),
    );
  }

  void getComments(){
    ls = List<BlogComments>.generate(commentsCount == null ? 0 : commentsCount, (int mComIndex){
      print(blogComments[mComIndex]['comment']);
        return BlogComments(
            id: blogComments[mComIndex]['id'],
            cName: blogComments[mComIndex]['name'],
            cEmail: blogComments[mComIndex]['email'],
            cBlogId: blogComments[mComIndex]['blog_id'],
            cComment: blogComments[mComIndex]['comment'],
            cCreatedAt: blogComments[mComIndex]['created_at'],
            cUpdatedAt: blogComments[mComIndex]['updated_at'],
        );
      }
    );
  }

//  List commentsList(int count){
//    List<Container> commentsReply = List.generate(count, (index){
//      return Container(
//        child: Column(
//          crossAxisAlignment: CrossAxisAlignment.center,
//          mainAxisAlignment: MainAxisAlignment.start,
//          children: <Widget>[
//            SizedBox(height: 10.0,),
//            Row(
//              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//              children: <Widget>[
//                Text(blogComments[index]['name'], style: TextStyle(fontSize: 18.0),),
//              ],
//            ),
//            SizedBox(height: 3.0),
//            Row(
//              children: <Widget>[
//                Text(blogComments[index]['comment'], style: TextStyle(fontSize: 12.0,
//                    color: whiteColor.withOpacity(0.6)),
//                ),
//              ],
//            ),
//          ],
//        ),
//      );
//    });
//    return commentsReply;
//  }

//  Future <String> postComment() async{
//
//    final postCommentResponse = await http.post(APIData.postBlogComment, body: {
//      "type": 'B',
//      "id": '${widget.blogId}',
//      "comment": '${commentsController.text}',
//      "name": '$name',
//      "email": '$email',
//    },
//        headers: {
//          // ignore: deprecated_member_use
//          HttpHeaders.AUTHORIZATION: fullData,
//        });
//
//    if(postCommentResponse.statusCode == 200){
////      print(postCommentResponse);
//      Fluttertoast.showToast(msg: "Commented Successfully");
//      commentsController.text = '';
//      Navigator.pop(context);
//    }else{
//      Fluttertoast.showToast(msg: "Error in commenting");
//      commentsController.text = '';
//      Navigator.pop(context);
//    }
//
//    return null;
//  }

  _updateComments(){
    setState(() {
      commentsCount = commentsCount + 1;
    });
  }


  Future <String> postComment() async{
      final postCommentResponse = await http.post(APIData.postBlogComment, body: {
        "type": 'B',
        "id": '${widget.blogId}',
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
      ls.add(BlogComments(cBlogId: '${widget.blogId}', cName: name, cEmail: email, cComment: commentsController.text));
      _updateComments();

      setState(() {
        commentsCount = ls.length;
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

  Widget comments(){
    return ListView.builder(
        itemCount: this.commentsCount,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, index) => this._buildRow(index));
  }

  _buildRow(int position) {
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
    setState(() {
      commentsCount = blogResponse[widget.index]['comments'].length;
    });
    blogComments = blogResponse[widget.index]['comments'];
    getComments();

  }

  Widget blogDetails(){
    return Html(
      data: blogResponse[widget.index]['detail'] == null ?
      """</div>""" :
      """${blogResponse[widget.index]['detail']}</div>""",
      customTextAlign: (dom.Node node) {
        if (node is dom.Element) {
          switch (node.localName) {
            case "p":
              return TextAlign.start;
          }
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                    height: 300,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius:
                      new BorderRadius.circular(8.0),
                      child: new FadeInImage.assetNetwork(
                        image: APIData.blogImageUri+"${blogResponse[widget.index]['image']}",
                        placeholder: "assets/placeholder_box.jpg",
                        height: 60.0,
                        width: 60.0,
                        fit: BoxFit.cover,
                      ),
                    )
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(children: <Widget>[
                    Expanded(
                      child: blogResponse[widget.index]['updated_at'] == null ? SizedBox.shrink():
                      Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(blogResponse[widget.index]['updated_at']))),
                    ),
                    IconButton(icon: Icon(Icons.share), onPressed: (){
                      Share.share(blogResponse[widget.index]['title']);
                    },)
                  ],),
                  Text(blogResponse[widget.index]['title'], style: Theme.of(context).textTheme.title,),
                  Divider(),
                  SizedBox(height: 10.0,),
                  Row(children: <Widget>[
                    Icon(Icons.comment),
                    SizedBox(width: 5.0,),
                    Text("$commentsCount"),
                  ],),
                  SizedBox(height: 10.0,),
                  blogDetails(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Comments", textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.0),
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
                  Text(""),
                ],
              ),
            ),
          ],
        ),

      ),
    );
  }
}
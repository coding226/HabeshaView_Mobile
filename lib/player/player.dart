import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:next_hour/apidata/apidata.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import '../global.dart';
class PlayerMovie extends StatefulWidget {
  PlayerMovie({this.id, this.type});
  final int id;
  final String type;
  @override
  _PlayerMovieState createState() => _PlayerMovieState();
}
class _PlayerMovieState extends State<PlayerMovie> with WidgetsBindingObserver{
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();
  WebViewController _controller1;
  var playerResponse;
  var status;
  GlobalKey sc = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    this.loadLocal();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    super.dispose();
  }


  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        print("1000");
        _controller1?.reload();
//        Navigator.pop(context);
        break;
      case AppLifecycleState.paused:
        print("1001");
        _controller1?.reload();
//        Navigator.pop(context);
        break;
      case AppLifecycleState.resumed:
        print("1003");
//        Navigator.pop(context);
        break;
      case AppLifecycleState.detached:
        // TODO: Handle this case.
        break;
    }
  }

  Future<String> loadLocal() async {
    playerResponse = await http.get(widget.type == 'T'
        ? APIData.tvSeriesPlayer + '$userId/$code/$ser'
        : APIData.moviePlayer + '$userId/$code/${widget.id}');
    print("status: ${playerResponse.statusCode}");
    setState(() {
      status = playerResponse.statusCode;
    });
    var responseUrl = playerResponse.body;
    return responseUrl;
  }
  @override
  Widget build(BuildContext context) {
    print( widget.type == 'T'
        ? APIData.tvSeriesPlayer + '$userId/$code/$ser'
        : APIData.moviePlayer +
        '$userId/$code/${widget.id}');

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
      return JavascriptChannel(
          name: 'Toaster',
          onMessageReceived: (JavascriptMessage message) {
            Scaffold.of(context).showSnackBar(
              SnackBar(content: Text(message.message)),
            );
          });
    }
    return Scaffold(
          key: sc,
          body: Stack(
            children: <Widget>[
             Container(
                width: width,
                height: height,
                child: WebView(
                    initialUrl: widget.type == 'T'
                        ? APIData.tvSeriesPlayer + '$userId/$code/$ser'
                        : APIData.moviePlayer +
                        '$userId/$code/${widget.id}',
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller1 = webViewController;
                    },
                    javascriptChannels: <JavascriptChannel>[
                      _toasterJavascriptChannel(context),
                    ].toSet()
                )
              ),
//              new Positioned(
//                top: 26.0,
//                left: 4.0,
//                child: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed:(){
//                  _controller1?.reload();
//                  Navigator.pop(context);
//                }),
////              child: new BackButton(color: Colors.white),
//              ),
            ],
          ));
//    );
  }
}


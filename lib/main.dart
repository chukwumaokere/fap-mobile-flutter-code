import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart' as URL_Launcher;

//String url = 'https://crm.fapaluminum.com/warehouse';
String url = "https://devl06.borugroup.com/cokere/new-app/#!/login";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Webview',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Webview'),
      routes: {
        "/webview": (_) => WebviewScaffold(
              url: url,
/*
appBar: AppBar(
title: Text("Webview"),
),
*/
              withJavascript: true,
              withLocalStorage: true,
              withZoom: true,
            )
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  NewWeb createState() => NewWeb();
}

class NewWeb extends State<MyHomePage> {
  final webview = FlutterWebviewPlugin();
  

  TextEditingController controller = TextEditingController(text: url);

  @override
  Widget build(BuildContext context) {
// TODO: implement build
    return Scaffold(
      //Navigator.of(context).pushNamed("/webview")
      
      appBar: AppBar(
//title: Text("Webview"),
          ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: controller,
              ),
            ),
            RaisedButton(
              child: Text("Open Webview"),
              onPressed: () {
                Navigator.of(context).pushNamed("/webview");
              },
            )
          ],
        ),
      ),
    );
    return null;
  }

  @override
  void initState() {
// TODO: implement initState
    super.initState();
    webview.close();
    webview.launch(url);
    //webview.onStateChanged
    webview.onUrlChanged.listen((String url){
        if(url.contains('tel')){
          // need to stop loading at this point so it doesnt show net
          URL_Launcher.launch(url);
          webview.goBack();
        }
    });
    controller.addListener(() {
      url = controller.text;
    });
  }

  @override
  void dispose() {
// TODO: implement dispose
    webview.dispose();
    controller.dispose();
    super.dispose();
  }
}
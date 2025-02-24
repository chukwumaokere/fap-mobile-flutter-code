import 'dart:async';
import 'package:url_launcher/url_launcher.dart' as URL_Launcher;
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/services.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

const kAndroidUserAgent =
    'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';

String selectedUrl = 'https://crm.fapaluminum.com/new-app/#!/';

// ignore: prefer_collection_literals
final Set<JavascriptChannel> jsChannels = [
  JavascriptChannel(
      name: 'Print',
      onMessageReceived: (JavascriptMessage message) {
        if(message.message == 'callSupport'){
          print(message.message);
          launchPhone();
        }else{
          print(message.message);
        }
      }),
].toSet();

launchPhone(){
  URL_Launcher.launch("tel:19547732898");
}

void main() {
  SafeArea(child: MyApp(),top: true,);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.blueAccent[300],
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(MyApp());
  SafeArea(child: MyApp(),top: true,);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.blueAccent[300],
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
  ));
}

class MyApp extends StatelessWidget {
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter WebView Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
       // '/': (_) => const MyHomePage(title: 'Flutter WebView Demo'),
        '/': (_) {
          return WebviewScaffold(
            url: selectedUrl,
            javascriptChannels: jsChannels,
            withZoom: true,
            withLocalStorage: true,
            withJavascript: true,
            hidden: true,
            scrollBar: false,
          );
        },
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Instance of WebView plugin
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  //FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  /* 
  void firebaseCloudMessagingListeners() {
  if (Platform.isIOS) iOSPermission();

  _firebaseMessaging.getToken().then((token){
    print(token);
  });

  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      print('on message $message');
    },
    onResume: (Map<String, dynamic> message) async {
      print('on resume $message');
    },
    onLaunch: (Map<String, dynamic> message) async {
      print('on launch $message');
    },
  );
}

void iOSPermission() {
  _firebaseMessaging.requestNotificationPermissions(
      IosNotificationSettings(sound: true, badge: true, alert: true)
  );
  _firebaseMessaging.onIosSettingsRegistered
      .listen((IosNotificationSettings settings)
  {
    print("Settings registered: $settings");
  });
} */

  // On destroy stream
  StreamSubscription _onDestroy;

  // On urlChanged stream
  StreamSubscription<String> _onUrlChanged;

  // On urlChanged stream
  StreamSubscription<WebViewStateChanged> _onStateChanged;

  StreamSubscription<WebViewHttpError> _onHttpError;

  StreamSubscription<double> _onProgressChanged;

  StreamSubscription<double> _onScrollYChanged;

  StreamSubscription<double> _onScrollXChanged;

  final _urlCtrl = TextEditingController(text: selectedUrl);

  final _codeCtrl = TextEditingController(text: 'window.navigator.userAgent');

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _history = [];

  @override
  void initState() {
    super.initState();
    //firebaseCloudMessagingListeners();

    flutterWebViewPlugin.close();
    flutterWebViewPlugin.resize(Rect.fromLTRB(
              MediaQuery.of(context).padding.left, /// for safe area
              MediaQuery.of(context).padding.top, /// for safe area
              MediaQuery.of(context).size.width + 1, /// add one to make it fullscreen
              MediaQuery.of(context).size.height,
            ));
    flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
          if(state.type == WebViewState.finishLoad) {
            flutterWebViewPlugin.resize(Rect.fromLTRB(
              MediaQuery.of(context).padding.left, /// for safe area
              MediaQuery.of(context).padding.top, /// for safe area
              MediaQuery.of(context).size.width + 1, /// add one to make it fullscreen
              MediaQuery.of(context).size.height,
            ));
          }
          print('state changing to: ${state.type}');
    });

    flutterWebViewPlugin.onStateChanged.listen((state) async {
      print('state changing to: ${state.type}');
    });

    _urlCtrl.addListener(() {
      selectedUrl = _urlCtrl.text;
    });

    // Add a listener to on destroy WebView, so you can make came actions.
    _onDestroy = flutterWebViewPlugin.onDestroy.listen((_) {
      if (mounted) {
        // Actions like show a info toast.
        _scaffoldKey.currentState.showSnackBar(
            const SnackBar(content: const Text('Webview Destroyed')));
      }
    });

    // Add a listener to on url changed
    _onUrlChanged = flutterWebViewPlugin.onUrlChanged.listen((String url) {
      print('hi');
      if (mounted) {
        setState(() {
          _history.add('onUrlChanged: $url');
        });
      }
    });

    _onProgressChanged =
        flutterWebViewPlugin.onProgressChanged.listen((double progress) {
      if (mounted) {
        setState(() {
          _history.add('onProgressChanged: $progress');
        });
      }
    });

    _onScrollYChanged =
        flutterWebViewPlugin.onScrollYChanged.listen((double y) {
      if (mounted) {
        setState(() {
          _history.add('Scroll in Y Direction: $y');
        });
      }
    });

    _onScrollXChanged =
        flutterWebViewPlugin.onScrollXChanged.listen((double x) {
      if (mounted) {
        setState(() {
          _history.add('Scroll in X Direction: $x');
        });
      }
    });
    

    _onStateChanged =
        flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
          if(state.type == WebViewState.finishLoad) {
            flutterWebViewPlugin.resize(Rect.fromLTRB(
              MediaQuery.of(context).padding.left, /// for safe area
              MediaQuery.of(context).padding.top, /// for safe area
              MediaQuery.of(context).size.width + 1, /// add one to make it fullscreen
              MediaQuery.of(context).size.height,
            ));
          }
          print('state changing to: ${state.type}');
      if (mounted) {
        setState(() {
          _history.add('onStateChanged: ${state.type} ${state.url}');
        });
      }
    });

    _onHttpError =
        flutterWebViewPlugin.onHttpError.listen((WebViewHttpError error) {
      if (mounted) {
        setState(() {
          _history.add('onHttpError: ${error.code} ${error.url}');
        });
      }
    });
  }

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onDestroy.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    _onHttpError.cancel();
    _onProgressChanged.cancel();
    _onScrollXChanged.cancel();
    _onScrollYChanged.cancel();

    flutterWebViewPlugin.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              child: TextField(controller: _urlCtrl),
            ),
            RaisedButton(
              onPressed: () {
                flutterWebViewPlugin.launch(
                  selectedUrl,
                  rect: Rect.fromLTWH(
                      0.0, 0.0, MediaQuery.of(context).size.width, 300.0),
                  userAgent: kAndroidUserAgent,
                  invalidUrlRegex:
                      r'^(https).+(twitter)', // prevent redirecting to twitter when user click on its icon in flutter website
                );
              },
              child: const Text('Open Webview (rect)'),
            ),
            RaisedButton(
              onPressed: () {
                flutterWebViewPlugin.launch(selectedUrl, hidden: true);
              },
              child: const Text('Open "hidden" Webview'),
            ),
            RaisedButton(
              onPressed: () {
                flutterWebViewPlugin.launch(selectedUrl);
              },
              child: const Text('Open Fullscreen Webview'),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/widget');
              },
              child: const Text('Open widget webview'),
            ),
            Container(
              padding: const EdgeInsets.all(24.0),
              child: TextField(controller: _codeCtrl),
            ),
            RaisedButton(
              onPressed: () {
                final future =
                    flutterWebViewPlugin.evalJavascript(_codeCtrl.text);
                future.then((String result) {
                  setState(() {
                    _history.add('eval: $result');
                  });
                });
              },
              child: const Text('Eval some javascript'),
            ),
            RaisedButton(
              onPressed: () {
                setState(() {
                  _history.clear();
                });
                flutterWebViewPlugin.close();
              },
              child: const Text('Close'),
            ),
            RaisedButton(
              onPressed: () {
                flutterWebViewPlugin.getCookies().then((m) {
                  setState(() {
                    _history.add('cookies: $m');
                  });
                });
              },
              child: const Text('Cookies'),
            ),
            Text(_history.join('\n'))
          ],
        ),
      ),
    );
  }
}
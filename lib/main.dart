import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_expander/WebViewWidget.dart';
import 'package:url_expander/goUrlExpanderClient.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const UrlExpanderApp());
}

class UrlExpanderApp extends StatelessWidget {
  static const ValueKey<String> externalBrowserButtonId =
      ValueKey('EXTERNAL_BROWSER_BUTTON_ID');

  static const ValueKey<String> internalBrowserButtonId =
      ValueKey('INTERNAL_BROWSER_BUTTON_ID');

  static const ValueKey<String> copyButtonId = ValueKey('COPY_BUTTON_ID');

  static const ValueKey<String> shareButtonId = ValueKey('SHARE_BUTTON_ID');

  const UrlExpanderApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URL Expander',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.indigo,
      ),
      home: const MyHomePage(title: 'URL Expander'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  static const platform = MethodChannel('app.channel.shared.data');
  String url = 'NO DATA';
  String expanded = '';

  void getSharedData() async {
    developer.log('CALLING getSharedData');
    var sharedData = await platform.invokeMethod('getSharedText');
    if (sharedData != null) {
      setState(() {
        url = sharedData;
      });
      var expandedUrl = await GoUrlExpanderClient.getUrlExpanded(url);
      setState(() {
        expanded = expandedUrl!;
      });
    }
  }

  void getUrlExpanded(String url) async {
    if (url == 'NO DATA') {
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    getSharedData();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(MyHomePage old) {
    super.didUpdateWidget(old);
    setState(() {
      url = '';
      expanded = '';
    });
    getSharedData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      setState(() {
        url = '';
        expanded = '';
      });
      getSharedData();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      SystemNavigator.pop(animated: false);
    }
  }

  bool shouldClickEnabled() {
    return expanded != '';
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                url,
              ),
              InkWell(
                child: Text(
                  expanded,
                  style: const TextStyle(
                      decoration: TextDecoration.underline, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FloatingActionButton(
                key: UrlExpanderApp.copyButtonId,
                tooltip: 'Copy to clipboard',
                onPressed: shouldClickEnabled()
                    ? () async {
                        Clipboard.setData(ClipboardData(text: expanded));
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Copied")));
                      }
                    : null,
                child: const Icon(Icons.copy),
              ),
              FloatingActionButton(
                  key: UrlExpanderApp.shareButtonId,
                  tooltip: 'Share',
                  onPressed: shouldClickEnabled()
                      ? () async {
                          SharePlus.instance.share(ShareParams(
                            title: 'Open with',
                            uri: Uri.parse(expanded)
                          ));
                        }
                      : null,
                  child: const Icon(Icons.offline_share)),
              FloatingActionButton(
                key: UrlExpanderApp.externalBrowserButtonId,
                tooltip: 'Open external Browser',
                onPressed: shouldClickEnabled()
                    ? () async {
                        var url = Uri.parse(expanded);
                        launchUrl(url,
                            mode: LaunchMode.externalNonBrowserApplication);
                      }
                    : null,
                child: const Icon(Icons.open_in_new),
              ),
              FloatingActionButton(
                key: UrlExpanderApp.internalBrowserButtonId,
                tooltip: 'Open Web ( internal )',
                onPressed: shouldClickEnabled()
                    ? () async {
                        var url = Uri.parse(expanded);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ExpanderWebViewWidget(url: url.toString())));
                      }
                    : null,
                child: const Icon(Icons.open_in_browser),
              )
            ],
          ),
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}

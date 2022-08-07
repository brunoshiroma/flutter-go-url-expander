import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewWidget extends StatelessWidget {

  final String? url;

  const WebViewWidget({Key? key, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: WebView(
          initialUrl: url,
          allowsInlineMediaPlayback: true,
          javascriptMode: JavascriptMode.unrestricted,
        )
    );
  }
}

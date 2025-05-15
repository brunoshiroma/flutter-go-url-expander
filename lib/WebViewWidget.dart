import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ExpanderWebViewWidget extends StatelessWidget {

  final String? url;

  const ExpanderWebViewWidget({Key? key, this.url}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url!));

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: WebViewWidget(controller: controller)
    );
  }
}

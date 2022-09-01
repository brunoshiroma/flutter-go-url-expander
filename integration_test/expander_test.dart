import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:url_expander/main.dart';

void main(){

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Integration Test url expander widget', (tester) async {

    const pluginChannel = MethodChannel('app.channel.shared.data');

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(pluginChannel, (message) async {
      switch(message.method){
        case 'getSharedText':
          return 'https://github.com/brunoshiroma/url_expander';
        default:
          return null;
      }
    });

    await tester.pumpWidget(const UrlExpanderApp(), const Duration(seconds: 10));

    TestWidgetsFlutterBinding.ensureInitialized();

    expect(find.byKey(UrlExpanderApp.copyButtonId), findsOneWidget);
    expect(find.byKey(UrlExpanderApp.externalBrowserButtonId), findsOneWidget);
    expect(find.byKey(UrlExpanderApp.internalBrowserButtonId), findsOneWidget);
    expect(find.byKey(UrlExpanderApp.shareButtonId), findsOneWidget);
    expect(find.text('NO DATA'), findsOneWidget);
  });

}
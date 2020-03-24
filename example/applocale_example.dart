import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:applocale/applocale.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// define supported Language lists
Map<String, String> get _supportedLanguages =>
    <String, String>{"en": "English", "en_us": "English(USA)", "ar": "Arabic"};
String get _defaultLanguage => "en";

void main(List<String> args) => runApp(FlutterDemoApp());

class FlutterDemoApp extends StatefulWidget {
  @override
  _FlutterDemoApp createState() => _FlutterDemoApp();
}

class _FlutterDemoApp extends State<FlutterDemoApp> {
  LocaleDelegate _localeDelegate;

  List<String> _getSupportedLanguages() =>
      _supportedLanguages.entries.map((l) => l.key).toList();

  @override
  void initState() {
    super.initState();
    // initialize _localeDelegate
    _localeDelegate =
        LocaleDelegate.init(_getSupportedLanguages(), _defaultLanguage);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        supportedLocales: _localeDelegate.supportedLocales, // Step I
        localizationsDelegates: [
          _localeDelegate, // Step II
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        title: 'Flutter Demo',
        home: FlutterDemo(),
      );
}

class FlutterDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // since LocaleDelegate is already initialized & ready
    var appLocale = LocaleDelegate.of(context); // Step III

    return Scaffold(
      appBar: AppBar(title: Text(appLocale.localValue('title'))),
      body: ListView(
        children: <Widget>[
          Center(child: Text(appLocale.localValue('Message'))),
        ],
      ),
    );
  }
}

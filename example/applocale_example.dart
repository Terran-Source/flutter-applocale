import 'package:flutter/material.dart';

import 'package:applocale/applocale.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// define supported Language lists
Map<String, String> get _supportedLanguages => {
      "en": "English",
      "en_us": "English(USA)",
      "bn": "Bengali",
    };
String get _defaultLanguage => "en";
List<String> get _getSupportedLanguages =>
    _supportedLanguages.entries.map((l) => l.key).toList();

void main(List<String> args) => runApp(FlutterDemoApp());

class FlutterDemoApp extends StatefulWidget {
  @override
  _FlutterDemoApp createState() => _FlutterDemoApp();
}

class _FlutterDemoApp extends State<FlutterDemoApp> {
  // initialize _localeDelegate
  LocaleDelegate _localeDelegate = LocaleDelegate.init(
    _getSupportedLanguages,
    // * optional, if it's same as the first one in the supportedLanguages
    defaultLanguage: _defaultLanguage,
  );

  @override
  void initState() {
    super.initState();
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
    var appLocale = AppLocale.of(context); // Step III
    // In case some additional values can be set now. This is an one time
    // activity
    appLocale.updateValue({'name': 'জয়ন্তী'});

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocale.localValue('title')),
      ),
      body: ListView(
        children: <Widget>[
          Center(
            child: Text(appLocale.localValue('subDetail.greeting')),
          ),
          Center(
            child: Text(appLocale.localValue(
              'subDetail.runtimeText',
              {'replacement': 'Individual'}, // runtime interpolation
            )),
          ),
          Center(
            child: Text(appLocale.localValue('message')),
          ),
        ],
      ),
    );
  }
}

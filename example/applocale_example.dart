import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:applocale/applocale.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Map<String, Locale> get _supportedLanguages => <String, Locale>{
      "English": getLocale("en"),
      "English(USA)": getLocale("en_us"),
      "Arabic": getLocale('ar')
    };
Locale get _defaultLocale => getLocale("en");
LocaleDelegate _localeDelegate;

void main(List<String> args) => runApp(FlutterDemoApp());

class FlutterDemoApp extends StatefulWidget {
  @override
  _FlutterDemoApp createState() => _FlutterDemoApp();
}

class _FlutterDemoApp extends State<FlutterDemoApp> {
  List<Locale> _supportedLocales() =>
      _supportedLanguages.entries.map((l) => l.value).toList();

  @override
  void initState() {
    super.initState();
    _localeDelegate = LocaleDelegate(_supportedLocales(), _defaultLocale);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        supportedLocales: _supportedLocales(),
        localizationsDelegates: [
          _localeDelegate,
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
    var appLocale = LocaleDelegate.of(context);

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

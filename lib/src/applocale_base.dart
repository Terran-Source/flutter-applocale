import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

import 'applocale_utility.dart';

class LocaleDelegate extends LocalizationsDelegate<AppLocale> {
  bool reload = true;
  Locale _currentLocale;
  final Locale _defaultLocale;
  final String _defaultContainerDirectory;
  final List<Locale> _supportedLocales;
  static LocaleDelegate _cache;

  // event handler to
  LocaleChangeCallback onLocaleChange;

  LocaleDelegate._init(this._supportedLocales, this._defaultLocale,
      this._defaultContainerDirectory)
      : assert(_supportedLocales.any((l) => l == _defaultLocale));

  factory LocaleDelegate(List<Locale> supportedLocales,
      [Locale defaultLocale, String defaultContainerDirectory = 'i18n']) {
    if (null == _cache) {
      _cache = LocaleDelegate._init(
          supportedLocales, defaultLocale, defaultContainerDirectory);
    }
    return _cache;
  }

  Locale _getSupportedLocale(Locale locale) {
    if (null == _supportedLocales) return null;

    // find the actual match
    var result =
        _supportedLocales.firstWhere((l) => l == locale, orElse: () => null);
    if (null != result) return result;

    // find the match with same name in lowercase
    result = _supportedLocales.firstWhere(
        (l) => l.toString().toLowerCase() == locale.toString().toLowerCase(),
        orElse: () => null);
    if (null != result) return result;

    // find the one with same languageCode but without any countryCode or scriptCode
    result = _supportedLocales.firstWhere(
        (l) =>
            (l.countryCode?.isEmpty ?? true) &&
            (l.scriptCode?.isEmpty ?? true) &&
            l.languageCode == locale.languageCode,
        orElse: () => null);
    if (null != result) return result;

    // find the one with same languageCode
    result = _supportedLocales.firstWhere(
        (l) => l.languageCode == locale.languageCode,
        orElse: () => null);
    if (null != result) return result;

    // if all fails
    return null;
  }

  @override
  bool isSupported(Locale locale) => null != _getSupportedLocale(locale);

  @override
  Future<AppLocale> load(Locale locale) async {
    locale = _getSupportedLocale(locale);
    return AppLocale.load(
        _defaultContainerDirectory, _currentLocale ?? locale, _defaultLocale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocale> old) {
    reload = !reload;
    return !reload;
  }

  Locale changeLocale(Locale locale) {
    _currentLocale = _getSupportedLocale(locale);
    reload = null != _currentLocale;
    if (reload) onLocaleChange(_currentLocale);
    return _currentLocale;
  }

  static AppLocale of(BuildContext context) =>
      Localizations.of<AppLocale>(context, AppLocale);
}

class AppLocale {
  final Locale locale;
  static final Map<String, AppLocale> _cache = <String, AppLocale>{};
  Map<String, dynamic> _values;
  bool _isLoaded = false;

  AppLocale._init(this.locale);

  factory AppLocale(Locale locale) => _cache.putIfAbsent(
      locale.toString().toLowerCase(), () => AppLocale._init(locale));

  static String _getAssetPath(String defaultContainerDirectory,
          String assetName, String extension) =>
      path.join(defaultContainerDirectory, '$assetName.$extension');

  static Future<Map<String, dynamic>> _getAssetJson(
          String defaultContainerDirectory, String assetName,
          [String extension = 'json']) async =>
      json.decode(await rootBundle.loadString(
          _getAssetPath(defaultContainerDirectory, assetName, extension)));

  static Future<AppLocale> load(String defaultContainerDirectory, Locale locale,
      [Locale defaultLocale]) async {
    var appLocale = AppLocale(locale);
    if (!appLocale._isLoaded) {
      appLocale._values = await _getAssetJson(
          defaultContainerDirectory, appLocale.locale.toString());
      if (null != defaultLocale && appLocale.locale != defaultLocale) {
        var defaultValues = await _getAssetJson(
            defaultContainerDirectory, defaultLocale.toString());
        defaultValues.forEach((key, obj) {
          var keyCode = key.toString();
          appLocale._values[keyCode] ??= defaultValues[keyCode];
        });
      }
      appLocale._isLoaded = true;
    }
    return appLocale;
  }

  static LocalizationsDelegate<AppLocale> delegate(
          List<Locale> supportedLocales,
          [Locale defaultLocale,
          String defaultContainerDirectory]) =>
      LocaleDelegate(
          supportedLocales, defaultLocale, defaultContainerDirectory);

  String get currentLocale => locale.toString();

  String localValue(String key) {
    dynamic result;
    // if dynamic traversal is required
    if (key.contains('.')) {
      var keys = key.split('.');
      var initObj = _values[keys[0]];
      result = keys.skip(1).fold(initObj, (parent, k) => parent[k] ?? null);
    } else // else, retrieve direct value
      result = _values[key];
    return result?.toString() ?? '';
  }
}

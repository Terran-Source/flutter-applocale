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
  final String _defaultLanguageDirectory;
  final List<Locale> _supportedLocales;
  static LocaleDelegate _cache;

  List<Locale> get supportedLocales => _supportedLocales;

  // event handler to
  LocaleChangeCallback onLocaleChange;

  LocaleDelegate._init(this._supportedLocales, this._defaultLocale,
      this._defaultLanguageDirectory)
      : assert(_supportedLocales.any((l) => l == (_defaultLocale ?? l))),
        assert(null != _defaultLanguageDirectory);

  /// deprecated: use LocaleDelegate.init() instead.
  factory LocaleDelegate(List<Locale> supportedLocales,
      [Locale defaultLocale, String defaultLanguageDirectory = 'i18n']) {
    if (null == _cache) {
      _cache = LocaleDelegate._init(
          supportedLocales, defaultLocale, defaultLanguageDirectory);
    }
    return _cache;
  }

  static LocaleDelegate init(List<String> supportedLanguages,
          [String defaultLanguage, String defaultLanguageDirectory = 'i18n']) =>
      LocaleDelegate(supportedLanguages.map((l) => getLocale(l)).toList(),
          getLocale(defaultLanguage), defaultLanguageDirectory);

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
    _currentLocale ??= locale;
    var appLocale = AppLocale(locale);
    await appLocale.load(
        _defaultLanguageDirectory, _currentLocale, _defaultLocale);
    return appLocale;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocale> old) {
    reload = !reload;
    return !reload;
  }

  Locale changeLocale(Locale locale) {
    var _newLocale = _getSupportedLocale(locale);
    reload = null != _newLocale && _newLocale != _currentLocale;
    if (reload) {
      _currentLocale = _newLocale;
      onLocaleChange(_currentLocale);
    }
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

  String _getAssetPath(String defaultContainerDirectory, String assetName,
          String extension) =>
      path.join(defaultContainerDirectory, '$assetName.$extension');

  Future<Map<String, dynamic>> _getAssetJson(
          String defaultContainerDirectory, String assetName,
          [String extension = 'json']) async =>
      json.decode(await rootBundle.loadString(
          _getAssetPath(defaultContainerDirectory, assetName, extension)));

  Future<bool> load(String defaultContainerDirectory, Locale locale,
      [Locale defaultLocale]) async {
    if (!_isLoaded) {
      _values =
          await _getAssetJson(defaultContainerDirectory, locale.toString());
      if (null != defaultLocale && locale != defaultLocale) {
        var defaultValues = await _getAssetJson(
            defaultContainerDirectory, defaultLocale.toString());
        _values.addAll(defaultValues);
      }
      _isLoaded = true;
    }
    return _isLoaded;
  }

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

  bool updateValue(Map<String, dynamic> newValues) {
    _values.addAll(newValues);
    return true;
  }
}

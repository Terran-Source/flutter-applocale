import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

import 'applocale_utility.dart';

/// A factory to define application level `Localizations`.
///
/// Create an instance using `LocaleDelegate.`[init] & add that to the app's
/// `localizationsDelegates` list.
class LocaleDelegate extends LocalizationsDelegate<AppLocale> {
  bool _reload = true;
  Locale _currentLocale;
  final Locale _defaultLocale;
  final String _defaultLanguageDirectory;
  final List<Locale> _supportedLocales;
  static LocaleDelegate _cache;

  List<Locale> get supportedLocales => _supportedLocales;

  /// Event handler to handle change language on runtime.
  ///
  /// Use this to define the application behavior to handle state change
  LocaleChangeCallback onLocaleChange;

  LocaleDelegate._init(this._supportedLocales, this._defaultLocale,
      this._defaultLanguageDirectory)
      : assert(_supportedLocales.any((l) => l == (_defaultLocale ?? l))),
        assert(null != _defaultLanguageDirectory);

  /// Default Constructor
  ///
  /// deprecated: use `LocaleDelegate.`[init] instead.
  factory LocaleDelegate(List<Locale> supportedLocales,
      [Locale defaultLocale, String defaultLanguageDirectory = 'i18n']) {
    if (null == _cache) {
      _cache = LocaleDelegate._init(
          supportedLocales, defaultLocale, defaultLanguageDirectory);
    }
    return _cache;
  }

  /// Get the base object to use it globally (application-wide).
  ///
  /// [supportedLanguages] is the list of unicode languages,
  /// as attached as json inside [defaultLanguageDirectory] directory
  /// (e.g. ["en", "en_us", "bn"] for the
  /// i18n/en.json, i18n/en_us.json, i18n/bn.json).
  /// {@image <image alt='project_structure' src='https://github.com/Terran-Source/applocale/raw/master/doc/img/project_structure.png'>}
  ///
  /// [defaultLanguage] json values are considered complete.
  /// In case of any supported language translation is not completed,
  /// the [defaultLanguage] json value is taken by default for the incomplete key's.
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
    var appLocale = AppLocale(_currentLocale);
    await appLocale.load(_defaultLanguageDirectory, _defaultLocale);
    return appLocale;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocale> old) {
    _reload = !_reload;
    return !_reload;
  }

  /// To dynamically change the application language without restart.
  ///
  /// It automatically calls the [onLocaleChange].
  Locale changeLocale(Locale locale) {
    var _newLocale = _getSupportedLocale(locale);
    _reload = null != _newLocale && _newLocale != _currentLocale;
    if (_reload) {
      _currentLocale = _newLocale;
      onLocaleChange(_currentLocale);
    }
    return _currentLocale;
  }

  /// Get the current [AppLocale] instance for the [context]
  static AppLocale of(BuildContext context) =>
      Localizations.of<AppLocale>(context, AppLocale);
}

/// The fruit of labour that [LocaleDelegate] produces.
///
/// Get the current instance inside any widget (except the `main` one)
/// through `LocaleDelegate.of(context)` & use [localValue]
/// to get the localized value
class AppLocale {
  /// The application [locale] loaded (or to be loaded).
  final Locale locale;
  static final Map<String, AppLocale> _cache = <String, AppLocale>{};
  Map<String, dynamic> _values;
  bool _isLoaded = false;

  AppLocale._init(this.locale);

  /// Default constructor
  ///
  /// Called internally through `LocaleDelegate.load()`.
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

  /// Load the appropriate json file from asset & parse it.
  ///
  /// Called internally through `LocaleDelegate.load()`.
  Future<bool> load(String defaultContainerDirectory,
      [Locale defaultLocale]) async {
    if (!_isLoaded) {
      _values =
          await _getAssetJson(defaultContainerDirectory, locale.toString());
      if (null != defaultLocale && locale != defaultLocale) {
        var defaultValues = await _getAssetJson(
            defaultContainerDirectory, defaultLocale.toString());
        // take the values from [defaultLocale], not present in [locale]
        defaultValues.addAll(_values);
        _values = defaultValues;
      }
      _isLoaded = true;
    }
    return _isLoaded;
  }

  /// [locale] in unicode string format
  String get currentLocale => locale.toString();

  /// Get the value of the [key] from the provide language json file
  ///
  /// Supports multi-level.
  /// Don't shy to pass `root.sub.subOfSub` as [key] if the json has it.
  String localValue(String key) {
    dynamic result = key
        .split('.')
        .fold(_values, (parent, k) => parent is String ? parent : parent[k]);
    return result?.toString() ?? key;
  }

  /// Some values are not determined until the application starts
  /// (i.e. set during runtime).
  ///
  /// Here additional runtime values can be set or update existing ones.
  bool updateValue(Map<String, dynamic> newValues) {
    _values.addAll(newValues);
    return true;
  }
}

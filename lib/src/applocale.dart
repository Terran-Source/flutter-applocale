import 'dart:async';
import 'dart:convert';

import 'package:extend/extend.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:interpolation/interpolation.dart';
import 'package:path/path.dart' as path;

import 'utility.dart';

/// A factory to define application level `Localizations`.
///
/// Create an instance using `LocaleDelegate.`[init] & add that to the app's
/// `localizationsDelegates` list.
///
/// ```dart
/// // define supported Language lists
/// var get _supportedLanguages => ["en", "en_us", "bn"];
/// var get _defaultLanguage => "en";
///
/// class _FlutterDemoApp extends State<FlutterDemoApp> {
///   LocaleDelegate _localeDelegate = LocaleDelegate.init(
///     _supportedLanguages,
///     // * optional, if it's same as the first one in the supportedLanguages
///     defaultLanguage: _defaultLanguage,
///   );
///
///   @override
///   Widget build(BuildContext context) => MaterialApp(
///     supportedLocales: _localeDelegate.supportedLocales,
///     localizationsDelegates: [
///       _localeDelegate
///     ],
///   );
/// ```
class LocaleDelegate extends LocalizationsDelegate<AppLocale> {
  final List<Locale> _supportedLocales;
  final Locale _defaultLocale;
  final String _defaultLanguageDirectory;

  late Locale _currentLocale;
  bool _reload = true;

  static LocaleDelegate? _cache;

  LocaleDelegate._init(
    this._supportedLocales,
    this._defaultLocale,
    this._defaultLanguageDirectory,
  )   : assert(_supportedLocales.isNotEmpty),
        assert(_supportedLocales.any((l) => l == _defaultLocale));

  /// Default Constructor
  ///
  /// deprecated: use `LocaleDelegate.[init]` instead
  factory LocaleDelegate(
    List<Locale> supportedLocales, {
    Locale? defaultLocale,
    String defaultLanguageDirectory = 'i18n',
  }) {
    if (null == _cache) {
      _cache = LocaleDelegate._init(
        supportedLocales,
        defaultLocale ?? supportedLocales[0],
        defaultLanguageDirectory,
      );
    }
    return _cache!;
  }

  /// Get the base object to use it globally (application-wide).
  ///
  /// [supportedLanguages] is the list of unicode languages, as attached as json
  /// inside [defaultLanguageDirectory] asset directory (e.g. ["en", "en_us", "bn"]
  /// for the i18n/en.json, i18n/en_us.json, i18n/bn.json respectively).
  ///
  /// {@image <image alt='project_structure'
  /// src='https://github.com/Terran-Source/applocale/raw/master/doc/img/project_structure.png'>}
  ///
  /// [defaultLanguage] is the default app language. If not provided, the first
  /// from the [supportedLanguages] will be set as [defaultLanguage]. In case of
  /// any supported language translation is not completed, the [defaultLanguage]
  /// json value is taken by default for the incomplete key's.
  ///
  /// ```dart
  /// // define supported Language lists
  /// var get _supportedLanguages => ["en", "en_us", "bn"];
  /// var get _defaultLanguage => "en";
  ///
  /// class _FlutterDemoApp extends State<FlutterDemoApp> {
  ///   LocaleDelegate _localeDelegate = LocaleDelegate.init(
  ///     _supportedLanguages,
  ///     // *optional, if it's same as the first one in the supportedLanguages
  ///     defaultLanguage: _defaultLanguage,
  ///   );
  ///
  ///   @override
  ///   Widget build(BuildContext context) => MaterialApp(
  ///     supportedLocales: _localeDelegate.supportedLocales,
  ///     localizationsDelegates: [
  ///       _localeDelegate
  ///     ],
  ///   );
  /// ```
  static LocaleDelegate init(
    List<String> supportedLanguages, {
    String? defaultLanguage,
    String defaultLanguageDirectory = 'i18n',
  }) =>
      LocaleDelegate(
        supportedLanguages.map((l) => getLocale(l)).toList(),
        defaultLocale:
            null != defaultLanguage ? getLocale(defaultLanguage) : null,
        defaultLanguageDirectory: defaultLanguageDirectory,
      );

  List<Locale> get supportedLocales => _supportedLocales;

  /// Event handler to handle change language on runtime.
  ///
  /// Use this to define the application behavior to handle state change
  LocaleChangeCallback? onLocaleChange;

  Locale? _getSupportedLocale(Locale locale) {
    try {
      return _supportedLocales.firstWhere(
        // find the actual match
        (l) => l == locale,
        orElse: () => _supportedLocales.firstWhere(
          // find the match with same name in lowercase
          (l) => l.toString().toLowerCase() == locale.toString().toLowerCase(),
          orElse: () => _supportedLocales.firstWhere(
            // find the one with same languageCode but without any countryCode or scriptCode
            (l) =>
                (l.countryCode?.isEmpty ?? true) &&
                (l.scriptCode?.isEmpty ?? true) &&
                l.languageCode == locale.languageCode,
            orElse: () => _supportedLocales.firstWhere(
                // find the one with same languageCode
                (l) => l.languageCode == locale.languageCode),
          ),
        ),
      );
    } catch (_) {
      // if all fails
      return null;
    }
  }

  @override
  bool isSupported(Locale locale) => null != _getSupportedLocale(locale);

  @override
  Future<AppLocale> load(Locale locale) async {
    var supportedLocale = _getSupportedLocale(locale) ?? _defaultLocale;
    _currentLocale = supportedLocale;
    var appLocale = AppLocale(_currentLocale);
    await appLocale.load(_defaultLanguageDirectory, _defaultLocale);
    return appLocale;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocale> old) {
    _reload = !_reload;
    return !_reload;
  }

  /// To dynamically change the application [locale] without restart.
  ///
  /// It automatically calls the [onLocaleChange].
  Locale changeLocale(Locale locale) {
    var _newLocale = _getSupportedLocale(locale);
    _reload = null != _newLocale && _newLocale != _currentLocale;
    if (_reload) {
      _currentLocale = _newLocale!;
      if (null != onLocaleChange) {
        onLocaleChange!(_currentLocale);
      }
    }
    return _currentLocale;
  }

  /// To dynamically change the application [language] without restart.
  ///
  /// It automatically calls the [onLocaleChange].
  String changeLanguage(String language) =>
      changeLocale(getLocale(language)).toString();
}

/// The fruit of labour that [LocaleDelegate] produces.
///
/// Get the current instance inside any widget (except the `main` one)
/// through `LocaleDelegate.of(context)` & use [localValue]
/// to get the localized value
///
/// ```dart
///   @override
///   Widget build(BuildContext context) {
///     var appLocale = LocaleDelegate.of(context);
///     var someText = appLocale.localValue('title');
///     // text with placeholder parameter can be replaced
///     // e.g.: 'message': 'To {to}, This is a sample Message, from {from}'
///     var someTextWithParameter = appLocale.localValue('message', {'to': 'World', 'from': 'Happy'});
///   }
/// ```
class AppLocale {
  /// The application [locale] loaded (or to be loaded).
  final Locale locale;
  late Map<String, dynamic> _values;
  bool _isLoaded = false;

  AppLocale._(this.locale) {
    // _interpolation = Interpolation();
  }

  /// Default constructor
  ///
  /// Called internally through `LocaleDelegate.load()`.
  factory AppLocale(Locale locale) => _cache.putIfAbsent(
      locale.toLanguageTag().toLowerCase(), () => AppLocale._(locale));

  /// Get the current [AppLocale] instance for the [context]
  static AppLocale of(BuildContext context) =>
      Localizations.of<AppLocale>(context, AppLocale)!;

  static final Map<String, AppLocale> _cache = <String, AppLocale>{};
  static Interpolation _interpolation = Interpolation();

  //
  static void setInterpolationOptions(
          InterpolationOption interpolationOption) =>
      _interpolation = Interpolation(option: interpolationOption);

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
      [Locale? defaultLocale]) async {
    if (!_isLoaded) {
      _values =
          await _getAssetJson(defaultContainerDirectory, locale.toString());
      if (null != defaultLocale && locale != defaultLocale) {
        var defaultValues = await _getAssetJson(
            defaultContainerDirectory, defaultLocale.toString());
        // take the values from [defaultLocale], not present in [locale]
        _values = defaultValues.extend(_values) as Map<String, dynamic>;
      }
      _values = _interpolation.resolve(_values, true) as Map<String, dynamic>;
      _isLoaded = true;
    }
    return _isLoaded;
  }

  /// [locale] in unicode string format
  String get currentLocale => locale.toString();

  /// Get the value of the [key] from the provide language json file.
  /// Additional [values] can be provided to substitute {placeholders}.
  ///
  /// Supports multi-level.
  /// Don't shy to pass `root.sub.subOfSub` as [key] if the json has it.
  String localValue(String key, [Map<String, dynamic>? values]) {
    var result = _interpolation.traverse(_values, key);
    if (null != values) {
      result = _interpolation.eval(result, values);
    }
    return result;
  }

  /// Set additional (or Update existing) runtime values.
  /// Some values are not determined until the application starts
  /// (i.e. set during runtime).
  bool updateValue(Map<String, dynamic> newValues) {
    _values.extend(newValues);
    _values = _interpolation.resolve(_values, true) as Map<String, dynamic>;
    return true;
  }
}

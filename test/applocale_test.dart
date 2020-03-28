import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:applocale/applocale.dart';

void main() {
  group('Check: LocaleDelegate.isSupported() with factory initiation', () {
    setUp(() {
      _localeDelegate = LocaleDelegate(_supportedLocales(), _defaultLocale);
    });

    test('First Test', () {
      expect(_localeDelegate.isSupported(getLocale("en")), isTrue);
      expect(_localeDelegate.isSupported(getLocale("en_us")), isTrue);
      expect(_localeDelegate.isSupported(getLocale("en_US")), isTrue);
      expect(_localeDelegate.isSupported(getLocale("en_UK")), isTrue);
      expect(_localeDelegate.isSupported(getLocale("bn")), isTrue);
      expect(_localeDelegate.isSupported(getLocale("zs")), isFalse);
    });
  });

  group('Check: LocaleDelegate.isSupported() with init initiation', () {
    setUp(() {
      _localeDelegate =
          LocaleDelegate.init(_supportedLocaleStrings(), _defaultLocaleString);
    });

    test('First Test', () {
      expect(_localeDelegate.isSupported(getLocale("en")), isTrue);
      expect(_localeDelegate.isSupported(getLocale("en_us")), isTrue);
      expect(_localeDelegate.isSupported(getLocale("en_US")), isTrue);
      expect(_localeDelegate.isSupported(getLocale("en_UK")), isTrue);
      expect(_localeDelegate.isSupported(getLocale("bn")), isTrue);
      expect(_localeDelegate.isSupported(getLocale("zs")), isFalse);
    });
  });
}

LocaleDelegate _localeDelegate;
Map<String, String> _supportedLanguages = <String, String>{
  "en": "English",
  "en_us": "English(USA)",
  "bn": "Bengali"
};
var _defaultLocale = getLocale("en");
var _defaultLocaleString = "en";
List<Locale> _supportedLocales() =>
    _supportedLanguages.entries.map((l) => getLocale(l.key)).toList();
List<String> _supportedLocaleStrings() =>
    _supportedLanguages.entries.map((l) => l.key).toList();

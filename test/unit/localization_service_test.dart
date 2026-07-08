import 'dart:ui' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:blood_donation/core/services/localization_service.dart';

void main() {
  group('LocalizationService', () {
    test('returns English translation for existing key', () {
      expect(LocalizationService.tr('appName'), equals('Blood Donor Network'));
      expect(LocalizationService.tr('ok'), equals('OK'));
      expect(LocalizationService.tr('cancel'), equals('Cancel'));
    });

    test('returns key itself when key is missing', () {
      expect(LocalizationService.tr('nonexistent_key'), equals('nonexistent_key'));
    });

    test('returns Hindi translation for hi locale', () {
      expect(LocalizationService.tr('appName', 'hi'), equals('ब्लड डोनर नेटवर्क'));
      expect(LocalizationService.tr('ok', 'hi'), equals('ठीक है'));
    });

    test('returns Urdu translation for ur locale', () {
      expect(LocalizationService.tr('appName', 'ur'), equals('بلڈ ڈونر نیٹ ورک'));
      expect(LocalizationService.tr('ok', 'ur'), equals('ٹھیک ہے'));
    });

    test('falls back to English for unsupported locale', () {
      expect(LocalizationService.tr('appName', 'fr'), equals('Blood Donor Network'));
    });

    test('returns correct hospital translations', () {
      expect(LocalizationService.tr('hospitals'), equals('Hospitals'));
      expect(LocalizationService.tr('noHospitalsFound'), equals('No Hospitals Found'));
      expect(LocalizationService.tr('hospitalsWillAppear'), equals('Hospitals will appear here once registered.'));
      expect(LocalizationService.tr('searchHospitals'), equals('Search hospitals...'));
    });

    test('returns correct blood bank translations', () {
      expect(LocalizationService.tr('bloodBanks'), equals('Blood Banks'));
      expect(LocalizationService.tr('noBloodBanksFound'), equals('No Blood Banks Found'));
      expect(LocalizationService.tr('noBloodBanksMatch'), equals('No blood banks match your search. Try a different term.'));
      expect(LocalizationService.tr('bloodBanksWillAppear'), equals('Blood banks will appear here once registered.'));
      expect(LocalizationService.tr('failedToLoadBloodBanks'), equals('Failed to load blood banks'));
    });

    test('returns correct tab translations', () {
      expect(LocalizationService.tr('hospitalsTab'), equals('Hospitals'));
      expect(LocalizationService.tr('bloodBanksTab'), equals('Blood Banks'));
    });

    test('returns correct Hindi tab translations', () {
      expect(LocalizationService.tr('hospitalsTab', 'hi'), equals('अस्पताल'));
      expect(LocalizationService.tr('bloodBanksTab', 'hi'), equals('रक्त बैंक'));
    });

    test('returns correct Urdu tab translations', () {
      expect(LocalizationService.tr('hospitalsTab', 'ur'), equals('ہسپتال'));
      expect(LocalizationService.tr('bloodBanksTab', 'ur'), equals('بلڈ بینک'));
    });

    test('hospitalsWillAppear available in all locales', () {
      expect(LocalizationService.tr('hospitalsWillAppear', 'en'), isNot(equals('hospitalsWillAppear')));
      expect(LocalizationService.tr('hospitalsWillAppear', 'hi'), isNot(equals('hospitalsWillAppear')));
      expect(LocalizationService.tr('hospitalsWillAppear', 'ur'), isNot(equals('hospitalsWillAppear')));
    });

    test('noBloodBanksMatch available in all locales', () {
      expect(LocalizationService.tr('noBloodBanksMatch', 'en'), isNot(equals('noBloodBanksMatch')));
      expect(LocalizationService.tr('noBloodBanksMatch', 'hi'), isNot(equals('noBloodBanksMatch')));
      expect(LocalizationService.tr('noBloodBanksMatch', 'ur'), isNot(equals('noBloodBanksMatch')));
    });

    test('supportedLocales contains expected languages', () {
      expect(LocalizationService.supportedLocales, containsAll(['en', 'hi', 'ur']));
    });

    test('toFlutterLocale returns correct Locale objects', () {
      expect(LocalizationService.toFlutterLocale('en'), equals(const Locale('en')));
      expect(LocalizationService.toFlutterLocale('hi'), equals(const Locale('hi')));
      expect(LocalizationService.toFlutterLocale('ur'), equals(const Locale('ur')));
    });
  });
}

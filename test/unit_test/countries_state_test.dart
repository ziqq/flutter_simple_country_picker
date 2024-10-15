import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/country_codes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CountriesState -', () {
    final country1 = Country.fromJson(countries[0]);
    final country2 = Country.fromJson(countries[1]);
    final countriesList = [country1, country2];

    test(r'CountriesState$Loading should be loading state', () {
      final state = CountriesState.loading(countriesList);

      expect(state.isLoading, isTrue);
      expect(state.isIdle, isFalse);
      expect(state.isError, isFalse);
      expect(state.countries, equals(countriesList));
    });

    test(r'CountriesState$Idle should be idle state', () {
      final state = CountriesState.idle(countriesList);

      expect(state.isLoading, isFalse);
      expect(state.isIdle, isTrue);
      expect(state.isError, isFalse);
      expect(state.countries, equals(countriesList));
    });

    test('CountriesState$Error should be error state', () {
      final state = CountriesState.error(countriesList);

      expect(state.isLoading, isFalse);
      expect(state.isIdle, isFalse);
      expect(state.isError, isTrue);
      expect(state.countries, equals(countriesList));
    });

    test('getByCountryCode should return correct country', () {
      final state = CountriesState.idle(countriesList);

      expect(state.getByCountryCode('RU'), equals(country1));
      expect(state.getByCountryCode('KZ'), equals(country2));
      expect(state.getByCountryCode('MX'), isNull);
    });

    test('CountriesState equality should be based on countriesList list', () {
      final state1 = CountriesState.idle([country1, country2]);
      final state2 = CountriesState.idle([country1, country2]);
      final state3 = CountriesState.idle([country1]);

      expect(state1, state2);
      expect(state1 == state3, isFalse);
    });

    test('CountriesState hashCode should be not iqual', () {
      final state1 = CountriesState.idle([country1, country2]);
      final state2 = CountriesState.idle([country1, country2]);

      expect(state1.hashCode != state2.hashCode, isTrue);
    });

    test('toString', () {
      final state1 = CountriesState.idle([country1, country2]);
      expect(state1.toString(), 'CountriesState{type: idle}');
    });
  });
}

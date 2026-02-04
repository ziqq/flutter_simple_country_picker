import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/constant/country_codes.dart';
import 'package:flutter_simple_country_picker/src/controller/country_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../util/mocks.dart';

void main() {
  _$controllerTest();
  _$stateTest();
}

void _$controllerTest() => group('CountryController -', () {
  late CountryController controller;
  late MockCountryProvider provider;
  late Country mockCountry;

  setUp(() {
    provider = MockCountryProvider();
    controller = CountryController(provider: provider);
    mockCountry = Country.fromJson(countries[0]);
  });

  test('Initial state is idle with empty countries list', () {
    expect(controller.state.isIdle, isTrue);
  });

  test(
    'getCountries sets state to loading, then idle with countries list',
    () async {
      final countries = [mockCountry];

      when(provider.getAll()).thenAnswer((_) async => Future.value(countries));

      expect(controller.state.isIdle, isTrue);

      // Start fetching countries
      await controller.getCountries();

      // Verify that the state is idle with countries after fetching
      expect(controller.state.countries, countries);

      // Verify that provider.getAll was called once
      verify(provider.getAll()).called(1);
    },
  );

  test('getCountries excludes countries based on the exclude list', () async {
    final countries = [mockCountry.copyWith(name: 'Canada', countryCode: 'CA')];

    when(provider.getAll()).thenAnswer((_) async => Future.value(countries));

    // Initialize controller with exclude list
    controller = CountryController(provider: provider, exclude: ['US']);

    await controller.getCountries();

    // Check that 'United States' is excluded
    expect(controller.state.countries, [
      mockCountry.copyWith(name: 'Canada', countryCode: 'CA'),
    ]);
  });

  test('getCountries filters countries based on the filter list', () async {
    final countries = [
      mockCountry,
      mockCountry.copyWith(name: 'Canada', countryCode: 'CA'),
      mockCountry.copyWith(name: 'Mexico', countryCode: 'MX'),
    ];

    when(provider.getAll()).thenAnswer((_) async => Future.value(countries));

    // Initialize controller with filter list
    controller = CountryController(
      provider: provider,
      filter: ['CA', 'MX'],
      showPhoneCode: false,
    );

    await controller.getCountries();

    // Check that only 'Canada' and 'Mexico' are in the list
    expect(controller.state.countries, [
      mockCountry.copyWith(name: 'Canada', countryCode: 'CA'),
      mockCountry.copyWith(name: 'Mexico', countryCode: 'MX'),
    ]);
  });

  test('search returns all countries when search text is empty', () async {
    final countries = [
      mockCountry,
      mockCountry.copyWith(name: 'Canada', countryCode: 'CA'),
      mockCountry.copyWith(name: 'Mexico', countryCode: 'MX'),
    ];

    when(provider.getAll()).thenAnswer((_) async => Future.value(countries));
    await controller.getCountries();

    controller.search?.clear();

    expect(controller.state.countries, countries);
  });

  test('Handles error state correctly', () async {
    final controller = CountryController(provider: provider);
    when(provider.getAll()).thenThrow(Exception('Error'));
    await controller.getCountries();
    expect(controller.state.isError, isTrue);
  });

  test('showGroup should return bool as true', () {
    final controller = CountryController(provider: provider);
    expect(controller.state.showGroup, isFalse);
  });
});

void _$stateTest() {
  group('CountryState -', () {
    final country1 = Country.fromJson(countries[0]);
    final country2 = Country.fromJson(countries[1]);
    final countriesList = [country1, country2];

    test(r'CountryState$Loading should be loading state', () {
      final state = CountryState.loading(
        countries: countriesList,
        showGroup: false,
      );

      expect(state.isLoading, isTrue);
      expect(state.isIdle, isFalse);
      expect(state.isError, isFalse);
      expect(state.countries, equals(countriesList));
    });

    test(r'CountryState$Idle should be idle state', () {
      final state = CountryState.idle(
        countries: countriesList,
        showGroup: false,
      );

      expect(state.isLoading, isFalse);
      expect(state.isIdle, isTrue);
      expect(state.isError, isFalse);
      expect(state.countries, equals(countriesList));
    });

    test(r'CountryState$Error should be error state', () {
      final state = CountryState.error(
        countries: countriesList,
        showGroup: false,
      );

      expect(state.isLoading, isFalse);
      expect(state.isIdle, isFalse);
      expect(state.isError, isTrue);
      expect(state.countries, equals(countriesList));
    });

    test('getCountryByCode should return correct country', () {
      final state = CountryState.idle(
        countries: countriesList,
        showGroup: false,
      );

      expect(state.getCountryByCode('RU'), equals(country1));
      expect(state.getCountryByCode('AB'), equals(country2));
      expect(state.getCountryByCode('MX'), isNull);
    });

    test('equality should be based on countriesList list', () {
      final state1 = CountryState.idle(
        countries: [country1, country2],
        showGroup: false,
      );
      final state2 = CountryState.idle(
        countries: [country1, country2],
        showGroup: false,
      );
      final state3 = CountryState.idle(countries: [country1], showGroup: false);

      expect(state1, state2);
      expect(state1 == state3, isFalse);
    });

    test('hashCode should be not iqual', () {
      final state1 = CountryState.idle(
        countries: [country1, country2],
        showGroup: false,
      );
      final state2 = CountryState.idle(
        countries: [country1, country2],
        showGroup: false,
      );

      expect(state1.hashCode != state2.hashCode, isTrue);
    });

    test('toString', () {
      final state1 = CountryState.idle(
        countries: [country1, country2],
        showGroup: false,
      );
      expect(
        state1.toString(),
        'CountryState.idle{countries: ${state1.countries.length}, showGroup: false}',
      );
    });
  });
}

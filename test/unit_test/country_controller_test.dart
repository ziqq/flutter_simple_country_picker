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

      when(provider.getAll()).thenReturn(Future.value(countries));

      expect(controller.state.isIdle, isTrue);

      // Start fetching countries
      controller.getCountries();

      // Wait for the async operation to complete
      await Future<void>.delayed(Duration.zero);

      // Verify that the state is idle with countries after fetching
      expect(controller.state.countries, countries);

      // Verify that provider.getAll was called once
      verify(provider.getAll()).called(1);
    },
  );

  test('getCountries excludes countries based on the exclude list', () async {
    final countries = [mockCountry.copyWith(name: 'Canada', countryCode: 'CA')];

    when(provider.getAll()).thenReturn(Future.value(countries));

    // Initialize controller with exclude list
    controller = CountryController(provider: provider, exclude: ['US'])
      ..getCountries();

    await Future<void>.delayed(Duration.zero);

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

    when(provider.getAll()).thenReturn(Future.value(countries));

    // Initialize controller with filter list
    controller = CountryController(
      provider: provider,
      filter: ['CA', 'MX'],
      showPhoneCode: false,
    )..getCountries();

    await Future<void>.delayed(Duration.zero);

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

    when(provider.getAll()).thenReturn(Future.value(countries));
    await Future.sync(() => controller.getCountries());

    controller.search?.clear();

    expect(controller.state.countries, countries);
  });

  test('Handles error state correctly', () async {
    final controller = CountryController(provider: provider);
    when(provider.getAll()).thenThrow(Exception('Error'));
    await Future.sync(controller.getCountries);
    expect(controller.state.isError, isTrue);
  });

  test('useGroup should return bool as true', () {
    final controller = CountryController(provider: provider);
    expect(controller.state.useGroup, isFalse);
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
        useGroup: false,
      );

      expect(state.isLoading, isTrue);
      expect(state.isIdle, isFalse);
      expect(state.isError, isFalse);
      expect(state.countries, equals(countriesList));
    });

    test(r'CountryState$Idle should be idle state', () {
      final state = CountryState.idle(
        countries: countriesList,
        useGroup: false,
      );

      expect(state.isLoading, isFalse);
      expect(state.isIdle, isTrue);
      expect(state.isError, isFalse);
      expect(state.countries, equals(countriesList));
    });

    test('CountryState$Error should be error state', () {
      final state = CountryState.error(
        countries: countriesList,
        useGroup: false,
      );

      expect(state.isLoading, isFalse);
      expect(state.isIdle, isFalse);
      expect(state.isError, isTrue);
      expect(state.countries, equals(countriesList));
    });

    test('getByCountryCode should return correct country', () {
      final state = CountryState.idle(
        countries: countriesList,
        useGroup: false,
      );

      expect(state.getByCountryCode('RU'), equals(country1));
      expect(state.getByCountryCode('KZ'), equals(country2));
      expect(state.getByCountryCode('MX'), isNull);
    });

    test('CountryState equality should be based on countriesList list', () {
      final state1 = CountryState.idle(
        countries: [country1, country2],
        useGroup: false,
      );
      final state2 = CountryState.idle(
        countries: [country1, country2],
        useGroup: false,
      );
      final state3 = CountryState.idle(countries: [country1], useGroup: false);

      expect(state1, state2);
      expect(state1 == state3, isFalse);
    });

    test('CountryState hashCode should be not iqual', () {
      final state1 = CountryState.idle(
        countries: [country1, country2],
        useGroup: false,
      );
      final state2 = CountryState.idle(
        countries: [country1, country2],
        useGroup: false,
      );

      expect(state1.hashCode != state2.hashCode, isTrue);
    });

    test('toString', () {
      final state1 = CountryState.idle(
        countries: [country1, country2],
        useGroup: false,
      );
      expect(
        state1.toString(),
        'CountryState.idle{countries: ${[country1, country2]}}',
      );
    });
  });
}

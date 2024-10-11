import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/country_codes.dart';
import 'package:flutter_simple_country_picker/src/controller/countries_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../util/mocks.dart';

void main() => group('CountriesController -', () {
      late CountriesController controller;
      late MockCountriesProvider provider;
      late Country mockCountry;

      setUp(() {
        provider = MockCountriesProvider();
        controller = CountriesController(provider: provider);
        mockCountry = Country.fromJson(countries[0]);
      });

      test('Initial state is idle with empty countries list', () {
        expect(controller.state.isIdle, isTrue);
      });

      test('getCountries sets state to loading, then idle with countries list',
          () async {
        final countries = [mockCountry];

        when(provider.getAll()).thenReturn(countries);

        expect(controller.state.isIdle, isTrue);

        // Start fetching countries
        controller.getCountries();

        // Wait for the async operation to complete
        await Future<void>.delayed(Duration.zero);

        // Verify that the state is idle with countries after fetching
        expect(controller.state.countries, countries);

        // Verify that provider.getAll was called once
        verify(provider.getAll()).called(1);
      });

      test('getCountries excludes countries based on the exclude list',
          () async {
        final countries = [
          mockCountry.copyWith(name: 'Canada', countryCode: 'CA'),
        ];

        when(provider.getAll()).thenReturn(countries);

        // Initialize controller with exclude list
        controller = CountriesController(
          provider: provider,
          exclude: ['US'],
        )..getCountries();

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

        when(provider.getAll()).thenReturn(countries);

        // Initialize controller with filter list
        controller = CountriesController(
          provider: provider,
          filter: ['CA', 'MX'],
        )..getCountries();

        await Future<void>.delayed(Duration.zero);

        // Check that only 'Canada' and 'Mexico' are in the list
        expect(controller.state.countries, [
          mockCountry.copyWith(name: 'Canada', countryCode: 'CA'),
          mockCountry.copyWith(name: 'Mexico', countryCode: 'MX'),
        ]);
      });

      test('search filters countries by name', () async {
        final countries = [
          mockCountry,
          mockCountry.copyWith(name: 'Canada', countryCode: 'CA'),
          mockCountry.copyWith(name: 'Mexico', countryCode: 'MX'),
        ];

        controller.originalCountries = countries;

        controller.searchController.text = 'Can';
        controller.search(null);

        expect(controller.state.countries, [
          mockCountry.copyWith(name: 'Canada', countryCode: 'CA'),
        ]);
      });

      test('search returns all countries when search text is empty', () async {
        final countries = [
          mockCountry,
          mockCountry.copyWith(name: 'Canada', countryCode: 'CA'),
          mockCountry.copyWith(name: 'Mexico', countryCode: 'MX'),
        ];

        controller.originalCountries = countries;

        controller.searchController.text = '';
        controller.search(null);

        expect(controller.state.countries, countries);
      });

      test('Handles error state correctly', () async {
        final controller = CountriesController(provider: provider);
        when(provider.getAll()).thenThrow(Exception('Error'));
        await Future.sync(controller.getCountries);
        expect(controller.state.isError, isTrue);
      });
    });

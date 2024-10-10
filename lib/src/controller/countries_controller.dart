import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/controller/countries_state.dart';
import 'package:meta/meta.dart';

/// {@template countries_controller}
/// Countries controller.
/// {@endtemplate}
@internal
class CountriesController extends ValueNotifier<CountriesState> {
  /// {@macro countries_controller}
  CountriesController({
    required CountriesProvider provider,
    bool showPhoneCode = true,
    List<Country>? countries,
    List<String>? exclude,
    List<String>? favorite,
    List<String>? filter,
  })  : _provider = provider,
        _exclude = exclude,
        _favorite = favorite,
        _filter = filter,
        _showPhoneCode = showPhoneCode,
        searchController = TextEditingController(),
        super(CountriesState.idle(countries ?? []));

  /// Countries provider.
  final CountriesProvider _provider;

  /// Used to show phone code.
  final bool _showPhoneCode;

  /// An optional [exclude] argument can be used to exclude(remove) one ore more
  /// country from the countries list. It takes a list of country code(iso2).
  /// Note: Can't provide both [exclude] and [countryFilter]
  final List<String>? _exclude;

  /// An optional [favorite] argument can be used to show countries
  /// at the top of the list. It takes a list of country code(iso2).
  final List<String>? _favorite;

  /// An optional [filter] argument can be used to filter the
  /// list of countries. It takes a list of country code(iso2).
  /// Note: Can't provide both [filter] and [exclude]
  final List<String>? _filter;

  /// Search controller
  final TextEditingController searchController;

  /// Get the state
  CountriesState get state => value;

  /// Original countries
  @internal
  @visibleForTesting
  List<Country> originalCountries = [];

  /// Get countries
  /// List<String> countries
  void getCountries() => _handle(() async {
        final stopwatch = Stopwatch()..start();
        try {
          final countries = await _provider.getAll();
          originalCountries = List.unmodifiable(countries);

          // Get favorite countries
          if (_favorite != null && _favorite!.isNotEmpty) {
            // final favorites = _provider.findCountriesByCode(_favorite!);
          }

          final $countries = <Country>[];
          final seenCountryCodes = <String>{};

          for (var i = 0; i < countries.length; i++) {
            final country = countries[i];

            // Check elapsed time and yield control if necessary
            if (stopwatch.elapsedMilliseconds > 8) {
              await Future<void>.delayed(Duration.zero);
              stopwatch.reset();
            }

            // Remove excluded countries
            if (_exclude != null && _exclude!.contains(country.countryCode)) {
              continue;
            }

            // Remove duplicates if not using phone code
            if (!_showPhoneCode) {
              if (!seenCountryCodes.add(country.countryCode)) continue;
            }

            // Filter countries
            if (_filter != null && !_filter!.contains(country.countryCode)) {
              continue;
            }

            // Add country to the filtered list
            $countries.add(country);
          }

          // Remove excluded countries
          // if (_exclude != null && _exclude!.isNotEmpty) {
          //   countries.removeWhere((e) => _exclude!.contains(e.countryCode));
          // }

          // // Remove duplicates country if not use phone code
          // if (!_showPhoneCode) {
          //   final ids = countries.map((e) => e.countryCode).toSet();
          //   countries.retainWhere((c) => ids.remove(c.countryCode));
          // }

          // // Get favorite countries
          // if (_favorite != null && _favorite!.isNotEmpty) {
          //   // ignore: unused_local_variable
          //   final favorites = _provider.findCountriesByCode(_favorite!);
          // }

          // // Filter countries
          // if (_filter != null && _filter!.isNotEmpty) {
          //   countries.removeWhere((e) => !_filter!.contains(e.countryCode));
          // }

          _setState(CountriesState.idle($countries.toList(growable: false)));
        } finally {
          if (kDebugMode) {
            dev.log(
              '${(stopwatch..stop()).elapsedMicroseconds} μs',
              name: 'get_countries',
              level: 100,
            );
          }
        }
      });

  /// Search countries
  void search(CountriesLocalization? localization) => _handle(() async {
        var newCountries = <Country>[];

        if (searchController.text.isEmpty) {
          newCountries.addAll(originalCountries);
        } else {
          newCountries = originalCountries
              .where((c) => c.startsWith(searchController.text, localization))
              .toList();
        }

        _setState(CountriesState.idle(newCountries.toList(growable: false)));
      });

  void _setState(CountriesState state) {
    value = state;
    notifyListeners();
  }

  Future<void> _handle(Future<void> Function() fn) async {
    _setState(CountriesState.loading(value.countries));
    try {
      await fn();
    } on Object catch (e, __) {
      _setState(CountriesState.error(value.countries));
    }
  }
}

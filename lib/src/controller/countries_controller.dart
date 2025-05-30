import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simple_country_picker/src/controller/countries_provider.dart';
import 'package:flutter_simple_country_picker/src/controller/countries_state.dart';
import 'package:flutter_simple_country_picker/src/localization/localization.dart';
import 'package:flutter_simple_country_picker/src/model/country.dart';
import 'package:meta/meta.dart';

/// {@template countries_controller}
/// Countries controller.
/// {@endtemplate}
@internal
final class CountriesController extends ValueNotifier<CountriesState> {
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
        search = TextEditingController(),
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

  /// Search controller.
  TextEditingController? search;

  /// Search listener.
  void Function()? _listener;

  /// Get the state.
  CountriesState get state => value;

  /// Original countries list.
  List<Country> _original = [];

  bool _useGroup = true;

  /// Use group in countries list or not.
  ///
  /// Defalut is `true`.
  bool get useGroup => _useGroup;

  /// Add listener to search controller and provide localization.
  ///
  /// Localization is used to search countries by localized name.
  void initListeners(CountriesLocalization? localization) {
    if (_listener != null) {
      search?.removeListener(_listener!);
      _listener = null;
    }
    _listener = () => _onSearch(localization);
    search?.addListener(_listener!);
  }

  /// Get countries
  void getCountries() => _handle(() async {
        final stopwatch = Stopwatch()..start();
        try {
          final countries = await _provider.getAll();
          _original = List.unmodifiable(countries);

          // Get favorite countries
          if (_favorite != null && _favorite.isNotEmpty) {
            // final favorites = _provider.findCountriesByCode(_favorite!);
          }

          final $countries = <Country>[];
          final seenCountryCodes = <String>{};

          for (var i = 0; i < countries.length; i++) {
            final country = countries[i];

            // Check elapsed time and yield control if necessary
            // coverage:ignore-start
            if (stopwatch.elapsedMilliseconds > 8) {
              await Future<void>.delayed(Duration.zero);
              stopwatch.reset();
            }
            // coverage:ignore-end

            // Remove excluded countries
            if (_exclude != null && _exclude.contains(country.countryCode)) {
              continue;
            }

            // Remove duplicates if not using phone code
            if (!_showPhoneCode) {
              if (!seenCountryCodes.add(country.countryCode)) continue;
            }

            // Filter countries
            if (_filter != null && !_filter.contains(country.countryCode)) {
              continue;
            }

            // Add country to the filtered list
            $countries.add(country);
          }

          _useGroup = $countries.length > 8;

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
  void _onSearch([CountriesLocalization? localization]) => _handle(() async {
        final searchText = search?.text ?? '';
        var newCountries = <Country>[];

        if (searchText.isEmpty) {
          newCountries.addAll(_original);
        } else {
          newCountries = _original
              .where((c) => c.startsWith(searchText, localization))
              .toList();
        }

        _setState(CountriesState.idle(newCountries.toList(growable: false)));
      });

  Future<void> _handle(Future<void> Function() fn) async {
    _setState(CountriesState.loading(value.countries));
    try {
      await fn();
    } on Object catch (e, __) {
      _setState(CountriesState.error(value.countries));
    }
  }

  void _setState(CountriesState state) {
    value = state;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_listener != null) search?.removeListener(_listener!);
    search?.dispose();
    super.dispose();
  }
}

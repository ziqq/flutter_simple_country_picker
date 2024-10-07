import 'package:flutter/foundation.dart';
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
    List<Country>? countries,
  })  : _provider = provider,
        super(CountriesState.idle(countries ?? []));

  final CountriesProvider _provider;

  /// Fetch countries
  void fetch(List<String> countryCodes) => _handle(() async {
        final countries = _provider.getAll();
        _setState(CountriesState.idle(countries));
      });

  void _setState(CountriesState state) {
    value = state;
    notifyListeners();
  }

  Future<void> _handle(Future<void> Function() fn) async {
    _setState(CountriesState.loading(value.countries));
    try {
      await fn();
    } on Object {
      _setState(CountriesState.error(value.countries));
    }
  }
}

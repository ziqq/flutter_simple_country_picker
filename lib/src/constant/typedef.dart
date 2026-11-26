import 'package:flutter/widgets.dart';
import 'package:flutter_simple_country_picker/src/model/country.dart';

/// {@template select_country_notifier}
/// A listenable selection where `null` means no country is selected.
/// {@endtemplate}
typedef SelectedCountry = ValueNotifier<Country?>;

/// {@template select_country_callback}
/// Called with the country the user chooses.
///
/// Dismissing the picker without choosing a country does not call this callback.
/// {@endtemplate}
typedef SelectCountryCallback = ValueChanged<Country>;

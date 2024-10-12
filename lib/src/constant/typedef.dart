import 'package:flutter/widgets.dart';
import 'package:flutter_simple_country_picker/src/model/country.dart';

/// {@template select_country_notifier}
/// Selected country notifier.
///
/// Used to notify listeners when a country is selected.
/// {@endtemplate}
typedef SelectedCountry = ValueNotifier<Country?>;

/// {@template select_country_callback}
/// Select country callback.
///
/// Call when the user select a country.
///
/// The function called with parameter the country that the user has selected.
///
/// If the user cancels the bottom sheet, the function is not call.
/// {@endtemplate}
typedef SelectCountryCallback = ValueChanged<Country>;

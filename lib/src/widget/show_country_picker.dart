import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/constant/constant.dart';
import 'package:flutter_simple_country_picker/src/widget/countries_list_view.dart';

/// {@template show_country_picker}
/// Shows a bottom sheet containing a list of countries to select one.
///
/// The callback function [onSelect] call when the user select a country.
/// The function called with parameter the country that the user has selected.
/// If the user cancels the bottom sheet, the function is not call.
///
///  An optional [exclude] argument can be used to exclude(remove) one ore more
///  country from the countries list. It takes a list of country code(iso2).
///
/// An optional [countryFilter] argument can be used to filter the
/// list of countries. It takes a list of country code(iso2).
/// Note: Can't provide both [countryFilter] and [exclude]
///
/// An optional [favorite] argument can be used to show countries
/// at the top of the list. It takes a list of country code(iso2).
///
/// An optional [showPhoneCode] argument can be used to show phone code.
///
/// [countryPickerThemeData] can be used to customizing
/// the country list bottom sheet.
///
/// [onClosed] callback which is called when CountryPicker is dismiss,
/// whether a country is selected or not.
///
/// [searchAutofocus] can be used to initially expand virtual keyboard
///
/// An optional [showSearch] argument can be used to show/hide the search bar.
///
/// The `context` argument is used to look up the [Scaffold] for the bottom
/// sheet. It is only used when the method is called. Its corresponding widget
/// can be safely removed from the tree before the bottom sheet is closed.
/// {@endtemplate}
void showCountryPicker({
  required BuildContext context,
  required ValueChanged<Country> onSelect,
  VoidCallback? onDone,
  List<String>? favorite,
  List<String>? exclude,
  List<String>? countryFilter,
  bool showPhoneCode = false,
  bool searchAutofocus = false,
  bool showWorldWide = false,
  bool showSearch = true,
  bool useSafeArea = false,
}) {
  final countryPickerTheme = CountryPickerTheme.maybeOf(context);

  // final backgroundColor = countryPickerTheme?.backgroundColor ??
  // Theme.of(context).bottomSheetTheme.backgroundColor ??
  // CupertinoDynamicColor.resolve(CupertinoColors.systemBackground, context);

  final effectiveRadius =
      Radius.circular(countryPickerTheme?.radius ?? kDefaultRadius);
  final borderRadius =
      BorderRadius.only(topLeft: effectiveRadius, topRight: effectiveRadius);

  showModalBottomSheet<void>(
    context: context,
    isDismissible: true,
    isScrollControlled: true,
    barrierColor: kCupertinoModalBarrierColor,
    builder: (context) => ClipRRect(
      borderRadius: borderRadius,
      child: CountriesListView(
        exclude: exclude,
        favorite: favorite,
        countryFilter: countryFilter,
        onSelect: onSelect,
        showSearch: showSearch,
        showPhoneCode: showPhoneCode,
        showWorldWide: showWorldWide,
        searchAutofocus: searchAutofocus,
      ),
    ),
  ).then<void>((_) => onDone?.call());
}

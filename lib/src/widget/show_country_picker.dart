import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/src/constant/constant.dart';
import 'package:flutter_simple_country_picker/src/constant/typedef.dart';
import 'package:flutter_simple_country_picker/src/theme/country_picker_theme.dart';
import 'package:flutter_simple_country_picker/src/widget/countries_list_view.dart';

/// {@template show_country_picker}
/// Shows a bottom sheet containing a list of countries to select one.
///
/// The callback function [onSelect] call when the user select a country.
/// The function called with parameter the country that the user has selected.
/// If the user cancels the bottom sheet, the function is not call.
///
/// An optional [selected] argument can be used to set the selected country.
///
/// An optional [exclude] argument can be used to exclude(remove) one ore more
/// country from the countries list. It takes a list of country code(iso2).
///
/// An optional [filter] argument can be used to filter the
/// list of countries. It takes a list of country code(iso2).
/// Note: Can't provide both [filter] and [exclude]
///
/// An optional [favorite] argument can be used to show countries
/// at the top of the list. It takes a list of country code(iso2).
///
/// An optional [showPhoneCode] argument can be used to show phone code.
///
/// [onDone] callback which is called when CountryPicker is dismiss,
/// whether a country is selected or not.
///
/// [autofocus] can be used to initially expand virtual keyboard
///
/// An optional [showSearch] argument can be used to show/hide the search bar.
///
/// The `context` argument is used to look up the [Scaffold] for the bottom
/// sheet. It is only used when the method is called. Its corresponding widget
/// can be safely removed from the tree before the bottom sheet is closed.
///
/// The `useRootNavigator` parameter ensures that the root navigator is used to
/// display the [BottomSheet] when set to `true`. This is useful in the case
/// that a modal [BottomSheet] needs to be displayed above all other content
/// but the caller is inside another [Navigator].
/// {@endtemplate}
void showCountryPicker({
  required BuildContext context,

  /// {@macro select_country_callback}
  SelectCountryCallback? onSelect,

  /// {@macro select_country_notifier}
  SelectedCountry? selected,
  VoidCallback? onDone,
  List<String>? exclude,
  List<String>? favorite,
  List<String>? filter,
  bool autofocus = false,
  bool isDismissible = true,
  bool isScrollControlled = true,
  bool showPhoneCode = false,
  bool showWorldWide = false,
  @Deprecated('Use autofocus instead. This will be removed in v0.3.0 releases.')
  bool useAutofocus = false,
  bool useHaptickFeedback = true,
  bool useRootNavigator = false,
  bool useSafeArea = true,
  bool? showSearch,
}) {
  final pickerTheme = CountryPickerTheme.maybeOf(context);
  final radius = Radius.circular(pickerTheme?.radius ?? kDefaultRadius);
  final borderRadius = BorderRadius.only(topLeft: radius, topRight: radius);
  if (useHaptickFeedback) HapticFeedback.mediumImpact().ignore();
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: useSafeArea,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    isScrollControlled: isScrollControlled,
    barrierColor: pickerTheme?.barrierColor,
    builder: (context) => ClipRRect(
      borderRadius: borderRadius,
      child: CountriesListView(
        exclude: exclude,
        favorite: favorite,
        filter: filter,
        selected: selected,
        onSelect: onSelect,
        autofocus: autofocus || useAutofocus,
        showSearch: showSearch,
        showPhoneCode: showPhoneCode,
        showWorldWide: showWorldWide,
      ),
    ),
  ).whenComplete(() => onDone?.call());
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    show
        BuildContext,
        VoidCallback,
        BorderRadius,
        ClipRRect,
        Radius,
        showModalBottomSheet,
        BoxDecoration,
        DecoratedBox,
        DraggableScrollableSheet,
        Colors;
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_simple_country_picker/src/constant/typedef.dart';
import 'package:flutter_simple_country_picker/src/theme/country_picker_theme.dart';
import 'package:flutter_simple_country_picker/src/widget/country_list_view.dart';

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
/// [whenComplete] callback which is called when CountryPicker is dismiss,
/// whether a country is selected or not.
///
/// [autofocus] can be used to initially expand virtual keyboard
///
/// [adaptive] can be used to show iOS style bottom sheet on iOS platform.
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
  List<String>? exclude,
  List<String>? favorite,
  List<String>? filter,
  SelectCountryCallback? onSelect,
  SelectedCountry? selected,
  @Deprecated(
    'Use whenComplete instead. This method will be removed in v1.0.0 releases.',
  )
  VoidCallback? onDone,
  VoidCallback? whenComplete,
  bool adaptive = false,
  bool autofocus = false,
  bool isDismissible = true,
  bool isScrollControlled = true,
  bool shouldCloseOnSwipeDown = false,
  bool showPhoneCode = false,
  bool showWorldWide = false,
  @Deprecated(
    'Use autofocus instead. This propery will be removed in v1.0.0 releases.',
  )
  bool useAutofocus = false,
  bool useHaptickFeedback = true,
  bool useRootNavigator = false,
  bool useSafeArea = true,
  bool? showSearch,
}) {
  final isiOS = defaultTargetPlatform == TargetPlatform.iOS;
  final pickerTheme = CountryPickerTheme.resolve(context);
  final radius = Radius.circular(pickerTheme.radius);
  final borderRadius = BorderRadius.only(topLeft: radius, topRight: radius);
  final child = DraggableScrollableSheet(
    expand: isScrollControlled,
    initialChildSize: isScrollControlled ? 1.0 : 1.0,
    minChildSize: isScrollControlled
        ? (shouldCloseOnSwipeDown ? .99 : 1.0)
        : .9,
    builder: (context, scrollController) => ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: pickerTheme.backgroundColor,
        ),
        child: CountryListView(
          exclude: exclude,
          favorite: favorite,
          filter: filter,
          selected: selected,
          onSelect: onSelect,
          adaptive: adaptive,
          autofocus: autofocus || useAutofocus,
          showSearch: showSearch,
          showPhoneCode: showPhoneCode,
          showWorldWide: showWorldWide,
          useHaptickFeedback: useHaptickFeedback,
          scrollController: isScrollControlled ? null : scrollController,
        ),
      ),
    ),
  );
  if (useHaptickFeedback) HapticFeedback.heavyImpact().ignore();
  if (adaptive && isiOS) {
    showCupertinoSheet<void>(
      context: context,
      builder: (context) => child,
    ).whenComplete(() => (whenComplete ?? onDone)?.call()).ignore();
  } else {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      backgroundColor: Colors.transparent,
      barrierColor: pickerTheme.barrierColor,
      builder: (context) => child,
    ).whenComplete(() => (whenComplete ?? onDone)?.call()).ignore();
  }
}

/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 7 October 2024
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        BuildContext,
        VoidCallback,
        BorderRadius,
        Radius,
        showModalBottomSheet,
        ShapeDecoration,
        RoundedSuperellipseBorder,
        DecoratedBox,
        Colors;
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_simple_country_picker/src/constant/typedef.dart';
import 'package:flutter_simple_country_picker/src/theme/country_picker_theme.dart';
import 'package:flutter_simple_country_picker/src/widget/country_list_view.dart';
import 'package:flutter_simple_country_picker/src/widget/country_picker_controls.dart';
import 'package:flutter_simple_country_picker/src/widget/country_picker_sheet_gesture.dart';
import 'package:flutter_simple_country_picker/src/widget/country_picker_surface.dart';

/// {@template show_country_picker}
/// Shows a bottom sheet containing a list of countries to select one.
///
/// An optional [exclude] argument can be used to exclude(remove) one ore more
/// country from the countries list. It takes a list of country code(iso2).
///
/// An optional [filter] argument can be used to filter the
/// list of countries. It takes a list of country code(iso2).
/// Note: Can't provide both [filter] and [exclude]
///
/// An optional [favorites] argument can be used to show countries
/// at the top of the list. It takes a list of country code(iso2).
///
/// An optional [selected] argument can be used to set the selected country.
///
/// An optional callback function [onSelect]
/// called when the country is selected.
///
/// An optional [whenComplete] callback which is called
/// when country picker is dismissed, whether a country is selected or not.
///
/// The [expand] argument can be used
/// to expand the bottom sheet to full height.
/// Defaults to `true`; set it to `false` for a partial sheet.
///
/// The [autofocus] argument can be used to initially expand virtual keyboard.
///
/// The [isDismissible] argument can be used
/// to make the bottom sheet dismissible.
///
/// The [isScrollControlled] argument can be used
/// to make the bottom sheet scrollable.
///
/// The [shouldCloseOnSwipeDown] argument can be used
/// to close the bottom sheet on swipe down gesture.
/// It controls sheet dragging and dismissal when the
/// country list is dragged down by a gesture that started at its beginning.
/// A gesture started farther down only scrolls the list, including its inertia;
/// reaching the beginning does not transfer that gesture to sheet dismissal.
/// A downward drag on the Material sheet header can dismiss it independently.
///
/// The [showPhoneCode] argument can be used
/// to show dialing codes alongside country names.
///
/// The [showWorldWide] argument argument can be used
/// to show "World Wide" option.
///
/// The [useHapticFeedback] argument can be used
/// to enable/disable haptic feedback.
///
/// The [useRootNavigator] argument ensures that the root navigator is used to
/// display the [BottomSheet] when set to `true`. This is useful in the case
/// that a modal [BottomSheet] needs to be displayed above all other content
/// but the caller is inside another [Navigator].
///
/// An optional [useSafeArea] argument can be used
/// to wrap the bottom sheet with SafeArea.
///
/// An optional [showGroup] argument can be used to show country groups.
///
/// An optional [showSearch] argument can be used to show/hide the search bar.
///
/// An optional [initialChildSize] argument can be used
/// to set the initial size of the bottom sheet.
///
/// An optional [minChildSize] argument can be used
/// to set the minimum size of the bottom sheet.
///
/// An optional [surfaceBuilder] argument can be used to paint custom
/// surfaces behind the search field and the close button.
/// {@endtemplate}
void showCountryPicker({
  required BuildContext context,
  List<String>? exclude,
  List<String>? favorites,
  List<String>? filter,
  SelectedCountry? selected,
  SelectCountryCallback? onSelect,
  VoidCallback? whenComplete,
  bool expand = true,
  bool autofocus = false,
  bool isDismissible = true,
  bool isScrollControlled = true,
  bool shouldCloseOnSwipeDown = false,
  bool showPhoneCode = false,
  bool showWorldWide = false,
  bool? useHapticFeedback,
  bool useRootNavigator = true,
  bool useSafeArea = true,
  bool? showGroup,
  bool? showSearch,
  double? initialChildSize,
  double? minChildSize,
  CountryPickerSurfaceBuilder? surfaceBuilder,
}) {
  final effectiveMinChildSize =
      minChildSize ??
      initialChildSize ??
      (expand ? (shouldCloseOnSwipeDown ? .99 : 1.0) : .65);

  final pickerTheme = CountryPickerTheme.resolve(context);
  final hapticFeedbackEnabled = useHapticFeedback ?? true;

  Widget buildSheet(BuildContext context) => CountryPickerSheetGesture(
    initialSize: initialChildSize ?? (expand ? 1.0 : .65),
    minSize: effectiveMinChildSize,
    canDismiss: shouldCloseOnSwipeDown,
    onDismiss: () =>
        Navigator.of(context, rootNavigator: useRootNavigator).pop<void>(),
    builder: (context, controller) {
      final theme = CountryPickerTheme.resolve(context);
      final radius = Radius.circular(theme.sheetCornerRadius);
      final borderRadius = BorderRadius.only(topLeft: radius, topRight: radius);
      final color = countryPickerSheetBackgroundColor(context, theme);
      final content = CountryListView(
        exclude: exclude,
        favorites: favorites,
        filter: filter,
        selected: selected,
        onSelect: onSelect,
        autofocus: autofocus,
        showGroup: showGroup,
        showSearch: showSearch,
        showPhoneCode: showPhoneCode,
        showWorldWide: showWorldWide,
        useRootNavigator: useRootNavigator,
        useHapticFeedback: hapticFeedbackEnabled,
        surfaceBuilder: surfaceBuilder,
        scrollController: controller,
      );
      // The full-width scroll edge paints into the corners too. Clip the whole
      // surface once so its shade cannot reveal a rectangular sheet beneath it.
      return ClipRSuperellipse(
        // Keep backdrop filters inside the sheet's alpha outline. A plain
        // antialiased clip lets their input restore a rectangular corner.
        clipBehavior: Clip.antiAliasWithSaveLayer,
        borderRadius: borderRadius,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: RoundedSuperellipseBorder(borderRadius: borderRadius),
            color: color,
          ),
          child: content,
        ),
      );
    },
  );

  if (hapticFeedbackEnabled) HapticFeedback.heavyImpact().ignore();

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: pickerTheme.barrierColor,
    isDismissible: isDismissible,
    isScrollControlled: isScrollControlled || expand,
    enableDrag: false,
    useRootNavigator: useRootNavigator,
    useSafeArea: useSafeArea,
    builder: (_) => CupertinoUserInterfaceLevel(
      data: .base,
      child: Builder(builder: buildSheet),
    ),
  ).whenComplete(() => whenComplete?.call()).ignore();
}

/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 7 October 2024
 */

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_simple_country_picker/src/constant/typedef.dart';
import 'package:flutter_simple_country_picker/src/theme/country_picker_theme.dart';
import 'package:flutter_simple_country_picker/src/widget/country_list_view.dart';
import 'package:flutter_simple_country_picker/src/widget/country_picker_controls.dart';
import 'package:flutter_simple_country_picker/src/widget/country_picker_sheet_gesture.dart';
import 'package:flutter_simple_country_picker/src/widget/country_picker_surface.dart';
import 'package:material_ui/material_ui.dart'
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

/// {@template show_country_picker}
/// Opens a country picker in a modal bottom sheet.
///
/// Pass ISO 3166-1 alpha-2 country codes to [exclude] or [filter] to omit
/// countries or restrict the list. These options are mutually exclusive.
/// [favorites] places matching entries first. With [showGroup], the remaining
/// entries are grouped by their first letter. [showSearch] defaults to
/// [showGroup]. Enable [showPhoneCode] to display calling codes and
/// [showWorldWide] to include the worldwide option.
///
/// [selected] supplies the current selection and is updated on a choice.
/// [onSelect] receives the chosen country. [whenComplete] runs whenever the
/// modal closes. [autofocus] focuses the search field when it is present.
///
/// [expand] opens the sheet at full height by default. [initialChildSize]
/// and [minChildSize] override its starting and minimum height as fractions
/// of the available space. [isScrollControlled] lets a partially expanded
/// picker use a scroll-controlled modal route.
///
/// [isDismissible] controls dismissal by tapping the scrim.
/// [shouldCloseOnSwipeDown] enables dismissal from a downward gesture started
/// at the top of the country list. Scrolling to the top in an active gesture
/// leaves the sheet open. A downward drag on the header can dismiss it
/// independently.
///
/// [useRootNavigator] places the sheet above nested navigator content.
/// [useSafeArea] keeps the modal outside system intrusions at its top and sides.
/// [useHapticFeedback] defaults to true. [surfaceBuilder] can paint custom
/// backgrounds behind the search field and close buttons.
/// {@endtemplate}
void showCountryPicker({
  required BuildContext context,
  SelectedCountry? selected,
  SelectCountryCallback? onSelect,
  VoidCallback? whenComplete,

  // Country list.
  List<String>? exclude,
  List<String>? favorites,
  List<String>? filter,
  bool? showGroup,
  bool? showSearch,
  bool showPhoneCode = false,
  bool showWorldWide = false,
  bool autofocus = false,

  // Sheet presentation.
  bool expand = true,
  bool isScrollControlled = true,
  double? initialChildSize,
  double? minChildSize,
  bool isDismissible = true,
  bool shouldCloseOnSwipeDown = false,
  bool useRootNavigator = true,
  bool useSafeArea = true,
  bool? useHapticFeedback,
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

import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
// TODO(ziqq): Remove the platform check import in 1.0.0.
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
        // TODO(ziqq): Remove Theme with _capturePickerTheme in 1.0.0.
        Theme,
        Colors;
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_simple_country_picker/src/constant/typedef.dart';
import 'package:flutter_simple_country_picker/src/theme/country_picker_theme.dart';
import 'package:flutter_simple_country_picker/src/widget/country_list_view.dart';

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
///
/// The [adaptive] argument can be used
/// to show an iOS-style bottom sheet on iOS. Deprecated for removal in 1.0.0.
///
/// The [autofocus] argument can be used to initially expand virtual keyboard.
///
/// The [isDismissible] argument can be used
/// to make the bottom sheet dismissible.
///
/// The [isScrollControlled] argument can be used
/// to make the bottom sheet scrollable.
///
/// The [shouldCloseOnSwipeDown] argument controls dismissal when dragging the
/// country list brings the sheet to its minimum height. The Material sheet
/// uses a slightly lower minimum if it opens at that height, so the list can
/// trigger dismissal. Its header also supports drag dismissal.
///
/// The [showPhoneCode] argument can be used
/// to show phone code before the country name.
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
/// {@endtemplate}
void showCountryPicker({
  required BuildContext context,

  // Selection and dismissal callbacks.
  SelectedCountry? selected,
  SelectCountryCallback? onSelect,
  VoidCallback? whenComplete,

  // Country list and search.
  List<String>? exclude,
  List<String>? favorites,
  List<String>? filter,
  bool? showGroup,
  bool? showSearch,
  bool showPhoneCode = false,
  bool showWorldWide = false,
  bool autofocus = false,

  // Sheet presentation.
  bool expand = false,
  bool isDismissible = true,
  bool isScrollControlled = true,
  bool shouldCloseOnSwipeDown = false,
  bool useRootNavigator = true,
  bool useSafeArea = true,
  double? initialChildSize,
  double? minChildSize,
  bool? useHapticFeedback,

  // Deprecated options.
  // TODO(ziqq): Remove the adaptive parameter and its dartdoc in 1.0.0.
  @Deprecated(
    'Omit adaptive to use the Material sheet. Will be removed in 1.0.0.',
  )
  bool adaptive = false,
  @Deprecated('Use whenComplete instead. Will be removed in 1.0.0.')
  VoidCallback? onDone,
  @Deprecated('Use autofocus instead. Will be removed in 1.0.0.')
  bool useAutofocus = false,
  @Deprecated('Use useHapticFeedback instead. Will be removed in 1.0.0.')
  bool useHaptickFeedback = true,
}) {
  // TODO(ziqq): Remove the Cupertino route check in 1.0.0.
  final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
  final useCupertinoSheet = adaptive && isIOS;
  // TODO(ziqq): Use expand directly in 1.0.0.
  final effectiveExpand = expand || useCupertinoSheet;
  final effectiveUseHapticFeedback = useHapticFeedback ?? useHaptickFeedback;

  // TODO(ziqq): Remove the Cupertino theme override in 1.0.0.
  final themeOverride = useCupertinoSheet
      ? _capturePickerTheme(
          from: context,
          to: Navigator.of(context, rootNavigator: true).context,
        )
      : null;

  // TODO(ziqq): Remove the route scrollController parameter in 1.0.0.
  Widget builder(BuildContext context, [ScrollController? scrollController]) {
    final defaultSize = effectiveExpand ? 1.0 : .65;
    final initialSize = initialChildSize ?? defaultSize;
    // Flutter only notifies the route if the sheet's extent changes.
    final minimumForDrag = shouldCloseOnSwipeDown
        ? initialSize * .99
        : initialSize;
    final minSize = !useCupertinoSheet && minChildSize == initialSize
        ? minimumForDrag
        : minChildSize ?? math.min(defaultSize, minimumForDrag);
    final sheet = DraggableScrollableSheet(
      expand: effectiveExpand,
      initialChildSize: initialSize,
      minChildSize: minSize,
      shouldCloseOnMinExtent: shouldCloseOnSwipeDown,
      builder: (context, sheetScrollController) {
        final pickerTheme = CountryPickerTheme.resolve(context);
        final radius = Radius.circular(pickerTheme.radius);
        final borderRadius = BorderRadius.only(
          topLeft: radius,
          topRight: radius,
        );
        return ClipRRect(
          borderRadius: borderRadius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: pickerTheme.backgroundColor,
            ),
            child: CountryListView(
              exclude: exclude,
              favorites: favorites,
              filter: filter,
              selected: selected,
              onSelect: onSelect,
              // TODO(ziqq): Stop forwarding adaptive in 1.0.0.
              adaptive: adaptive,
              autofocus: autofocus || useAutofocus,
              showGroup: showGroup,
              showSearch: showSearch,
              showPhoneCode: showPhoneCode,
              showWorldWide: showWorldWide,
              useRootNavigator: useRootNavigator,
              useHapticFeedback: effectiveUseHapticFeedback,
              // A sheet fixed at full height cannot resize to handle a drag.
              // TODO(ziqq): Remove the route scrollController in 1.0.0.
              scrollController:
                  scrollController ??
                  (minSize == 1.0 ? null : sheetScrollController),
            ),
          ),
        );
      },
    );
    // TODO(ziqq): Return sheet directly in 1.0.0.
    return themeOverride == null
        ? sheet
        : InheritedCountryPickerTheme(data: themeOverride, child: sheet);
  }

  /// Provide haptic feedback on opening the picker, if enabled.
  if (effectiveUseHapticFeedback) HapticFeedback.heavyImpact().ignore();

  // TODO(ziqq): Remove the Cupertino branch and call showModalBottomSheet
  // directly in 1.0.0.
  /// Show adaptive bottom sheet for `iOS` platform, if [adaptive] is `true`.
  if (useCupertinoSheet) {
    showCupertinoSheet<void>(
      context: context,
      scrollableBuilder: builder,
    ).whenComplete(() => (whenComplete ?? onDone)?.call()).ignore();

    /// Show material bottom sheet for other platforms.
  } else {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: CountryPickerTheme.resolve(context).barrierColor,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled || expand,
      useRootNavigator: useRootNavigator,
      useSafeArea: useSafeArea,
      builder: builder,
    ).whenComplete(() => (whenComplete ?? onDone)?.call()).ignore();
  }
}

// TODO(ziqq): Remove _capturePickerTheme in 1.0.0.
/// Captures the picker theme between the opener and the route's navigator.
CountryPickerTheme? _capturePickerTheme({
  required BuildContext from,
  required BuildContext to,
}) {
  if (from == to) return null;

  if (from.getInheritedWidgetOfExactType<InheritedCountryPickerTheme>() !=
      null) {
    CountryPickerTheme? theme;
    from.visitAncestorElements((ancestor) {
      if (ancestor == to) return false;
      if (ancestor.widget case InheritedCountryPickerTheme(:final data)) {
        theme = data;
        return false;
      }
      return true;
    });
    return theme;
  }

  final extensions = Theme.of(from).extensions;
  if (identical(extensions, Theme.of(to).extensions)) return null;
  if (extensions[CountryPickerTheme] case CountryPickerTheme? t) return t;
  return null;
}

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
import 'package:meta/meta.dart';

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
/// when [CountryPicker] is dismissed, whether a country is selected or not.
///
/// The [expand] argument can be used
/// to expand the bottom sheet to full height.
///
/// The [adaptive] argument can be used
/// to show iOS style bottom sheet on iOS platform.
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
///
/// The [showPhoneCode] argument can be used
/// to show phone code before the country name.
///
/// The [showWorldWide] argument argument can be used
/// to show "World Wide" option.
///
/// The [useHaptickFeedback] argument can be used
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
  List<String>? exclude,
  List<String>? favorites,
  List<String>? filter,
  SelectedCountry? selected,
  SelectCountryCallback? onSelect,
  @Deprecated(
    'Use whenComplete instead. This method will be removed in v1.0.0 releases.',
  )
  VoidCallback? onDone,
  VoidCallback? whenComplete,
  bool expand = false,
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
  bool useRootNavigator = true,
  bool useSafeArea = true,
  bool? showGroup,
  bool? showSearch,
  double? initialChildSize,
  double? minChildSize,
}) {
  final isiOS = defaultTargetPlatform == TargetPlatform.iOS;
  final pickerTheme = CountryPickerTheme.resolve(context);
  final radius = Radius.circular(pickerTheme.radius);
  final borderRadius = BorderRadius.only(topLeft: radius, topRight: radius);
  final child = DraggableScrollableSheet(
    expand: expand,
    initialChildSize: initialChildSize ?? (expand ? 1.0 : .65),
    minChildSize:
        minChildSize ?? (expand ? (shouldCloseOnSwipeDown ? .99 : 1.0) : .65),
    builder: (context, scrollController) => ClipRRect(
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
          adaptive: adaptive,
          autofocus: autofocus || useAutofocus,
          showGroup: showGroup,
          showSearch: showSearch,
          showPhoneCode: showPhoneCode,
          showWorldWide: showWorldWide,
          useRootNavigator: useRootNavigator,
          useHaptickFeedback: useHaptickFeedback,
          scrollController: isScrollControlled ? null : scrollController,
        ),
      ),
    ),
  );

  /// Provide haptic feedback on opening the picker, if enabled.
  if (useHaptickFeedback) HapticFeedback.heavyImpact().ignore();

  /// Show adaptive bottom sheet for `iOS` platform, if [adaptive] is `true`.
  if (adaptive && isiOS) {
    showCupertinoSheet<void>(
      context: context,
      builder: (context) => child,
    ).whenComplete(() => (whenComplete ?? onDone)?.call()).ignore();

    /// Show material bottom sheet for other platforms.
  } else {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: pickerTheme.barrierColor,
      isDismissible: isDismissible,
      isScrollControlled: true,
      useRootNavigator: useRootNavigator,
      useSafeArea: useSafeArea,
      builder: (context) => child,
    ).whenComplete(() => (whenComplete ?? onDone)?.call()).ignore();
  }
}

/// {@template country_picker_options}
/// [CountryPicker] options.
/// {@endtemplate}
@immutable
@experimental
class CountryPickerOptions {
  /// {@macro country_picker_options}
  const CountryPickerOptions({
    this.exclude,
    this.favorites,
    this.filter,
    this.selected,
    this.onSelect,
    @Deprecated(
      'Use whenComplete instead. This method will be removed in v1.0.0 releases.',
    )
    this.onDone,
    this.whenComplete,
    this.expand = false,
    this.adaptive = false,
    this.autofocus = false,
    this.isDismissible = true,
    this.isScrollControlled = true,
    this.shouldCloseOnSwipeDown = false,
    this.showPhoneCode = false,
    this.showWorldWide = false,
    this.useHaptickFeedback = true,
    this.useRootNavigator = false,
    @Deprecated(
      'Use autofocus instead. This propery will be removed in v1.0.0 releases.',
    )
    this.useAutofocus = false,
    this.useSafeArea = true,
    this.showGroup,
    this.showSearch,
    this.initialChildSize,
    this.minChildSize,
  });

  /// List of country codes to exclude.
  final List<String>? exclude;

  /// List of favorites country codes.
  final List<String>? favorites;

  /// List of country codes to filter.
  final List<String>? filter;

  /// Initially selected country.
  final SelectedCountry? selected;

  /// Callback when a country is selected.
  final SelectCountryCallback? onSelect;
  @Deprecated(
    'Use whenComplete instead. This method will be removed in v1.0.0 releases.',
  )
  /// Callback when the picker is dismissed.
  final VoidCallback? onDone;

  /// Callback when the picker is dismissed.
  final VoidCallback? whenComplete;

  /// Expand to full height?
  final bool expand;

  /// Adaptive style?
  /// Shows iOS style bottom sheet on iOS platform.
  final bool adaptive;

  /// Autofocus the search field?
  final bool autofocus;

  /// Used to make the bottom sheet dismissible.
  final bool isDismissible;

  /// Used to make the bottom sheet scrollable.
  final bool isScrollControlled;

  /// Close on swipe down gesture.
  final bool shouldCloseOnSwipeDown;

  /// Show phone code before the country name.
  final bool showPhoneCode;

  /// Show "World Wide" option.
  final bool showWorldWide;
  @Deprecated(
    'Use autofocus instead. This propery will be removed in v1.0.0 releases.',
  )
  /// Initially expand virtual keyboard.
  final bool useAutofocus;

  /// Use haptic feedback?
  final bool useHaptickFeedback;

  /// Use root navigator?
  final bool useRootNavigator;

  /// Use [SafeArea]?
  final bool useSafeArea;

  /// Show country groups.
  final bool? showGroup;

  /// Show/hide the search bar.
  final bool? showSearch;

  /// Initial child size for the modal bottom sheet.
  final double? initialChildSize;

  /// Min child size for the modal bottom sheet.
  final double? minChildSize;
}

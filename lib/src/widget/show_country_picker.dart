/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 7 October 2024
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
/// when country picker is dismissed, whether a country is selected or not.
///
/// The [expand] argument can be used
/// to expand the bottom sheet to full height.
/// Defaults to `true`; set it to `false` for a partial nonadaptive sheet.
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
/// It controls sheet dragging and dismissal when the
/// country list is dragged down by a gesture that started at its beginning.
/// A gesture started farther down only scrolls the list, including its inertia;
/// reaching the beginning does not transfer that gesture to sheet dismissal.
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
  @Deprecated(
    'Use whenComplete instead. This method will be removed in v1.0.0 releases.',
  )
  VoidCallback? onDone,
  VoidCallback? whenComplete,
  bool expand = true,
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
  @Deprecated(
    'Use useHapticFeedback instead. This parameter will be removed in '
    'v1.0.0 releases.',
  )
  bool useHaptickFeedback = true,
  bool? useHapticFeedback,
  bool useRootNavigator = true,
  bool useSafeArea = true,
  bool? showGroup,
  bool? showSearch,
  double? initialChildSize,
  double? minChildSize,
  CountryPickerSurfaceBuilder? surfaceBuilder,
}) {
  final isiOS = defaultTargetPlatform == .iOS;
  final effectiveExpand = expand || (adaptive && isiOS);
  final effectiveMinChildSize =
      minChildSize ??
      initialChildSize ??
      (effectiveExpand ? (shouldCloseOnSwipeDown ? .99 : 1.0) : .65);
  final effectiveUseHapticFeedback = useHapticFeedback ?? useHaptickFeedback;

  final pickerTheme = CountryPickerTheme.resolve(context);
  final radius = Radius.circular(pickerTheme.sheetCornerRadius);
  final borderRadius = BorderRadius.only(topLeft: radius, topRight: radius);
  void complete() => (whenComplete ?? onDone)?.call();

  Widget buildSheet(BuildContext context) => CountryPickerSheetGesture(
    initialSize: initialChildSize ?? (effectiveExpand ? 1.0 : .65),
    minSize: effectiveMinChildSize,
    canDismiss: shouldCloseOnSwipeDown,
    onDismiss: () =>
        Navigator.of(context, rootNavigator: useRootNavigator).pop<void>(),
    builder: (context, controller) {
      final color = countryPickerSheetBackgroundColor(
        context,
        CountryPickerTheme.resolve(context),
      );
      final content = CountryListView(
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
        useHapticFeedback: effectiveUseHapticFeedback,
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

  /// Uses the base Cupertino surface for the country list background.
  Widget builder(BuildContext context, [ScrollController? _]) =>
      CupertinoUserInterfaceLevel(
        data: .base,
        child: Builder(builder: buildSheet),
      );

  /// Provide haptic feedback on opening the picker, if enabled.
  if (effectiveUseHapticFeedback) HapticFeedback.heavyImpact().ignore();

  /// Show adaptive bottom sheet for `iOS` platform, if [adaptive] is `true`.
  if (adaptive && isiOS) {
    final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
    final themes = InheritedTheme.capture(from: context, to: navigator.context);
    navigator
        .push<void>(
          _CountryPickerCupertinoRoute(
            contentBuilder: (context) => themes.wrap(builder(context)),
          ),
        )
        .whenComplete(complete)
        .ignore();

    /// Show material bottom sheet for other platforms.
  } else {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: pickerTheme.barrierColor,
      isDismissible: isDismissible,
      isScrollControlled: true,
      enableDrag: false,
      useRootNavigator: useRootNavigator,
      useSafeArea: useSafeArea,
      builder: builder,
    ).whenComplete(complete).ignore();
  }
}

/// Retains SDK sheet transitions while the picker owns clipping and gestures.
///
/// The stock route clips its content to a fixed radius before the builder runs.
/// Overriding this public hook lets the picker theme also specify smaller or
/// square corners, without a second clip truncating them.
class _CountryPickerCupertinoRoute extends CupertinoSheetRoute<void> {
  _CountryPickerCupertinoRoute({required WidgetBuilder contentBuilder})
    : _contentBuilder = contentBuilder,
      super(
        enableDrag: false,
        scrollableBuilder: (context, _) => contentBuilder(context),
      );

  /// Builds the picker with its coordinated scroll position and themed surface.
  final WidgetBuilder _contentBuilder;

  @override
  Widget buildContent(BuildContext context) => MediaQuery.removePadding(
    context: context,
    removeTop: true,
    child: Builder(builder: _contentBuilder),
  );
}

/// {@template country_picker_options}
/// Country picker options.
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
    this.expand = true,
    this.adaptive = false,
    this.autofocus = false,
    this.isDismissible = true,
    this.isScrollControlled = true,
    this.shouldCloseOnSwipeDown = false,
    this.showPhoneCode = false,
    this.showWorldWide = false,
    @Deprecated(
      'Use useHapticFeedback instead. This parameter will be removed in '
      'v1.0.0 releases.',
    )
    bool useHaptickFeedback = true,
    bool? useHapticFeedback,
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
    this.surfaceBuilder,
  }) : useHaptickFeedback = useHapticFeedback ?? useHaptickFeedback,
       useHapticFeedback = useHapticFeedback ?? useHaptickFeedback;

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

  /// Whether to open at full height. Defaults to `true`.
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

  /// Whether to use haptic feedback.
  @Deprecated(
    'Use useHapticFeedback instead. This property will be removed in '
    'v1.0.0 releases.',
  )
  final bool useHaptickFeedback;

  /// Whether to use haptic feedback.
  final bool useHapticFeedback;

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

  /// {@macro country_picker_surface_builder}
  final CountryPickerSurfaceBuilder? surfaceBuilder;
}

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart'
    show
        CupertinoDynamicColor,
        CupertinoSearchTextField,
        CupertinoColors,
        CupertinoButtonSize,
        CupertinoButton,
        CupertinoIcons;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/constant/constants.dart';
import 'package:flutter_simple_country_picker/src/controller/country_controller.dart';
import 'package:flutter_simple_country_picker/src/data/country_provider.dart';
import 'package:flutter_simple_country_picker/src/util/country_flag_font_util.dart';
import 'package:flutter_simple_country_picker/src/util/country_util.dart';

part 'country_grouped_list.dart';
part 'country_flag_raster.dart';

/// {@template country_list_view}
/// CountryListView widget.
///
/// This widget is used to display a list of countries.
/// {@endtemplate}
@internal
class CountryListView extends StatefulWidget {
  /// {@macro country_list_view}
  const CountryListView({
    this.exclude,
    this.favorites,
    this.filter,
    this.selected,
    this.onSelect,
    this.scrollController,
    this.adaptive = false,
    this.autofocus = false,
    @Deprecated(
      'Use autofocus instead. This will be removed in v1.0.0 releases.',
    )
    this.useAutofocus = false,
    this.showPhoneCode = false,
    this.showWorldWide = false,
    this.useRootNavigator = true,
    this.useHapticFeedback = true,
    this.showGroup,
    this.showSearch,
    this.surfaceBuilder,
    super.key,
  }) : assert(
         filter == null || exclude == null,
         'Cannot provide both filter and exclude',
       );

  /// An optional argument for adaptive modal presentation.
  final bool adaptive;

  /// An optional argument for autofocus the search bar.
  final bool autofocus;

  /// Group countries by their first letter.
  /// Default is `null`.
  final bool? showGroup;

  /// An optional [showSearch] argument can be used to show/hide the search bar.
  /// Default is `null`.
  final bool? showSearch;

  /// An optional [showPhoneCode] argument can be used to show phone code.
  final bool showPhoneCode;

  /// An optional argument for showing "World Wide"
  /// option at the beginning of the list
  final bool showWorldWide;

  /// An optional argument for autofocus the search bar.
  @Deprecated('Use autofocus instead. This will be removed in v1.0.0 releases.')
  final bool useAutofocus;

  /// Whether to use root navigator to display the bottom sheet.
  final bool useRootNavigator;

  /// Whether to use haptic feedback on user interactions.
  final bool useHapticFeedback;

  /// Scroll controller.
  final ScrollController? scrollController;

  /// {@macro country_picker_surface_builder}
  final CountryPickerSurfaceBuilder? surfaceBuilder;

  /// {@macro select_country_callback}
  final SelectCountryCallback? onSelect;

  /// {@macro select_country_notifier}
  final SelectedCountry? selected;

  /// An optional [exclude] argument can be used to exclude(remove) one ore more
  /// country from the countries list. It takes a list of country code(iso2).
  /// Note: Can't provide both [exclude] and [filter]
  final List<String>? exclude;

  /// An optional [favorites] argument can be used to show countries
  /// at the top of the list. It takes a list of country code(iso2).
  final List<String>? favorites;

  /// An optional [filter] argument can be used to filter the
  /// list of countries. It takes a list of country code(iso2).
  /// Note: Can't provide both [filter] and [exclude]
  final List<String>? filter;

  @override
  State<CountryListView> createState() => _CountriesListViewState();
}

/// State for [CountryListView].
class _CountriesListViewState extends State<CountryListView>
    with WidgetsBindingObserver {
  late final ScrollController _scrollController;
  late final CountryController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = widget.scrollController ?? ScrollController();
    _controller = CountryController(
      provider: CountryProvider(),
      favorites: widget.favorites,
      exclude: widget.exclude,
      filter: widget.filter,
      showGroup: widget.showGroup,
      showPhoneCode: widget.showPhoneCode,
      showWorldWide: widget.showWorldWide,
    )..getCountries();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.initLocalization(CountryLocalizations.of(context));
  }

  @override
  void handleStatusBarTap() {
    _scrollController.animateTo(
      .0,
      curve: Curves.easeOutCirc,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.scrollController == null) _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _unfocus() {
    if (!mounted) return;
    final currentFocus = FocusScope.of(context);
    if (currentFocus.hasPrimaryFocus) return;
    if (currentFocus.focusedChild == null) return;
    FocusManager.instance.primaryFocus?.unfocus();
    // if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {}
  }

  /// Build divider widget.
  Widget _buildDivider() {
    final pickerTheme = CountryPickerTheme.resolve(context);
    // The drag handle is purely decorative.
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Align(
          heightFactor: 2,
          child: SizedBox(
            width: 36,
            height: 5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: pickerTheme.dividerColor,
                borderRadius: const BorderRadius.all(Radius.circular(30)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build search bar widget.
  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pickerTheme = CountryPickerTheme.resolve(context);
    final localization = CountryLocalizations.of(context);
    void pop() {
      if (widget.useHapticFeedback) HapticFeedback.heavyImpact().ignore();
      Navigator.of(context, rootNavigator: widget.useRootNavigator).pop<void>();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // --- Search bar --- //
        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: kToolbarHeight - 1, // Fix on border height
            maxHeight: kToolbarHeight - 1, // Fix on border height
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: pickerTheme.secondaryBackgroundColor,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: pickerTheme.padding),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: pickerTheme.padding / 1.6,
                children: <Widget>[
                  // --- Search field --- //
                  Expanded(
                    child: CupertinoSearchTextField(
                      autofocus: widget.autofocus || widget.useAutofocus,
                      controller: _controller.search,
                      onSuffixTap: _controller.search?.clear,
                      placeholder: localization.searchPlaceholder,
                      style: pickerTheme.textStyle?.copyWith(height: 1.3),
                      placeholderStyle: pickerTheme.textStyle?.copyWith(
                        color: pickerTheme.searchTextStyle?.color?.withValues(
                          alpha: .5,
                        ),
                        height: 1.3,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(pickerTheme.radius),
                      ),
                      backgroundColor: isDark
                          ? pickerTheme.backgroundColor?.withValues(
                              alpha: widget.adaptive ? 1 : .5,
                            )
                          : null,
                      suffixInsets: EdgeInsetsDirectional.only(
                        end: pickerTheme.padding / 3.2,
                      ),
                      prefixInsets: EdgeInsetsDirectional.only(
                        start: pickerTheme.padding / 2,
                      ),
                    ),
                  ),

                  // --- Cancel button --- //
                  CupertinoButton(
                    sizeStyle: CupertinoButtonSize.small,
                    padding: EdgeInsets.zero,
                    onPressed: pop,
                    child: Text(
                      localization.cancelButton,
                      style: pickerTheme.textStyle?.copyWith(
                        color: pickerTheme.accentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // --- Bottom border --- //
        SizedBox(
          width: double.infinity,
          height: 1,
          child: ColoredBox(
            color:
                pickerTheme.dividerColor ??
                // Theme resolution always supplies a divider color.
                // coverage:ignore-start
                CupertinoDynamicColor.resolve(
                  CupertinoColors.opaqueSeparator,
                  context,
                ),
            // coverage:ignore-end
          ),
        ),
      ],
    );
  }

  /// Build search bar widget in the iOS 26 style.
  ///
  /// A pill-shaped search field with a round close button next to it.
  Widget _buildSearchBarIOS26() {
    final pickerTheme = CountryPickerTheme.resolve(context);
    final localization = CountryLocalizations.of(context);
    final labelColor = CupertinoDynamicColor.resolve(
      CupertinoColors.label,
      context,
    );
    final iconSize = IconTheme.of(context).size;
    // Native iOS 26 controls are almost transparent over the sheet
    // and outlined by a hairline border.
    final side = BorderSide(
      color:
          pickerTheme.dividerColor ??
          // Theme resolution always supplies a divider color.
          // coverage:ignore-start
          CupertinoDynamicColor.resolve(
            CupertinoColors.opaqueSeparator,
            context,
          ),
      // coverage:ignore-end
    );
    const color = Colors.transparent;
    void pop() {
      if (widget.useHapticFeedback) HapticFeedback.heavyImpact().ignore();
      Navigator.of(context, rootNavigator: widget.useRootNavigator).pop<void>();
    }

    // Like native iOS 26 sheets, the header is solid and the list is
    // clipped right below it, keeping a gap under the controls.
    return ColoredBox(
      color: pickerTheme.backgroundColor ?? Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          pickerTheme.padding,
          pickerTheme.padding,
          pickerTheme.padding,
          pickerTheme.padding,
        ),
        child: SizedBox(
          height: kIOS26ControlHeight,
          child: Row(
            spacing: pickerTheme.padding / 1.6,
            children: <Widget>[
              // --- Search field --- //
              Expanded(
                child: _Surface(
                  builder: widget.surfaceBuilder,
                  type: CountryPickerSurfaceType.searchField,
                  shape: const StadiumBorder(),
                  decoration: ShapeDecoration(
                    color: color,
                    shape: StadiumBorder(side: side),
                  ),
                  child: CupertinoSearchTextField(
                    autofocus: widget.autofocus || widget.useAutofocus,
                    controller: _controller.search,
                    onSuffixTap: _controller.search?.clear,
                    placeholder: localization.searchPlaceholder,
                    style: pickerTheme.textStyle?.copyWith(height: 1.3),
                    placeholderStyle: pickerTheme.textStyle?.copyWith(
                      color:
                          pickerTheme.searchTextStyle?.color?.withValues(
                            alpha: .5,
                          ) ??
                          CupertinoDynamicColor.resolve(
                            CupertinoColors.secondaryLabel,
                            context,
                          ),
                      height: 1.3,
                    ),
                    // The background is painted by the surface.
                    decoration: const BoxDecoration(),
                    itemColor: labelColor,
                    itemSize: iconSize ?? 22,
                    padding: const EdgeInsetsDirectional.fromSTEB(8, 11, 8, 11),
                    prefixInsets: EdgeInsetsDirectional.only(
                      start: pickerTheme.padding * .75,
                    ),
                    suffixInsets: EdgeInsetsDirectional.only(
                      end: pickerTheme.padding / 1.6,
                    ),
                  ),
                ),
              ),

              // --- Close button --- //
              SizedBox.square(
                dimension: kIOS26ControlHeight,
                child: _Surface(
                  builder: widget.surfaceBuilder,
                  key: const ValueKey<String>('country_picker_close_button'),
                  type: CountryPickerSurfaceType.closeButton,
                  shape: const CircleBorder(),
                  decoration: ShapeDecoration(
                    color: color,
                    shape: CircleBorder(side: side),
                  ),
                  onPressed: pop,
                  semanticsLabel: localization.cancelButton,
                  child: Center(
                    child: Icon(
                      CupertinoIcons.xmark,
                      size: iconSize,
                      color: labelColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gestureInsets = MediaQuery.systemGestureInsetsOf(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final localization = CountryLocalizations.of(context);
    final pickerTheme = CountryPickerTheme.resolve(context);
    final useIOS26Header =
        pickerTheme.style == CountryPickerStyle.ios26 &&
        (widget.showSearch ?? widget.showGroup ?? false);
    return Scaffold(
      backgroundColor: pickerTheme.backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          useIOS26Header
              ? kIOS26ControlHeight + pickerTheme.padding * 2
              : kToolbarHeight,
        ),
        child: ValueListenableBuilder(
          valueListenable: _controller,
          builder: (_, state, _) => switch ((
            widget.showSearch ?? state.showGroup,
            pickerTheme.style == CountryPickerStyle.ios26,
          )) {
            (true, true) => _buildSearchBarIOS26(),
            (true, false) => _buildSearchBar(),
            (false, _) => _buildDivider(),
          },
        ),
      ),
      body: GestureDetector(
        onTap: _unfocus,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            // --- Gap under the iOS 26 header before scrolling --- //
            if (useIOS26Header)
              SliverToBoxAdapter(
                child: SizedBox(height: pickerTheme.padding / 2),
              ),

            // --- Title --- //
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, _) {
                // In the iOS 26 style the search field replaces the title.
                final hideTitle =
                    pickerTheme.style == CountryPickerStyle.ios26 &&
                    (widget.showSearch ?? state.showGroup);
                if (state.showGroup || hideTitle) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: pickerTheme.padding,
                      vertical: pickerTheme.padding / 2,
                    ),
                    child: Text(
                      localization.selectCountryLabel,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontWeight: .w700),
                    ),
                  ),
                );
              },
            ),

            // --- Countries list --- //
            _CountriesList(
              controller: _controller,
              favorites: widget.favorites,
              selected: widget.selected,
              onSelect: widget.onSelect,
            ),

            // --- Bottom spacer --- //
            SliverToBoxAdapter(
              child: SizedBox(
                height: viewPadding.bottom > 0
                    ? viewPadding.bottom
                    : gestureInsets.bottom > 0
                    ? gestureInsets.bottom
                    : pickerTheme.padding,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// _CountriesList widget.
/// {@macro countries_list_view}
class _CountriesList extends StatefulWidget {
  /// {@macro countries_list_view}
  const _CountriesList({
    required this.controller,
    this.favorites,
    this.selected,
    this.onSelect,
    super.key, // ignore: unused_element_parameter
  });

  /// Countries controller.
  final CountryController controller;

  /// Favorite country codes (iso2) shown in a section above the letters.
  final List<String>? favorites;

  /// {@macro select_country_notifier}
  final SelectedCountry? selected;

  /// {@macro select_country_callback}
  final SelectCountryCallback? onSelect;

  @override
  State<_CountriesList> createState() => _CountriesListState();
}

/// State for widget [_CountriesList].
class _CountriesListState extends State<_CountriesList> {
  final ValueNotifier<List<(String, List<Country>)>> _groups =
      ValueNotifier<List<(String, List<Country>)>>([]);
  List<(int, int)> _entries = [];
  List<int> _headers = [];
  List<Country>? _countries;
  bool? _showGroup;

  /// Fallback notifier used when [_CountriesList.selected] is not provided.
  final ValueNotifier<Country?> _fallbackSelected = ValueNotifier<Country?>(
    null,
  );

  /// The effective selected country notifier.
  ValueListenable<Country?> get _selected =>
      widget.selected ?? _fallbackSelected;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_groupByName);
    WidgetsBinding.instance.addPostFrameCallback((_) => _groupByName());
  }

  @override
  void didUpdateWidget(covariant _CountriesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The parent owns a late final controller, so it cannot be replaced.
    if (oldWidget.controller != widget.controller) {
      // coverage:ignore-start
      oldWidget.controller.removeListener(_groupByName);
      widget.controller.addListener(_groupByName);
      _groupByName();
      // coverage:ignore-end
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_groupByName);
    _fallbackSelected.dispose();
    _groups.dispose();
    super.dispose();
  }

  /// Group countries by name as initial letter.
  void _groupByName() {
    if (!mounted) return;
    final state = widget.controller.state;
    // An empty list is grouped too, so a search without results
    // does not keep showing the previous groups.
    if (!state.showGroup || !state.isIdle) return;

    if (_showGroup == state.showGroup &&
        identical(_countries, state.countries)) {
      return;
    }

    _countries = state.countries;
    _showGroup = state.showGroup;

    final groups = _buildGroups(state.countries);
    final entries = <(int, int)>[];
    final headers = <int>[];
    for (var group = 0; group < groups.length; group++) {
      final (key, countries) = groups[group];
      final header = key.isEmpty ? -1 : entries.length;
      if (key.isNotEmpty) {
        entries.add((group, -1));
        headers.add(header);
      }
      for (var index = 0; index < countries.length; index++) {
        entries.add((group, index));
        headers.add(header);
      }
    }
    _entries = entries;
    _headers = headers;
    _groups.value = groups;
  }

  /// Build groups of countries.
  ///
  /// The leading "World Wide" option and favorites form a section with an
  /// empty key, which is rendered without a letter header. The rest is
  /// grouped by the first letter of the localized name. Equal letters are
  /// merged even when not adjacent, so a letter header never repeats.
  List<(String, List<Country>)> _buildGroups(List<Country> countries) {
    final favorites =
        widget.favorites?.map((code) => code.trim().toUpperCase()).toSet() ??
        const <String>{};

    // The controller puts the pinned countries first. The block ends at the
    // first country that is not pinned or is repeated, because favorites
    // are listed again among all countries when phone codes are shown.
    final pinned = <Country>[];
    final seen = <String>{};
    var index = 0;
    for (; index < countries.length; index++) {
      final country = countries[index];
      final isPinned =
          country.iswWorldWide ||
          favorites.contains(country.countryCode.toUpperCase());
      if (!isPinned || !seen.add(country.e164Key)) break;
      pinned.add(country);
    }

    final letters = <String, List<Country>>{};
    for (final country in countries.skip(index)) {
      final name = country.nameLocalized ?? country.name;
      if (name.isEmpty) continue;
      // Accented letters are grouped with their base letter,
      // e.g. `Österreich` under `O`.
      final key = CountryUtil.foldDiacritics(
        name.characters.first,
      ).toUpperCase();
      (letters[key] ??= <Country>[]).add(country);
    }

    return <(String, List<Country>)>[
      if (pinned.isNotEmpty) ('', pinned),
      for (final MapEntry(:key, :value) in letters.entries) (key, value),
    ];
  }

  /// Notifies [_CountriesList.onSelect] and updates
  /// [_CountriesList.selected].
  void _onSelect(Country country) {
    // Notify external listeners first so they can
    // compare against the previous SelectedCountry
    // value, then update the notifier itself.
    widget.onSelect?.call(country);
    widget.selected?.value = country;
  }

  /// Build an inset rounded section of [countries] in the iOS 26 style.
  Widget _buildIOS26Section(List<Country> countries, Country? selected) {
    final pickerTheme = CountryPickerTheme.resolve(context);
    const radius = Radius.circular(kIOS26SectionRadius);
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: pickerTheme.padding,
        vertical: pickerTheme.padding / 2,
      ),
      sliver: SliverList.builder(
        itemCount: countries.length,
        itemBuilder: (_, index) {
          final country = countries[index];
          return ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: index == 0 ? radius : Radius.zero,
              bottom: index == countries.length - 1 ? radius : Radius.zero,
            ),
            child: ColoredBox(
              color: pickerTheme.secondaryBackgroundColor ?? Colors.transparent,
              child: _CountryListTile.ios26(
                key: ValueKey<String>(country.e164Key),
                country: country,
                selected: selected?.countryCode == country.countryCode,
                onSelect: _onSelect,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Keeps section headers and country rows in one lazy delegate.
  Widget _buildGroupedList(
    List<(String, List<Country>)> groups,
    CountryPickerTheme theme,
    Country? selected,
  ) {
    final entries = _entries;
    final ios26 = theme.style == CountryPickerStyle.ios26;
    final headerHeight = ios26 ? 36.0 : 26.0;

    Widget header(BuildContext context, int entry, {bool pinned = false}) {
      final key = groups[entries[entry].$1].$1;
      return Semantics(
        key: ValueKey<String>('${pinned ? 'pinned_header' : 'header'}_$key'),
        header: true,
        child: SizedBox(
          height: headerHeight,
          child: ColoredBox(
            key: ValueKey<String>('header_child_$key'),
            color:
                (ios26
                    ? theme.backgroundColor
                    : theme.secondaryBackgroundColor) ??
                Colors.transparent,
            child: Padding(
              padding: ios26
                  ? EdgeInsetsDirectional.only(
                      start: theme.padding * 2,
                      end: theme.padding * 2,
                      top: theme.padding / 2,
                    )
                  : EdgeInsets.symmetric(horizontal: theme.padding),
              child: Align(
                alignment: ios26
                    ? AlignmentDirectional.centerStart
                    : Alignment.centerLeft,
                child: Text(
                  key,
                  style: TextStyle(
                    height: 1,
                    fontSize: 15,
                    fontWeight:
                        !ios26 && defaultTargetPlatform == TargetPlatform.iOS
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: ios26
                        ? CupertinoDynamicColor.resolve(
                            CupertinoColors.secondaryLabel,
                            context,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return _CountryGroupedList(
      // Each entry carries its preceding header; the leading favorites use -1.
      headers: _headers,
      headerHeight: headerHeight,
      headerBuilder: (context, index) => header(context, index, pinned: true),
      delegate: SliverChildBuilderDelegate((context, entry) {
        final (group, index) = entries[entry];
        if (index < 0) return header(context, entry);
        final countries = groups[group].$2;
        final country = countries[index];
        final last = index == countries.length - 1;
        if (ios26) {
          const radius = Radius.circular(kIOS26SectionRadius);
          return Padding(
            padding: EdgeInsets.fromLTRB(
              theme.padding,
              index == 0 ? theme.padding / 2 : 0,
              theme.padding,
              last ? theme.padding / 2 : 0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: index == 0 ? radius : Radius.zero,
                bottom: last ? radius : Radius.zero,
              ),
              child: ColoredBox(
                color: theme.secondaryBackgroundColor ?? Colors.transparent,
                child: _CountryListTile.ios26(
                  key: ValueKey<String>(country.e164Key),
                  country: country,
                  selected: selected?.countryCode == country.countryCode,
                  onSelect: _onSelect,
                ),
              ),
            ),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CountryListTile(
              key: ValueKey<String>(country.e164Key),
              country: country,
              onSelect: _onSelect,
            ),
            if (!last)
              Divider(
                height: 1,
                thickness: 1,
                indent: theme.padding,
                endIndent: theme.padding,
                color: theme.dividerColor,
              ),
          ],
        );
      }, childCount: entries.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pickerTheme = CountryPickerTheme.resolve(context);
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, state, _) {
        // --- Loading state --- //
        if (state.isLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        // --- Grouped countries --- //
        if (state.showGroup) {
          return ValueListenableBuilder(
            valueListenable: _groups,
            builder: (_, groups, _) {
              if (pickerTheme.style == CountryPickerStyle.classic) {
                return _buildGroupedList(groups, pickerTheme, null);
              }
              return ValueListenableBuilder(
                valueListenable: _selected,
                builder: (_, selected, _) =>
                    _buildGroupedList(groups, pickerTheme, selected),
              );
            },
          );
        }

        // --- Plain countries list (iOS 26 style) --- //
        if (pickerTheme.style == CountryPickerStyle.ios26) {
          return ValueListenableBuilder(
            valueListenable: _selected,
            builder: (_, selected, _) =>
                _buildIOS26Section(state.countries, selected),
          );
        }

        // --- Plain countries list --- //
        return ValueListenableBuilder(
          valueListenable: widget.selected ?? ValueNotifier<Country?>(null),
          builder: (_, selected, _) => SliverList.builder(
            itemCount: state.countries.length,
            itemBuilder: (_, index) {
              final country = state.countries[index];
              return _CountryListTile.simple(
                key: ValueKey<String>(country.e164Key),
                country: country,
                selected: selected == country,
                onSelect: (country) {
                  // Notify external listeners first so they can
                  // compare against the previous SelectedCountry
                  // value, then update the notifier itself.
                  widget.onSelect?.call(country);
                  widget.selected?.value = country;
                },
              );
            },
          ),
        );
      },
    );
  }
}

/// _CountryListTile widget.
/// {@macro countries_list_view}
class _CountryListTile extends StatelessWidget {
  const _CountryListTile({
    required this.country,
    this.onSelect,
    this.simple = false,
    this.selected = false,
    super.key, // ignore: unused_element
  });

  const factory _CountryListTile.simple({
    required Country country,
    SelectCountryCallback? onSelect,
    bool selected,
    Key? key,
  }) = _CountryListTile$Simple;

  const factory _CountryListTile.ios26({
    required Country country,
    SelectCountryCallback? onSelect,
    bool selected,
    Key? key,
  }) = _CountryListTile$IOS26;

  /// Use simple variant?
  final bool simple;

  /// Is selected?
  final bool selected;

  /// Current country.
  final Country country;

  /// {@macro select_country_callback}
  final SelectCountryCallback? onSelect;

  /// Handles a tap on the tile.
  void _onTap(BuildContext context, String? nameLocalized) {
    final useHapticFeedback = context
        .findAncestorStateOfType<_CountriesListViewState>()
        ?.widget
        .useHapticFeedback;

    if (useHapticFeedback ?? true) {
      HapticFeedback.heavyImpact().ignore();
    }
    onSelect?.call(country.copyWith(nameLocalized: nameLocalized));
    Navigator.of(context).maybePop<void>();
  }

  /// Wraps [child] into an [InkWell] with the Cupertino-like highlight.
  ///
  /// The tile is exposed to accessibility services as a single button
  /// labelled with the country name and phone code, so decorative parts
  /// such as the emoji flag are not announced.
  ///
  /// [semanticsSelected] is `null` when the tile does not track selection.
  Widget _buildInkWell(
    BuildContext context, {
    required String? nameLocalized,
    required Widget child,
    bool? semanticsSelected,
  }) => Semantics(
    container: true,
    button: true,
    selected: semanticsSelected,
    label: country.phoneCode.isEmpty
        ? nameLocalized ?? country.name
        : '${nameLocalized ?? country.name}, +${country.phoneCode}',
    child: Material(
      // Add Material Widget with transparent color
      // so the ripple effect of InkWell will show on tap
      color: Colors.transparent,
      type: MaterialType.card,
      child: Theme(
        data: Theme.of(context).copyWith(
          highlightColor: CupertinoDynamicColor.resolve(
            CupertinoColors.systemGrey4,
            context,
          ),
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: InkWell(
          onTap: () => _onTap(context, nameLocalized),
          child: ExcludeSemantics(child: child),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final pickerTheme = CountryPickerTheme.resolve(context);
    final localization = CountryLocalizations.of(context);
    final effectiveTextStyle = pickerTheme.textStyle?.copyWith(height: 1.2);

    final nameLocalized = localization.getFormatedCountryNameByCode(
      country.countryCode,
    );

    final title = Text(
      nameLocalized ?? country.name,
      style: effectiveTextStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final effectiveTitle = switch (simple) {
      false => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: pickerTheme.padding / 4,
        children: <Widget>[
          _Flag(country),
          Flexible(child: title),
        ],
      ),
      true => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _Flag(country),
          SizedBox(width: pickerTheme.padding / 4),
          Flexible(child: title),
          if (country.phoneCode.isNotEmpty)
            Text(
              ' (${isRtl ? '' : '+'}${country.phoneCode}${isRtl ? '+' : ''})',
              style: effectiveTextStyle,
            ),
        ],
      ),
    };

    final effectiveTrailing = switch ((simple, selected)) {
      (true, true) => Icon(
        CupertinoIcons.checkmark_circle_fill,
        color: pickerTheme.accentColor,
      ),
      (true, false) => null,
      (false, _) when country.phoneCode.isEmpty => null,
      (false, _) => Padding(
        padding: EdgeInsets.only(top: pickerTheme.padding / 5),
        child: Text(
          '${isRtl ? '' : '+'}${country.phoneCode}${isRtl ? '+' : ''}',
          style: effectiveTextStyle?.copyWith(
            color: CupertinoDynamicColor.resolve(
              CupertinoColors.secondaryLabel,
              context,
            ),
            height: 1,
          ),
        ),
      ),
    };

    return _buildInkWell(
      context,
      nameLocalized: nameLocalized,
      semanticsSelected: simple ? selected : null,
      child: Padding(
        padding: EdgeInsets.only(
          top: simple ? pickerTheme.padding / 1.25 : pickerTheme.padding / 2,
          bottom: simple
              ? pickerTheme.padding / 1.25
              : pickerTheme.padding / 1.35,
          left: pickerTheme.padding,
          right: pickerTheme.padding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // --- Title of the country --- //
                  effectiveTitle,

                  // --- Country name --- //
                  if (!simple) ...[
                    Text(country.name, style: pickerTheme.secondaryTextStyle),
                  ],
                ],
              ),
            ),
            ?effectiveTrailing,
          ],
        ),
      ),
    );
  }
}

/// Country tile in the iOS 26 style:
/// round flag, phone code column and the localized country name.
/// {@macro countries_list_view}
class _CountryListTile$IOS26 extends _CountryListTile {
  /// {@macro countries_list_view}
  const _CountryListTile$IOS26({
    required super.country,
    super.selected = false,
    super.onSelect,
    super.key, // ignore: unused_element_parameter
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final pickerTheme = CountryPickerTheme.resolve(context);
    final localization = CountryLocalizations.of(context);
    final effectiveTextStyle = pickerTheme.textStyle?.copyWith(height: 1.2);

    final nameLocalized = localization.getFormatedCountryNameByCode(
      country.countryCode,
    );

    return _buildInkWell(
      context,
      nameLocalized: nameLocalized,
      semanticsSelected: selected,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: pickerTheme.padding,
          vertical: pickerTheme.padding * 1.1,
        ),
        child: Row(
          spacing: pickerTheme.padding,
          children: <Widget>[
            // --- Round flag --- //
            _Flag$IOS26(country, selected: selected),

            // --- Phone code --- //
            SizedBox(
              width: kIOS26PhoneCodeWidth,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    country.phoneCode.isEmpty
                        ? ''
                        : '${isRtl ? '' : '+'}${country.phoneCode}'
                              '${isRtl ? '+' : ''}',
                    maxLines: 1,
                    style: effectiveTextStyle?.copyWith(
                      color: CupertinoDynamicColor.resolve(
                        CupertinoColors.secondaryLabel,
                        context,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- Country name --- //
            Expanded(
              child: Text(
                nameLocalized ?? country.name,
                style: effectiveTextStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// {@macro countries_list_view}
class _CountryListTile$Simple extends _CountryListTile {
  /// {@macro countries_list_view}
  const _CountryListTile$Simple({
    required super.country,
    super.selected = false,
    super.onSelect,
    super.key, // ignore: unused_element_parameter
  }) : super(simple: true);
}

/// Flag widget.
/// {@macro countries_list_view}
class _Flag extends StatelessWidget {
  /// {@macro countries_list_view}
  const _Flag(
    this.country, {
    super.key, // ignore: unused_element_parameter
  });

  /// Current country.
  final Country country;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final pickerTheme = CountryPickerTheme.resolve(context);
    return SizedBox(
      // The conditional 50 prevents irregularities
      // caused by the flags in RTL mode
      width: isRtl ? 44 : null,
      child: Text.rich(
        TextSpan(
          text: country.iswWorldWide
              ? '\uD83C\uDF0D'
              : CountryUtil.countryCodeToEmoji(country.countryCode),
          style: TextStyle(
            fontFamily: country.iswWorldWide
                ? null
                : CountryFlagFontUtil.fontFamily,
          ),
        ),
        style: TextStyle(fontSize: pickerTheme.flagSize ?? 22, height: 1),
      ),
    );
  }
}

/// Round flag widget with an optional checkmark badge used
/// in the iOS 26 style.
/// {@macro countries_list_view}
class _Flag$IOS26 extends StatelessWidget {
  /// {@macro countries_list_view}
  const _Flag$IOS26(
    this.country, {
    this.selected = false,
    super.key, // ignore: unused_element_parameter
  });

  /// Current country.
  final Country country;

  /// Whether to show the checkmark badge.
  final bool selected;

  /// How much the emoji glyph is scaled to cover the whole circle.
  ///
  /// Emoji flags are rectangular glyphs with transparent padding.
  /// Apple Color Emoji (iOS, macOS) draws waving flags with extra space
  /// around them, so it needs a bigger scale than the flat Noto flags
  /// (Android, Linux, web) and the bundled Twemoji flags (Windows).
  static double _scaleOf(Country country) {
    if (country.iswWorldWide) return 1.0;
    if (kIsWeb) return 1.6;
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => 2.0,
      _ => 1.6,
    };
  }

  @override
  Widget build(BuildContext context) {
    final pickerTheme = CountryPickerTheme.resolve(context);
    final badgeColor = CupertinoDynamicColor.resolve(
      CupertinoColors.label,
      context,
    );
    final badgeBorderColor =
        pickerTheme.secondaryBackgroundColor ??
        // Theme resolution always supplies a secondary background color.
        // coverage:ignore-start
        CupertinoDynamicColor.resolve(
          CupertinoColors.secondarySystemBackground,
          context,
        );
    // coverage:ignore-end

    final emoji = country.iswWorldWide
        ? '\uD83C\uDF0D'
        : CountryUtil.countryCodeToEmoji(country.countryCode);
    final scale = _scaleOf(country);

    final flag = OverflowBox(
      maxWidth: double.infinity,
      maxHeight: double.infinity,
      child: Text.rich(
        TextSpan(
          text: emoji,
          style: TextStyle(
            fontFamily: country.iswWorldWide
                ? null
                : CountryFlagFontUtil.fontFamily,
          ),
        ),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: kIOS26FlagSize * scale, height: 1),
      ),
    );

    return SizedBox.square(
      dimension: kIOS26FlagSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          ClipOval(
            child: _FlagRasterCache(
              child: SizedBox.square(dimension: kIOS26FlagSize, child: flag),
            ),
          ),
          if (selected)
            PositionedDirectional(
              end: -4,
              bottom: -4,
              child: DecoratedBox(
                key: const ValueKey<String>('country_picker_selected_badge'),
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: badgeBorderColor, width: 2),
                ),
                child: SizedBox.square(
                  dimension: 20,
                  child: Icon(
                    CupertinoIcons.checkmark_alt,
                    size: 14,
                    color: badgeBorderColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A control surface of the iOS 26 style.
///
/// Delegates painting to [builder] and handles
/// taps, the pressed state and accessibility itself, so a custom builder
/// only has to draw the surface.
class _Surface extends StatefulWidget {
  const _Surface({
    required this.type,
    required this.shape,
    required this.decoration,
    required this.child,
    this.builder,
    this.onPressed,
    this.semanticsLabel,
    super.key,
  });

  final CountryPickerSurfaceBuilder? builder;

  final CountryPickerSurfaceType type;
  final ShapeBorder shape;
  final ShapeDecoration decoration;
  final VoidCallback? onPressed;
  final String? semanticsLabel;
  final Widget child;

  @override
  State<_Surface> createState() => _SurfaceState();
}

class _SurfaceState extends State<_Surface> {
  final ValueNotifier<bool> _pressed = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _pressed.dispose();
    super.dispose();
  }

  /// Paints [CountryPickerSurface.decoration] and dims the content on press.
  static Widget _defaultBuilder(
    BuildContext context,
    CountryPickerSurface surface,
    Widget child,
  ) => DecoratedBox(
    decoration: surface.decoration,
    child: !surface.isInteractive
        ? child
        : ValueListenableBuilder<bool>(
            valueListenable: surface.pressed,
            builder: (_, pressed, child) => AnimatedOpacity(
              opacity: pressed ? .4 : 1,
              duration: const Duration(milliseconds: 100),
              child: child,
            ),
            child: child,
          ),
  );

  @override
  Widget build(BuildContext context) {
    final builder = widget.builder ?? _defaultBuilder;
    final surface = CountryPickerSurface(
      type: widget.type,
      shape: widget.shape,
      decoration: widget.decoration,
      pressed: _pressed,
      onPressed: widget.onPressed,
    );
    final result = builder(context, surface, widget.child);
    final onPressed = widget.onPressed;
    if (onPressed == null) return result;
    return Semantics(
      container: true,
      button: true,
      label: widget.semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _pressed.value = true,
        onTapUp: (_) => _pressed.value = false,
        onTapCancel: () => _pressed.value = false,
        onTap: onPressed,
        child: ExcludeSemantics(child: result),
      ),
    );
  }
}

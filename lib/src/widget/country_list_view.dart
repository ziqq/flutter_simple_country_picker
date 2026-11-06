/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 7 October 2024
 */

import 'package:flutter/cupertino.dart'
    show CupertinoDynamicColor, CupertinoColors, CupertinoIcons;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/controller/country_controller.dart';
import 'package:flutter_simple_country_picker/src/data/country_provider.dart';
import 'package:flutter_simple_country_picker/src/util/country_flag_font_util.dart';
import 'package:flutter_simple_country_picker/src/util/country_util.dart';
import 'package:flutter_simple_country_picker/src/widget/country_flag_cache.dart';
import 'package:flutter_simple_country_picker/src/widget/country_picker_controls.dart';
import 'package:flutter_simple_country_picker/src/widget/country_picker_sheet_gesture.dart';

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
    this.paintBackground = true,
    super.key,
  }) : assert(
         filter == null || exclude == null,
         'Cannot provide both filter and exclude',
       );

  /// Whether the view paints its background or the modal shell supplies it.
  final bool paintBackground;

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
  final FocusNode _searchFocus = FocusNode();
  final ValueNotifier<List<(String, List<Country>)>> _groups =
      ValueNotifier<List<(String, List<Country>)>>([]);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchFocus.addListener(_expandForSearch);
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
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      curve: Curves.easeOutCirc,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchFocus.dispose();
    _groups.dispose();
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

  /// Expands the sheet before the keyboard occupies the lower viewport.
  void _expandForSearch() {
    if (_searchFocus.hasFocus) CountryPickerSheetGesture.expandOf(context);
  }

  /// Dismisses the picker through its configured navigator.
  void _closePicker() {
    if (widget.useHapticFeedback) HapticFeedback.heavyImpact().ignore();
    Navigator.of(context, rootNavigator: widget.useRootNavigator).pop<void>();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CountryPickerTheme.resolve(context);
    final controls = countryPickerControlHeight(context, theme);
    final headerHeight =
        countryPickerMinimumControlHeight(context) +
        countryPickerHeaderPadding(theme).vertical;
    final headerExtent = MediaQuery.paddingOf(context).top + headerHeight;
    final showSearch = widget.showSearch ?? widget.showGroup ?? false;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final dockBottom = bottom > 0 ? bottom : theme.padding / 2;
    final dockExtent = showSearch
        ? controls + dockBottom + theme.padding / 2
        : bottom;
    final viewBottom = MediaQuery.viewPaddingOf(context).bottom;
    final railBottom = showSearch
        ? controls +
              (viewBottom > 0 ? viewBottom : theme.padding / 2) +
              theme.padding / 2
        : viewBottom;
    return BackdropGroup(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: widget.paintBackground
            ? countryPickerSheetBackgroundColor(context, theme)
            : Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(headerHeight),
          child: CountryPickerHeader(
            onScrollToTop: handleStatusBarTap,
            surfaceBuilder: widget.surfaceBuilder,
            onClose: _closePicker,
          ),
        ),
        body: GestureDetector(
          onTap: _unfocus,
          excludeFromSemantics: true,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              CustomScrollView(
                controller: _scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  // Keep initial rows below the header while allowing scroll-under.
                  SliverPadding(
                    padding: EdgeInsets.only(top: headerExtent),
                    sliver: _CountriesList(
                      controller: _controller,
                      groups: _groups,
                      favorites: widget.favorites,
                      selected: widget.selected,
                      onSelect: widget.onSelect,
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: dockExtent)),
                ],
              ),
              PositionedDirectional(
                top: headerExtent,
                // Keep the rail's full-height geometry behind the keyboard.
                bottom: railBottom - MediaQuery.viewInsetsOf(context).bottom,
                end: 0,
                child: ValueListenableBuilder(
                  valueListenable: _groups,
                  builder: (context, groups, _) {
                    if (_controller.search?.text.isNotEmpty ?? false) {
                      return const SizedBox.shrink();
                    }
                    return CountryPickerAlphabet(
                      groups: groups,
                      onSelect: (letter) {
                        if (!_scrollController.hasClients) return;
                        final offset = countryPickerGroupOffset(
                          context,
                          theme,
                          groups,
                          letter,
                        );
                        _scrollController.jumpTo(
                          offset.clamp(
                            _scrollController.position.minScrollExtent,
                            _scrollController.position.maxScrollExtent,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if ((showSearch, _controller.search) case (
                true,
                TextEditingController search,
              ))
                PositionedDirectional(
                  start: theme.padding * .75,
                  end: theme.padding * .75,
                  bottom: dockBottom,
                  child: CountryPickerSearchDock(
                    controller: search,
                    focusNode: _searchFocus,
                    autofocus: widget.autofocus || widget.useAutofocus,
                    surfaceBuilder: widget.surfaceBuilder,
                    onClose: _closePicker,
                  ),
                ),
            ],
          ),
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
    required this.groups,
    this.favorites,
    this.selected,
    this.onSelect,
    super.key, // ignore: unused_element_parameter
  });

  /// Countries controller.
  final CountryController controller;
  final ValueNotifier<List<(String, List<Country>)>> groups;

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
  ValueNotifier<List<(String, List<Country>)>> get _groups => widget.groups;
  List<(int, int)> _entries = <(int, int)>[];
  List<Country>? _countries;
  bool? _showGroup;

  /// Fallback notifier used when [_CountriesList.selected] is not provided.
  final ValueNotifier<Country?> _fallback = ValueNotifier<Country?>(null);

  /// The effective selected country notifier.
  ValueListenable<Country?> get _selected => widget.selected ?? _fallback;

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
    _fallback.dispose();
    super.dispose();
  }

  /// Group countries by name as initial letter.
  void _groupByName() {
    if (!mounted) return;
    final state = widget.controller.state;
    // An empty list is grouped too, so a search without results
    // does not keep showing the previous groups.
    if (!state.showGroup || !state.isIdle) return;

    if (identical(_countries, state.countries) &&
        _showGroup == state.showGroup) {
      return;
    }

    _countries = state.countries;
    _showGroup = state.showGroup;

    final groups = _buildGroups(state.countries);
    final entries = <(int, int)>[];
    for (var group = 0; group < groups.length; group++) {
      final (key, countries) = groups[group];
      if (key.isNotEmpty) {
        entries.add((group, -1));
      }
      for (var index = 0; index < countries.length; index++) {
        entries.add((group, index));
      }
    }
    _entries = entries;
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
    while (index < countries.length) {
      final country = countries[index];
      final isPinned =
          country.iswWorldWide ||
          favorites.contains(country.countryCode.toUpperCase());
      if (!isPinned || !seen.add(country.e164Key)) break;
      pinned.add(country);
      index++;
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
    // Notify external listeners first so they can compare
    // against the previous SelectedCountry value,
    // then update the notifier itself.
    widget.onSelect?.call(country);
    widget.selected?.value = country;
  }

  /// Builds compact country rows in one lazy list.
  Widget _buildSection(List<Country> countries, Country? selected) {
    final theme = CountryPickerTheme.resolve(context);
    final rowHeight = countryPickerCountryHeight(context, theme);
    final divider = 1 / MediaQuery.devicePixelRatioOf(context);
    return SliverFixedExtentList.builder(
      itemExtent: rowHeight + divider,
      itemCount: countries.length,
      itemBuilder: (context, index) => Column(
        children: <Widget>[
          _CountryListTile(
            key: ValueKey<String>(countries[index].e164Key),
            country: countries[index],
            selected: selected?.countryCode == countries[index].countryCode,
            onSelect: _onSelect,
          ),
          Divider(
            height: divider,
            thickness: divider,
            color: theme.dividerColor,
            indent: countryPickerListInset(theme),
            endIndent: countryPickerListInset(theme),
          ),
        ],
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
    final light = Theme.of(context).brightness == Brightness.light;
    final dividerHeight = 1 / MediaQuery.devicePixelRatioOf(context);

    Widget? itemBuilder(BuildContext context, int entry) {
      final (group, index) = entries[entry];
      final (letter, countries) = groups[group];
      if (index < 0) {
        return Semantics(
          key: ValueKey<String>('header_$letter'),
          header: true,
          child: SizedBox(
            height: countryPickerGroupHeight(context, theme, first: group == 0),
            child: ColoredBox(
              key: ValueKey<String>('header_child_$letter'),
              color: countryPickerSheetBackgroundColor(context, theme),
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: countryPickerListInset(theme),
                ).add(EdgeInsets.only(bottom: theme.padding / 2)),
                child: Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: Text(
                    letter,
                    style: TextStyle(
                      height: 1,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.secondaryTextStyle?.color,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
      final country = countries[index];
      final inset = countryPickerListInset(theme);
      final contentInset = light
          ? (inset - theme.padding).clamp(0.0, double.infinity)
          : inset;
      final row = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _CountryListTile(
            key: ValueKey<String>(country.e164Key),
            country: country,
            selected: selected?.countryCode == country.countryCode,
            onSelect: _onSelect,
            horizontalPadding: contentInset,
          ),
          if (index < countries.length - 1)
            Divider(
              height: dividerHeight,
              thickness: dividerHeight,
              indent: contentInset,
              endIndent: contentInset,
              color: theme.dividerColor,
            ),
        ],
      );
      if (!light) return row;
      // First and last rows draw the group's outline without building the
      // intervening countries eagerly. Each row remains a lazy sliver child.
      const radius = Radius.circular(24);
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: theme.padding),
        child: ClipRSuperellipse(
          borderRadius: BorderRadius.vertical(
            top: index == 0 ? radius : Radius.zero,
            bottom: index == countries.length - 1 ? radius : Radius.zero,
          ),
          child: ColoredBox(
            color:
                theme.backgroundColor ?? Theme.of(context).colorScheme.surface,
            child: row,
          ),
        ),
      );
    }

    final sliver = SliverList(
      delegate: CountryPickerExtentDelegate(
        itemBuilder,
        childCount: entries.length,
        extent: countryPickerGroupOffset(context, theme, groups, null),
      ),
    );
    return sliver;
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

        if (state.showGroup &&
            (widget.controller.search?.text.isEmpty ?? true)) {
          return ValueListenableBuilder(
            valueListenable: _groups,
            builder: (_, groups, _) => ValueListenableBuilder(
              valueListenable: _selected,
              builder: (_, selected, _) =>
                  _buildGroupedList(groups, pickerTheme, selected),
            ),
          );
        }
        return ValueListenableBuilder(
          valueListenable: _selected,
          builder: (_, selected, _) => _buildSection(state.countries, selected),
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
    this.selected = false,
    this.horizontalPadding,
    super.key, // ignore: unused_element
  });

  /// Is selected?
  final bool selected;

  /// Current country.
  final Country country;

  /// {@macro select_country_callback}
  final SelectCountryCallback? onSelect;

  /// Insets content inside an already inset light group surface.
  final double? horizontalPadding;

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
          splashFactory:
              Theme.of(context).splashFactory == InkSparkle.splashFactory
              ? NoSplash.splashFactory
              : null,
          onTap: () => _onTap(context, nameLocalized),
          child: ExcludeSemantics(child: child),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = CountryPickerTheme.resolve(context);
    final localization = CountryLocalizations.of(context);
    final localized = localization.getFormatedCountryNameByCode(
      country.countryCode,
    );
    final name = localized == null || localized.isEmpty
        ? country.name
        : localized;
    final titleStyle = theme.textStyle?.copyWith(height: 1.2);
    final large = countryPickerUsesLargeRows(context, theme);
    final phone = Directionality.of(context) == TextDirection.rtl
        ? '${country.phoneCode}+'
        : '+${country.phoneCode}';
    return SizedBox(
      height: countryPickerCountryHeight(context, theme),
      child: _buildInkWell(
        context,
        nameLocalized: name,
        semanticsSelected: selected,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding ?? countryPickerListInset(theme),
          ),
          child: Row(
            spacing: theme.padding / 2,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      spacing: theme.padding / 3.2,
                      children: <Widget>[
                        _CountryFlag(country),
                        Expanded(
                          child: Text(
                            name,
                            style: titleStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      country.name,
                      style: theme.secondaryTextStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (large && country.phoneCode.isNotEmpty)
                      Text(
                        phone,
                        style: titleStyle?.copyWith(
                          color: theme.secondaryTextStyle?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (!large && country.phoneCode.isNotEmpty)
                Text(
                  phone,
                  style: titleStyle?.copyWith(
                    color: theme.secondaryTextStyle?.color?.withValues(
                      alpha: .6,
                    ),
                  ),
                ),
              if (selected)
                Icon(
                  CupertinoIcons.checkmark_alt,
                  key: const ValueKey<String>('country_picker_selected_badge'),
                  size: 18,
                  color: theme.accentColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact platform emoji used in country rows.
/// {@macro countries_list_view}
class _CountryFlag extends StatelessWidget {
  /// {@macro countries_list_view}
  const _CountryFlag(
    this.country, {
    super.key, // ignore: unused_element_parameter
  });

  /// Current country.
  final Country country;

  @override
  Widget build(BuildContext context) {
    final theme = CountryPickerTheme.resolve(context);
    return CountryFlagCache(
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
        style: TextStyle(fontSize: theme.flagSize, height: 1),
      ),
    );
  }
}

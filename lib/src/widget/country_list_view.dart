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
import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/controller/country_controller.dart';
import 'package:flutter_simple_country_picker/src/data/country_provider.dart';
import 'package:flutter_simple_country_picker/src/util/country_util.dart';

/// Height of the search field and the close button in the iOS 26 style.
const double _kIOS26ControlHeight = 44.0;

/// Diameter of the round flag in the iOS 26 style.
const double _kIOS26FlagSize = 40.0;

/// Border radius of the inset list section in the iOS 26 style.
const double _kIOS26SectionRadius = 26.0;

/// Width of the phone code column in the iOS 26 style.
const double _kIOS26PhoneCodeWidth = 48.0;

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
                spacing: pickerTheme.indent,
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
                        end: pickerTheme.indent / 2,
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
                CupertinoDynamicColor.resolve(
                  CupertinoColors.opaqueSeparator,
                  context,
                ),
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
    final decoration = BoxDecoration(
      color: pickerTheme.secondaryBackgroundColor,
      border: Border.all(
        color:
            pickerTheme.dividerColor?.withValues(alpha: .5) ??
            CupertinoDynamicColor.resolve(CupertinoColors.separator, context),
        width: .5,
      ),
    );
    void pop() {
      if (widget.useHapticFeedback) HapticFeedback.heavyImpact().ignore();
      Navigator.of(context, rootNavigator: widget.useRootNavigator).pop<void>();
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        pickerTheme.padding,
        pickerTheme.padding,
        pickerTheme.padding,
        pickerTheme.padding / 2,
      ),
      child: SizedBox(
        height: _kIOS26ControlHeight,
        child: Row(
          spacing: pickerTheme.indent,
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
                decoration: decoration.copyWith(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(_kIOS26ControlHeight / 2),
                  ),
                ),
                itemColor: labelColor,
                itemSize: iconSize ?? 22,
                padding: const EdgeInsetsDirectional.fromSTEB(8, 11, 8, 11),
                prefixInsets: EdgeInsetsDirectional.only(
                  start: pickerTheme.padding * .75,
                ),
                suffixInsets: EdgeInsetsDirectional.only(
                  end: pickerTheme.indent,
                ),
              ),
            ),

            // --- Close button --- //
            SizedBox.square(
              dimension: _kIOS26ControlHeight,
              child: DecoratedBox(
                decoration: decoration.copyWith(shape: BoxShape.circle),
                child: CupertinoButton(
                  key: const ValueKey<String>('country_picker_close_button'),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size.square(_kIOS26ControlHeight),
                  onPressed: pop,
                  child: Icon(
                    CupertinoIcons.xmark,
                    size: iconSize,
                    color: labelColor,
                    semanticLabel: localization.cancelButton,
                  ),
                ),
              ),
            ),
          ],
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
    return Scaffold(
      backgroundColor: pickerTheme.backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          pickerTheme.useIOS26 &&
                  (widget.showSearch ?? widget.showGroup ?? false)
              ? _kIOS26ControlHeight + pickerTheme.padding * 1.5
              : kToolbarHeight,
        ),
        child: ValueListenableBuilder(
          valueListenable: _controller,
          builder: (_, state, _) => switch ((
            widget.showSearch ?? state.showGroup,
            pickerTheme.useIOS26,
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
            // --- Title --- //
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, _) {
                // In the iOS 26 style the search field replaces the title.
                final hideTitle =
                    pickerTheme.useIOS26 &&
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
    this.selected,
    this.onSelect,
    super.key, // ignore: unused_element_parameter
  });

  /// Countries controller.
  final CountryController controller;

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
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_groupByName);
      widget.controller.addListener(_groupByName);
      _groupByName();
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
    if (!state.showGroup || !state.isIdle || state.countries.isEmpty) return;

    if (_showGroup == state.showGroup &&
        identical(_countries, state.countries)) {
      return;
    }

    _countries = state.countries;
    _showGroup = state.showGroup;

    _groups.value = _buildGroups(state.countries);
  }

  /// Build groups of countries.
  List<(String, List<Country>)> _buildGroups(List<Country> countries) {
    final result = <(String, List<Country>)>[];
    List<Country>? bucket;
    String? currentKey;

    for (final country in countries) {
      final name = country.nameLocalized;
      if (name == null || name.isEmpty) continue;

      final key = name.characters.first.toUpperCase();
      if (key != currentKey) {
        currentKey = key;
        bucket = <Country>[];
        result.add((key, bucket));
      }
      bucket?.add(country);
    }

    return result;
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
    const radius = Radius.circular(_kIOS26SectionRadius);
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

        // --- Grouped countries (iOS 26 style) --- //
        if (state.showGroup && pickerTheme.useIOS26) {
          return ValueListenableBuilder(
            valueListenable: _groups,
            builder: (_, groups, _) => ValueListenableBuilder(
              valueListenable: _selected,
              builder: (_, selected, _) => SliverMainAxisGroup(
                slivers: <Widget>[
                  for (final (key, countries) in groups)
                    SliverMainAxisGroup(
                      slivers: <Widget>[
                        SliverPersistentHeader(
                          key: ValueKey<String>('header_$key'),
                          floating: true,
                          pinned: true,
                          delegate: _SliverHeaderDelegate(
                            maxHeight: 36,
                            minHeight: 36,
                            child: ColoredBox(
                              key: ValueKey('header_child_$key'),
                              color:
                                  pickerTheme.backgroundColor ??
                                  Colors.transparent,
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start: pickerTheme.padding * 2,
                                  end: pickerTheme.padding * 2,
                                  top: pickerTheme.padding / 2,
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    key,
                                    style: TextStyle(
                                      height: 1,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoDynamicColor.resolve(
                                        CupertinoColors.secondaryLabel,
                                        context,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        _buildIOS26Section(countries, selected),
                      ],
                    ),
                ],
              ),
            ),
          );
        }

        // --- Grouped countries --- //
        if (state.showGroup) {
          return ValueListenableBuilder(
            valueListenable: _groups,
            builder: (_, groups, _) {
              final slivers = <Widget>[
                for (final (key, countries) in groups)
                  SliverMainAxisGroup(
                    slivers: <Widget>[
                      SliverPersistentHeader(
                        key: ValueKey<String>('header_$key'),
                        floating: true,
                        pinned: true,
                        delegate: _SliverHeaderDelegate(
                          maxHeight: 26,
                          minHeight: 26,
                          child: DecoratedBox(
                            key: ValueKey('header_child_$key'),
                            decoration: BoxDecoration(
                              color: pickerTheme.secondaryBackgroundColor,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: pickerTheme.padding,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  key,
                                  style: TextStyle(
                                    height: 1,
                                    fontSize: 15,
                                    fontWeight: switch (defaultTargetPlatform) {
                                      .iOS => .w700,
                                      _ => .w600,
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverList.separated(
                        itemCount: countries.length,
                        itemBuilder: (_, index) {
                          final country = countries[index];
                          return _CountryListTile(
                            key: ValueKey<String>(country.e164Key),
                            onSelect: (country) {
                              // Notify external listeners first so they can
                              // compare against the previous SelectedCountry
                              // value, then update the notifier itself.
                              widget.onSelect?.call(country);
                              widget.selected?.value = country;
                            },
                            country: country,
                          );
                        },
                        separatorBuilder: (_, _) => Divider(
                          height: 1,
                          thickness: 1,
                          indent: pickerTheme.padding,
                          endIndent: pickerTheme.padding,
                          color: pickerTheme.dividerColor,
                        ),
                      ),
                    ],
                  ),
              ];

              return SliverMainAxisGroup(slivers: slivers);
            },
          );
        }

        // --- Plain countries list (iOS 26 style) --- //
        if (pickerTheme.useIOS26) {
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
    label: '${nameLocalized ?? country.name}, +${country.phoneCode}',
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
            if (effectiveTrailing != null) effectiveTrailing,
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
              width: _kIOS26PhoneCodeWidth,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${isRtl ? '' : '+'}${country.phoneCode}'
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
      child: Text(
        country.iswWorldWide
            ? '\uD83C\uDF0D'
            : CountryUtil.countryCodeToEmoji(country.countryCode),
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

  /// Whether the platform emoji font can draw flag glyphs.
  ///
  /// Windows' Segoe UI Emoji has no flags and renders the regional
  /// indicator pair as two letters. Flutter web always falls back to
  /// Noto Color Emoji, which has flags on every host OS.
  static bool get _hasFlagGlyphs =>
      kIsWeb || defaultTargetPlatform != TargetPlatform.windows;

  /// How much the emoji glyph is scaled to cover the whole circle.
  ///
  /// Emoji flags are rectangular glyphs with transparent padding.
  /// Apple Color Emoji (iOS, macOS) draws waving flags with extra space
  /// around them, so it needs a bigger scale than the flat Noto flags
  /// used on Android, Linux and the web.
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
        CupertinoDynamicColor.resolve(
          CupertinoColors.secondarySystemBackground,
          context,
        );

    final emoji = country.iswWorldWide
        ? '\uD83C\uDF0D'
        : CountryUtil.countryCodeToEmoji(country.countryCode);
    final scale = _scaleOf(country);

    final Widget flag;
    if (country.iswWorldWide || _hasFlagGlyphs) {
      flag = OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: Text(
          emoji,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: _kIOS26FlagSize * scale, height: 1),
        ),
      );
    } else {
      // No flag glyphs: show the ISO code in a tinted circle instead
      // of a cropped pair of regional indicator letters.
      flag = ColoredBox(
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.tertiarySystemFill,
          context,
        ),
        child: Center(
          child: Text(
            country.countryCode.toUpperCase(),
            style: TextStyle(
              height: 1,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.secondaryLabel,
                context,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox.square(
      dimension: _kIOS26FlagSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          ClipOval(
            child: SizedBox.square(dimension: _kIOS26FlagSize, child: flag),
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

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  /// {@macro countries_list_view}
  _SliverHeaderDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  final Widget child;
  final double minHeight;
  final double maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Semantics(header: true, child: SizedBox.expand(child: child));

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  bool shouldRebuild(covariant _SliverHeaderDelegate oldDelegate) =>
      oldDelegate.minHeight != minHeight ||
      oldDelegate.maxHeight != maxHeight ||
      oldDelegate.child.key != child.key;
}

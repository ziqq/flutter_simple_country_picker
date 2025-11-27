import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/controller/country_controller.dart';
import 'package:flutter_simple_country_picker/src/controller/country_provider.dart';
import 'package:flutter_simple_country_picker/src/util/country_util.dart';
import 'package:flutter_simple_country_picker/src/widget/status_bar_gesture_detector.dart';
import 'package:meta/meta.dart';

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
    this.favorite,
    this.filter,
    this.selected,
    this.onSelect,
    this.autofocus = false,
    @Deprecated(
      'Use autofocus instead. This will be removed in v1.0.0 releases.',
    )
    this.useAutofocus = false,
    this.showPhoneCode = false,
    this.showWorldWide = false,
    this.useHaptickFeedback = true,
    bool? showSearch,
    super.key,
  }) : showSearch = showSearch ?? filter == null || filter.length > 8,
       assert(
         filter == null || exclude == null,
         'Cannot provide both filter and exclude',
       );

  /// An optional argument for autofocus the search bar.
  final bool autofocus;

  /// An optional argument for showing search bar.
  final bool showSearch;

  /// An optional [showPhoneCode] argument can be used to show phone code.
  final bool showPhoneCode;

  /// An optional argument for showing "World Wide"
  /// option at the beginning of the list
  final bool showWorldWide;

  /// An optional argument for autofocus the search bar.
  @Deprecated('Use autofocus instead. This will be removed in v1.0.0 releases.')
  final bool useAutofocus;

  /// Whether to use haptic feedback on user interactions.
  final bool useHaptickFeedback;

  /// {@macro select_country_callback}
  final SelectCountryCallback? onSelect;

  /// {@macro select_country_notifier}
  final SelectedCountry? selected;

  /// An optional [exclude] argument can be used to exclude(remove) one ore more
  /// country from the countries list. It takes a list of country code(iso2).
  /// Note: Can't provide both [exclude] and [filter]
  final List<String>? exclude;

  /// An optional [favorite] argument can be used to show countries
  /// at the top of the list. It takes a list of country code(iso2).
  final List<String>? favorite;

  /// An optional [filter] argument can be used to filter the
  /// list of countries. It takes a list of country code(iso2).
  /// Note: Can't provide both [filter] and [exclude]
  final List<String>? filter;

  @override
  State<CountryListView> createState() => _CountriesListViewState();
}

/// State for [CountryListView].
class _CountriesListViewState extends State<CountryListView> {
  final ScrollController _scrollController = ScrollController();
  late final CountryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CountryController(
      provider: CountryProvider(),
      favorite: widget.favorite,
      exclude: widget.exclude,
      filter: widget.filter,
      showPhoneCode: widget.showPhoneCode,
    )..getCountries();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.initListeners(CountryLocalizations.of(context));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _unfocus() {
    if (!mounted) return;
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  /// Build divider widget.
  Widget _buildDivider() {
    final pickerTheme = CountryPickerTheme.resolve(context);
    return Padding(
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
    );
  }

  /// Build search bar widget.
  Widget _buildSearchBar() {
    final localization = CountryLocalizations.of(context);
    final pickerTheme = CountryPickerTheme.resolve(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // --- Search bar --- //
        DecoratedBox(
          decoration: BoxDecoration(
            color: pickerTheme.secondaryBackgroundColor,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: pickerTheme.padding,
              vertical: pickerTheme.padding / 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: pickerTheme.indent,
              children: <Widget>[
                // --- Search field --- //
                Flexible(
                  child: CupertinoSearchTextField(
                    autofocus: widget.autofocus || widget.useAutofocus,
                    controller: _controller.search,
                    onSuffixTap: _controller.search?.clear,
                    placeholder: localization?.toLocalizedString(
                      'searchPlaceholder',
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
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
                  padding: EdgeInsets.zero,
                  sizeStyle: CupertinoButtonSize.small,
                  child: Text(
                    localization?.toLocalizedString('cancelButton') ?? 'Cancel',
                  ),
                  onPressed: () {
                    if (widget.useHaptickFeedback) {
                      HapticFeedback.heavyImpact().ignore();
                    }
                    Navigator.of(context, rootNavigator: true).pop<void>();
                  },
                ),
              ],
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

  @override
  Widget build(BuildContext context) {
    final pickerTheme = CountryPickerTheme.resolve(context);
    final localization = CountryLocalizations.of(context);
    final child = GestureDetector(
      onTap: _unfocus,
      child: StatusBarGestureDetector(
        onTap: (_) => StatusBarGestureDetector.scrollToTop(_scrollController),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            // --- Title --- //
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, _) {
                if (state.useGroup) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: pickerTheme.padding,
                      right: pickerTheme.padding,
                      top: pickerTheme.padding / 2,
                      bottom: pickerTheme.padding / 2,
                    ),
                    child: Text(
                      localization?.toLocalizedString('selectCountryLabel') ??
                          'Select your country',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
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
          ],
        ),
      ),
    );
    return Scaffold(
      backgroundColor: pickerTheme.backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ValueListenableBuilder(
          valueListenable: _controller,
          // TODO(ziqq): Refactor to avoid ignore
          // Anton Ustinoff <a.a.ustinoff@gmail.com>, 26 November 2025
          // ignore: unnecessary_underscores
          builder: (_, state, __) => widget.showSearch && state.useGroup
              ? _buildSearchBar()
              : _buildDivider(),
        ),
      ),
      body: child,
    );
  }
}

/// _CountriesList widget.
///
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

  /// {@macro select_country_callback}
  final SelectCountryCallback? onSelect;

  /// {@macro select_country_notifier}
  final SelectedCountry? selected;

  @override
  State<_CountriesList> createState() => _CountriesListState();
}

/// State for widget [_CountriesList].
class _CountriesListState extends State<_CountriesList> {
  final ValueNotifier<List<Widget>> _grouped = ValueNotifier<List<Widget>>([]);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_groupByName);
    WidgetsBinding.instance.addPostFrameCallback((_) => _groupByName());
  }

  @override
  void dispose() {
    super.dispose();
    _grouped.dispose();
    widget.controller.removeListener(_groupByName);
  }

  /// Get grouped countries by name initial letter.
  Map<String, List<Country>>? _getGroupedCountries() {
    if (!mounted) return null;
    final localization = CountryLocalizations.of(context);
    final state = widget.controller.state;
    final countries = state.countries
        .map(
          (country) => country.copyWith(
            nameLocalized: localization
                ?.getCountryNameByCode(country.countryCode)
                ?.replaceAll(CountryLocalizations.countryNameRegExp, ' '),
          ),
        )
        .where(
          (country) =>
              country.nameLocalized != null &&
              (country.nameLocalized?.isNotEmpty ?? false),
        )
        .toList(growable: false);
    final groupedBy = groupBy(countries, (c) => c.nameLocalized![0]);
    return Map<String, List<Country>>.fromEntries(
      groupedBy.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  void _groupByName() {
    if (!mounted || !widget.controller.state.useGroup) return;
    final pickerTheme = CountryPickerTheme.resolve(context);
    final countries = _getGroupedCountries();
    var grouped = <Widget>[];
    countries?.forEach(
      (key, countries) => grouped.add(
        SliverMainAxisGroup(
          slivers: <Widget>[
            SliverPersistentHeader(
              key: ValueKey<String>(key),
              floating: true,
              pinned: true,
              delegate: _SliverHeaderDelegate(
                maxHeight: 13 * 2,
                minHeight: 13 * 2,
                child: DecoratedBox(
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
                        style: const TextStyle(
                          height: 1,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final country = countries[index];
                return _CountryListTile(
                  key: ValueKey<String>(country.e164Key),
                  country: country,
                  onSelect: widget.onSelect,
                  useBorder: index < countries.length - 1,
                );
              }, childCount: countries.length),
            ),
          ],
        ),
      ),
    );
    _grouped.value = grouped;
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: widget.controller,
    builder: (context, state, _) {
      if (state.isLoading)
        return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator.adaptive()),
        );
      else if (state.useGroup)
        return ValueListenableBuilder(
          valueListenable: _grouped,
          // TODO(ziqq): Refactor to avoid ignore
          // Anton Ustinoff <a.a.ustinoff@gmail.com>, 26 November 2025
          // ignore: unnecessary_underscores
          builder: (_, grouped, __) => SliverMainAxisGroup(slivers: grouped),
        );
      else
        return ValueListenableBuilder(
          valueListenable: widget.selected ?? ValueNotifier<Country?>(null),
          builder: (context, selected, _) => SliverList.builder(
            itemCount: state.countries.length,
            itemBuilder: (context, index) {
              final country = state.countries[index];
              return _CountryListTile.simple(
                key: ValueKey<String>(country.e164Key),
                country: country,
                onSelect: widget.onSelect,
                selected: selected == country,
              );
            },
          ),
        );
    },
  );
}

/// _CountryListTile widget.
///
/// {@macro countries_list_view}
class _CountryListTile extends StatelessWidget {
  const _CountryListTile({
    required this.country,
    this.onSelect,
    this.simple = false,
    this.selected = false,
    this.useBorder = false,
    super.key, // ignore: unused_element
  });

  const factory _CountryListTile.simple({
    required Country country,
    SelectCountryCallback? onSelect,
    bool selected,
    Key? key,
  }) = _CountryListTile$Simple;

  /// Use simple variant?
  final bool simple;

  /// Is selected?
  final bool selected;

  /// Use boder?
  final bool useBorder;

  /// Current country.
  final Country country;

  /// {@macro select_country_callback}
  final SelectCountryCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final pickerTheme = CountryPickerTheme.resolve(context);
    final localization = CountryLocalizations.of(context);
    final effectiveTextStyle = pickerTheme.textStyle;

    final nameLocalized = localization
        ?.getCountryNameByCode(country.countryCode)
        ?.replaceAll(CountryLocalizations.countryNameRegExp, ' ');

    final title = Text(
      nameLocalized ?? country.name,
      style: effectiveTextStyle,
    );

    final effectiveTitle = switch (simple) {
      false => title,
      true => Row(
        children: <Widget>[
          title,
          Text(
            ' (${isRtl ? '' : '+'}${country.phoneCode}${isRtl ? '+' : ''})',
            style: effectiveTextStyle,
          ),
        ],
      ),
    };

    final Widget? effectiveTrailing = switch ((simple, selected)) {
      (true, true) => Icon(
        CupertinoIcons.checkmark_circle_fill,
        color: pickerTheme.accentColor,
      ),
      (true, false) => null,
      (false, _) => Text(
        '${isRtl ? '' : '+'}${country.phoneCode}${isRtl ? '+' : ''}',
        style: effectiveTextStyle?.copyWith(
          color: CupertinoDynamicColor.resolve(
            CupertinoColors.secondaryLabel,
            context,
          ),
        ),
      ),
    };

    return Material(
      // Add Material Widget with transparent color
      // so the ripple effect of InkWell will show on tap
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final useHaptickFeedback = context
              .findAncestorStateOfType<_CountriesListViewState>()
              ?.widget
              .useHaptickFeedback;

          if (useHaptickFeedback ?? true) HapticFeedback.heavyImpact().ignore();
          onSelect?.call(country.copyWith(nameLocalized: nameLocalized));
          Navigator.of(context).maybePop<void>();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              dense: true,
              minLeadingWidth: 0,
              contentPadding: EdgeInsets.symmetric(
                horizontal: pickerTheme.padding,
              ),
              // shape: useBorder && !simple
              //     ? Border(
              //         bottom: BorderSide(
              //           color: pickerTheme.dividerColor ??
              //               CupertinoDynamicColor.resolve(
              //                 CupertinoColors.opaqueSeparator,
              //                 context,
              //               ),
              //           width: 1,
              //         ),
              //       )
              //     : null,
              leading: _Flag(country: country),
              title: effectiveTitle,
              trailing: effectiveTrailing,
              subtitle: simple ? null : Text(country.name),
            ),
            if (useBorder && !simple) ...[
              Divider(
                height: 1,
                thickness: 1,
                indent: pickerTheme.padding,
                endIndent: pickerTheme.padding,
                color: pickerTheme.dividerColor,
              ),
            ],
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
  }) : super(simple: true, useBorder: false);
}

/// Flag widget.
///
/// {@macro countries_list_view}
class _Flag extends StatelessWidget {
  /// {@macro countries_list_view}
  const _Flag({
    required this.country,
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
      width: isRtl ? 50 : null,
      child: Text(
        country.iswWorldWide
            ? '\uD83C\uDF0D'
            : CountryUtil.countryCodeToEmoji(country.countryCode),
        style: TextStyle(fontSize: pickerTheme.flagSize ?? 25),
      ),
    );
  }
}

/// {@macro countries_list_view}
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
  ) => SizedBox.expand(child: child);

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/controller/countries_controller.dart';
import 'package:flutter_simple_country_picker/src/controller/countries_state.dart';
import 'package:flutter_simple_country_picker/src/util/util.dart';
import 'package:flutter_simple_country_picker/src/widget/status_bar_gesture_detector.dart';

/// {@template country_list_view}
/// CountriesListView widget.
///
/// This widget is used to display a list of countries.
///
/// The [CountriesListView] widget requires a [onSelect] callback,
/// which is called when a country is selected.
///
/// The [exclude] argument can be used to exclude(remove) one ore more
/// country from the countries list. It takes a list of country code(iso2).
///
/// The [filter] argument can be used to filter the
/// list of countries. It takes a list of country code(iso2).
///
/// The [favorite] argument can be used to show countries
/// at the top of the list. It takes a list of country code(iso2).
///
/// The [showPhoneCode] argument can be used to show phone code.
///
/// The [showWorldWide] argument can be used to show "World Wide"
///
/// The [useAutofocus] argument can be used
/// to initially expand virtual keyboard.
///
/// The [showSearch] argument can be used to show/hide the search bar.
/// {@endtemplate}
class CountriesListView extends StatefulWidget {
  /// {@macro country_list_view}
  const CountriesListView({
    this.onSelect,
    this.exclude,
    this.favorite,
    this.filter,
    this.showPhoneCode = false,
    this.showWorldWide = false,
    this.useAutofocus = false,
    bool? showSearch,
    super.key,
  }) : showSearch = showSearch ?? filter == null || filter.length > 8;

  /// An optional argument for hiding the search bar
  final bool showSearch;

  /// An optional [showPhoneCode] argument can be used to show phone code.
  final bool showPhoneCode;

  /// An optional argument for showing "World Wide"
  /// option at the beginning of the list
  final bool showWorldWide;

  /// An optional argument for initially expanding virtual keyboard
  final bool useAutofocus;

  /// Called when a country is select.
  ///
  /// The country picker passes the new value to the callback.
  final ValueChanged<Country>? onSelect;

  /// An optional [exclude] argument can be used to exclude(remove) one ore more
  /// country from the countries list. It takes a list of country code(iso2).
  /// Note: Can't provide both [exclude] and [filter]
  final List<String>? exclude;

  /// An optional [filter] argument can be used to filter the
  /// list of countries. It takes a list of country code(iso2).
  /// Note: Can't provide both [filter] and [exclude]
  final List<String>? filter;

  /// An optional [favorite] argument can be used to show countries
  /// at the top of the list. It takes a list of country code(iso2).
  final List<String>? favorite;

  @override
  State<CountriesListView> createState() => _CountriesListViewState();
}

/// State for [CountriesListView].
class _CountriesListViewState extends State<CountriesListView> {
  final ScrollController _scrollController = ScrollController();
  late final CountriesController _controller;

  bool _useGroup(List<Country> countries) => countries.length > 8;

  @override
  void initState() {
    super.initState();
    _controller = CountriesController(
      provider: CountriesProvider(),
      favorite: widget.favorite,
      exclude: widget.exclude,
      filter: widget.filter,
      showPhoneCode: widget.showPhoneCode,
    )..getCountries();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _controller.dispose();
  }

  void _unfocus() {
    if (!mounted) return;
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  Widget _buildDivider() {
    final pickerTheme = CountryPickerTheme.resolve(context);
    return Align(
      heightFactor: 2,
      child: Container(
        width: 36,
        height: 5,
        margin: const EdgeInsets.only(top: 5),
        decoration: BoxDecoration(
          color: pickerTheme.dividerColor,
          borderRadius: const BorderRadius.all(Radius.circular(30)),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final localization = CountriesLocalization.of(context);
    final pickerTheme = CountryPickerTheme.resolve(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- Search bar --- //
        ColoredBox(
          color: pickerTheme.stickyHeaderBackgroundColor ?? Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: pickerTheme.padding,
              vertical: pickerTheme.padding / 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: ValueListenableBuilder<CountriesState>(
                    valueListenable: _controller,
                    builder: (context, state, _) => CupertinoSearchTextField(
                      placeholder: localization.search,
                      autofocus: widget.useAutofocus,
                      controller: _controller.searchController,
                      onChanged: (_) => _controller.search(localization),
                      onSuffixTap: () {
                        _controller.searchController.clear();
                        _controller.search(localization);
                      },
                      suffixInsets: EdgeInsetsDirectional.only(
                        end: pickerTheme.indent / 2,
                      ),
                      prefixInsets: EdgeInsetsDirectional.only(
                        start: pickerTheme.padding / 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: pickerTheme.indent),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text(localization.cancel),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
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
            color: pickerTheme.dividerColor ??
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
    final child = SafeArea(
      child: GestureDetector(
        onTap: _unfocus,
        child: StatusBarGestureDetector(
          onTap: (_) => StatusBarGestureDetector.scrollToTop(_scrollController),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              _CountriesList(
                controller: _controller,
                onSelect: widget.onSelect,
              ),
            ],
          ),
        ),
      ),
    );
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: (context, state, _) => Scaffold(
        backgroundColor: pickerTheme.backgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 5),
          child: widget.showSearch && _useGroup(state.countries)
              ? _buildSearchBar()
              : _buildDivider(),
        ),
        body: child,
      ),
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
    this.onSelect,
    super.key, // ignore: unused_element
  });

  final CountriesController controller;
  final ValueChanged<Country>? onSelect;

  @override
  State<_CountriesList> createState() => _CountriesListState();
}

/// State for widget [_CountriesList].
class _CountriesListState extends State<_CountriesList> {
  final ValueNotifier<List<Widget>> _grouped = ValueNotifier([]);

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

  bool _useGroup(List<Country> countries) {
    final parent = context.findAncestorStateOfType<_CountriesListViewState>();
    return parent?._useGroup(countries) ?? false;
  }

  Map<String, List<Country>>? _getGroupedCountries() {
    if (!mounted) return null;
    final localization = CountriesLocalization.of(context);
    final state = widget.controller.state;
    final countries = state.countries.map(
      (e) => e.copyWith(
        nameLocalized: localization
            .getCountryNameByCode(e.countryCode)
            ?.replaceAll(CountriesLocalization.countryNameRegExp, ' '),
      ),
    );
    final groupedBy = groupBy(countries, (c) => c.nameLocalized![0]);
    return Map.fromEntries(
        groupedBy.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  void _groupByName() {
    if (!mounted) return;
    final state = widget.controller.state;
    if (!_useGroup(state.countries)) return;
    final pickerTheme = CountryPickerTheme.resolve(context);
    final countries = _getGroupedCountries();
    var grouped = <Widget>[];
    countries?.forEach(
      (key, countries) => grouped.add(
        SliverMainAxisGroup(
          slivers: <Widget>[
            SliverPersistentHeader(
              key: ValueKey(key),
              floating: true,
              pinned: true,
              delegate: _SliverHeaderDelegate(
                maxHeight: 13 * 2,
                minHeight: 13 * 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: pickerTheme.stickyHeaderBackgroundColor,
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
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final country = countries[index];
                  return _CountryListItem(
                    country: country,
                    onSelect: widget.onSelect,
                    useBorder: index < countries.length - 1,
                  );
                },
                childCount: countries.length,
              ),
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
          else if (_useGroup(state.countries))
            return ValueListenableBuilder(
              valueListenable: _grouped,
              builder: (_, grouped, __) => SliverMainAxisGroup(
                slivers: grouped,
              ),
            );
          else
            return SliverList.builder(
              itemCount: state.countries.length,
              itemBuilder: (context, index) => _CountryListItem.simple(
                country: state.countries[index],
                onSelect: widget.onSelect,
              ),
            );
        },
      );
}

/// CountryListItem widget.
///
/// {@macro countries_list_view}
class _CountryListItem extends StatelessWidget {
  const _CountryListItem({
    required this.country,
    this.useBorder = false,
    this.simple = false,
    this.onSelect,
    super.key, // ignore: unused_element
  });

  const factory _CountryListItem.simple({
    required Country country,
    ValueChanged<Country>? onSelect,
  }) = _CountryListItem$Simple;

  /// Use simple variant?
  final bool simple;

  /// Use boder?
  final bool useBorder;

  /// Current country.
  final Country country;

  /// Called when a country is select.
  ///
  /// The country picker passes the new value to the callback.
  final ValueChanged<Country>? onSelect;

  @override
  Widget build(BuildContext context) {
    final localization = CountriesLocalization.of(context);
    final pickerTheme = CountryPickerTheme.resolve(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final effectiveTextStyle =
        pickerTheme.textStyle ?? Theme.of(context).textTheme.bodyLarge;

    final nameLocalized = localization
        .getCountryNameByCode(country.countryCode)
        ?.replaceAll(CountriesLocalization.countryNameRegExp, ' ');

    final title =
        Text(nameLocalized ?? country.name, style: effectiveTextStyle);

    final effectiveTitle = switch (simple) {
      false => title,
      true => Row(
          children: [
            title,
            Text(
              ' (${isRtl ? '' : '+'}${country.phoneCode}${isRtl ? '+' : ''})',
              style: effectiveTextStyle,
            ),
          ],
        ),
    };

    return Material(
      // Add Material Widget with transparent color
      // so the ripple effect of InkWell will show on tap
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onSelect?.call(country.copyWith(nameLocalized: nameLocalized));
          Navigator.of(context).maybePop();
        },
        child: ListTile(
          dense: true,
          minLeadingWidth: 0,
          contentPadding: EdgeInsets.only(
            left: pickerTheme.padding,
            right: pickerTheme.padding,
            top: simple ? pickerTheme.padding / 8 : 0,
            bottom: simple ? pickerTheme.padding / 8 : pickerTheme.padding / 4,
          ),
          shape: useBorder && !simple
              ? Border(
                  bottom: BorderSide(
                    color: pickerTheme.dividerColor!,
                    width: 0.5,
                  ),
                )
              : null,
          leading: _Flag(country: country),
          trailing: simple
              ? null
              : Text(
                  '${isRtl ? '' : '+'}${country.phoneCode}${isRtl ? '+' : ''}',
                  style: effectiveTextStyle?.copyWith(
                    color: CupertinoDynamicColor.resolve(
                      CupertinoColors.secondaryLabel,
                      context,
                    ),
                  ),
                ),
          title: effectiveTitle,
          subtitle: simple ? null : Text(country.name),
        ),
      ),
    );
  }
}

/// {@macro countries_list_view}
class _CountryListItem$Simple extends _CountryListItem {
  /// {@macro countries_list_view}
  const _CountryListItem$Simple({
    required super.country,
    super.onSelect,
  }) : super(simple: true, useBorder: false);
}

/// Flag widget.
///
/// {@macro countries_list_view}
class _Flag extends StatelessWidget {
  /// {@macro countries_list_view}
  const _Flag({
    required this.country,
    super.key, // ignore: unused_element
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
            : Util.countryCodeToEmoji(country.countryCode),
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
  ) =>
      SizedBox.expand(child: child);

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  bool shouldRebuild(
    covariant SliverPersistentHeaderDelegate oldDelegate,
  ) =>
      true;
}

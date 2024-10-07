// ignore_for_file: unused_element

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/controller/countries_controller.dart';
import 'package:flutter_simple_country_picker/src/controller/countries_state.dart';
import 'package:flutter_simple_country_picker/src/util/util.dart';
import 'package:flutter_simple_country_picker/src/widget/status_bar_gesture_detector.dart';

/// {@template country_list_view}
/// CountriesListView widget.
/// {@endtemplate}
class CountriesListView extends StatefulWidget {
  /// {@macro country_list_view}
  const CountriesListView({
    required this.onSelect,
    this.exclude,
    this.favorite,
    this.countryFilter,
    this.showSearch = true,
    this.showPhoneCode = false,
    this.showWorldWide = false,
    this.searchAutofocus = false,
    super.key,
  });

  /// An optional argument for hiding the search bar
  final bool showSearch;

  /// An optional [showPhoneCode] argument can be used to show phone code.
  final bool showPhoneCode;

  /// An optional argument for showing "World Wide"
  /// option at the beginning of the list
  final bool showWorldWide;

  /// An optional argument for initially expanding virtual keyboard
  final bool searchAutofocus;

  /// Called when a country is select.
  ///
  /// The country picker passes the new value to the callback.
  final ValueChanged<Country> onSelect;

  /// An optional [exclude] argument can be used to exclude(remove) one ore more
  /// country from the countries list. It takes a list of country code(iso2).
  /// Note: Can't provide both [exclude] and [countryFilter]
  final List<String>? exclude;

  /// An optional [countryFilter] argument can be used to filter the
  /// list of countries. It takes a list of country code(iso2).
  /// Note: Can't provide both [countryFilter] and [exclude]
  final List<String>? countryFilter;

  /// An optional [favorite] argument can be used to show countries
  /// at the top of the list. It takes a list of country code(iso2).
  final List<String>? favorite;

  @override
  State<CountriesListView> createState() => _CountriesListViewState();
}

/// State for [CountriesListView].
class _CountriesListViewState extends State<CountriesListView> {
  // final CountriesProvider _countryProvider = CountriesProvider();
  final ScrollController _scrollController = ScrollController();

  late final CountriesController _controller;

  // late List<Country> _countriesList;
  // late List<Country> _filteredList;
  // List<Country>? _favoriteList;
  // late bool _searchAutofocus;
  // late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _controller = CountriesController(
      provider: CountriesProvider(),
      exclude: widget.exclude,
      showPhoneCode: widget.showPhoneCode,
    )..getCountries();

    // _searchController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    // _searchController.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CountriesLocalization.of(context);
    final cancelButtonText = t?.countryName(countryCode: 'cancel') ?? 'Отмена';
    final searchPlaceholder = t?.countryName(countryCode: 'search') ?? 'Поиск';

    final countryPickerTheme = CountryPickerTheme.of(context);

    final Widget header = ColoredBox(
      color: countryPickerTheme.stickyHeaderBackgroundColor ?? Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: countryPickerTheme.padding,
          vertical: countryPickerTheme.padding / 2,
        ),
        child: Material(
          color: countryPickerTheme.stickyHeaderBackgroundColor,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ValueListenableBuilder<CountriesState>(
                  valueListenable: _controller,
                  builder: (context, state, _) => CupertinoSearchTextField(
                    autofocus: widget.searchAutofocus,
                    placeholder: searchPlaceholder,
                    controller: _controller.searchController,
                    onChanged: (query) => _controller.search(t),
                    onSuffixTap: () {
                      _controller.searchController.clear();
                      _controller.search(t);
                    },
                    suffixInsets: EdgeInsetsDirectional.only(
                      end: countryPickerTheme.indent / 2,
                    ),
                    prefixInsets: EdgeInsetsDirectional.only(
                      start: countryPickerTheme.padding / 2,
                    ),
                    style: countryPickerTheme.searchTextStyle,
                  ),
                ),
              ),
              SizedBox(width: countryPickerTheme.indent),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text(cancelButtonText),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            final currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: StatusBarGestureDetector(
            onTap: (context) => _scrollController.animateTo(
              0,
              curve: Curves.easeOutCirc,
              duration: const Duration(milliseconds: 1000),
            ),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                PinnedHeaderSliver(child: header),
                ValueListenableBuilder<CountriesState>(
                  valueListenable: _controller,
                  builder: (context, state, _) => SliverList.builder(
                    itemCount: state.countries.length,
                    itemBuilder: (context, index) => _CountryListItem(
                      country: state.countries[index],
                      onSelect: widget.onSelect,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// CountryListItem widget.
///
/// {@macro countries_list_view}
class _CountryListItem extends StatelessWidget {
  const _CountryListItem({
    required this.country,
    this.onSelect,
    super.key,
  });

  /// Current country.
  final Country country;

  /// Called when a country is select.
  ///
  /// The country picker passes the new value to the callback.
  final ValueChanged<Country>? onSelect;

  @override
  Widget build(BuildContext context) {
    final localizations = CountriesLocalization.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final countryPickerTheme = CountryPickerTheme.maybeOf(context);

    final effectiveTextStyle =
        countryPickerTheme?.textStyle ?? Theme.of(context).textTheme.bodyLarge;

    final effectivePadding =
        EdgeInsets.symmetric(horizontal: countryPickerTheme?.padding ?? 16);

    return Material(
      // Add Material Widget with transparent color
      // so the ripple effect of InkWell will show on tap
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onSelect?.call(country.copyWith(
            nameLocalized: localizations
                ?.countryName(countryCode: country.countryCode)
                ?.replaceAll(RegExp(r'\s+'), ' '),
          ));
          Navigator.of(context).maybePop();
        },
        child: ListTile(
          dense: true,
          minLeadingWidth: 0,
          contentPadding: effectivePadding,
          leading: _Flag(
            country: country,
            countryPickerTheme: countryPickerTheme,
          ),
          trailing: Text(
            '${isRtl ? '' : '+'}${country.phoneCode}${isRtl ? '+' : ''}',
            style: effectiveTextStyle,
          ),
          title: Text(
            localizations
                    ?.countryName(countryCode: country.countryCode)
                    ?.replaceAll(RegExp(r'\s+'), ' ') ??
                country.name,
            style: effectiveTextStyle,
          ),
        ),
      ),
    );
  }
}

/// Flag widget.
///
/// {@macro countries_list_view}
class _Flag extends StatelessWidget {
  const _Flag({
    required this.country,
    super.key,
    this.countryPickerTheme,
  });
  final Country country;
  final CountryPickerTheme? countryPickerTheme;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final countryPickerTheme = CountryPickerTheme.maybeOf(context);
    return SizedBox(
      // The conditional 50 prevents irregularities
      // caused by the flags in RTL mode
      width: isRtl ? 50 : null,
      child: Text(
        country.iswWorldWide
            ? '\uD83C\uDF0D'
            : Util.countryCodeToEmoji(country.countryCode),
        style: TextStyle(
          fontSize: countryPickerTheme?.flagSize ?? 25,
        ),
      ),
    );
  }
}

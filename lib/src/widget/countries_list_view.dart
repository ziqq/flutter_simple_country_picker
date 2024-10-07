// ignore_for_file: unused_element

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
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
  final CountriesProvider _countryService = CountriesProvider();
  final ScrollController _scrollController = ScrollController();

  late bool _searchAutofocus;
  late List<Country> _countryList;
  late List<Country> _filteredList;
  late TextEditingController _searchController;

  // List<Country>? _favoriteList;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    final stopwatch = Stopwatch()..start();

    _countryList = _countryService.getAll();

    // Remove duplicates country if not use phone code
    if (!widget.showPhoneCode) {
      final ids = _countryList.map((e) => e.countryCode).toSet();
      _countryList.retainWhere((c) => ids.remove(c.countryCode));
    }

    // if (widget.favorite != null) {
    //   _favoriteList = _countryService.findCountriesByCode(widget.favorite!);
    // }

    if (widget.exclude != null) {
      _countryList.removeWhere(
        (e) => widget.exclude!.contains(e.countryCode),
      );
    }

    if (widget.countryFilter != null) {
      _countryList.removeWhere(
        (e) => !widget.countryFilter!.contains(e.countryCode),
      );
    }

    _filteredList = <Country>[];

    if (widget.showWorldWide) {
      _filteredList.add(Country.worldWide);
    }

    _filteredList.addAll(_countryList);

    _searchAutofocus = widget.searchAutofocus;
    log(
      '${(stopwatch..stop()).elapsedMicroseconds} μs',
      name: 'CountriesListView > initState',
      level: 100,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _scrollController.dispose();
  }

  void _filterSearchResults(String query) {
    final localizations = CountriesLocalization.of(context);

    var searchResult = <Country>[];

    if (query.isEmpty) {
      searchResult.addAll(_countryList);
    } else {
      searchResult = _countryList
          .where((c) => c.startsWith(query, localizations))
          .toList();
    }

    setState(() => _filteredList = List.unmodifiable(searchResult));
  }

  @override
  Widget build(BuildContext context) {
    final t = CountriesLocalization.of(context);
    final cancelButtonText = t?.countryName(countryCode: 'cancel') ?? 'Отмена';
    final searchPlaceholder = t?.countryName(countryCode: 'search') ?? 'Поиск';

    final countryPickerTheme = CountryPickerTheme.of(context);

    final header = Container(
      color: countryPickerTheme.stickyHeaderBackgroundColor,
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
              child: CupertinoSearchTextField(
                placeholder: searchPlaceholder,
                autofocus: _searchAutofocus,
                controller: _searchController,
                onChanged: _filterSearchResults,
                suffixInsets: EdgeInsetsDirectional.only(
                  end: countryPickerTheme.indent / 2,
                ),
                style: countryPickerTheme.searchTextStyle,
              ),
            ),
            SizedBox(width: countryPickerTheme.indent),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text(cancelButtonText),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
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
                SliverList.builder(
                  itemCount: _countryList.length,
                  itemBuilder: (context, index) => _CountryListItem(
                    country: _countryList[index],
                    onSelect: widget.onSelect,
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

/// {@template country_list_view}
/// _CountryListItem widget.
/// {@endtemplate}
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

class _CountryListController extends ChangeNotifier {}

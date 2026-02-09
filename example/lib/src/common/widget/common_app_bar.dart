import 'package:example/src/common/constant/pubspec.yaml.g.dart';
import 'package:example/src/common/widget/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart'
    show CountryPickerTheme;

/// {@template common_app_bar}
/// CommonAppBar widget.
/// {@endtemplate}
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// {@macro common_app_bar}
  const CommonAppBar({
    this.backgroundColor,
    this.bottom,
    this.title,
    super.key,
  });

  /// Title of the header.
  final String? title;

  /// Background color of the header.
  final Color? backgroundColor;

  /// Bottom widget of the app bar.
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /// {@macro scaffold_padding}
  static Widget sliver(String title, [Widget? child]) => SliverAppBar(
    pinned: true,
    title: _Header(title),
    leading: const AppLocaleSwitcherButton(),
    actions: const [AppThemeModeSwitcherButton()],
  );

  @override
  Widget build(BuildContext context) => AppBar(
    centerTitle: true,
    bottom: bottom,
    backgroundColor: backgroundColor,
    title: title != null && title!.isNotEmpty ? _Header(title!) : null,
    leading: Row(
      children: [
        SizedBox(width: CountryPickerTheme.of(context).padding),
        const AppLocaleSwitcherButton(),
      ],
    ),
    actions: const [AppThemeModeSwitcherButton()],
  );
}

/// Title widget of [CommonAppBar].
///
/// {@macro common_app_bar}
class _Header extends StatelessWidget {
  /// {@macro common_app_bar}
  const _Header(
    this.title, {
    super.key, // ignore: unused_element_parameter
  });

  /// Title of the header.
  final String title;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      Text(
        'Version: ${Pubspec.version.canonical}',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ],
  );
}

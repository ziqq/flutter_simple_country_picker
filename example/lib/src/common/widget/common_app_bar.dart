/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 11 October 2024
 */

import 'package:example/src/common/constant/pubspec.yaml.g.dart';
import 'package:example/src/common/widget/app.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart'
    show CountryPickerTheme;
import 'package:material_ui/material_ui.dart';

/// {@template common_app_bar}
/// Shows the preview title, app version, and theme and language controls.
/// {@endtemplate}
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// {@macro common_app_bar}
  const CommonAppBar({
    this.title,
    this.backgroundColor,
    this.bottom,
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

  @override
  Widget build(BuildContext context) => AppBar(
    centerTitle: true,
    bottom: bottom,
    backgroundColor: backgroundColor,
    title: switch (title) {
      String title when title.isNotEmpty => _Header(title),
      _ => null,
    },
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
  const _Header(this.title);

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

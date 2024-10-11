import 'package:example/src/common/constant/pubspec.yaml.g.dart';
import 'package:example/src/common/widget/app.dart';
import 'package:flutter/material.dart';

/// {@template common_header}
/// CommonHeader widget.
/// {@endtemplate}
class CommonHeader extends StatelessWidget implements PreferredSizeWidget {
  /// {@macro common_header}
  const CommonHeader(this.title, {super.key});

  /// Title of the header.
  final String title;

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
        title: _Header(title),
        leading: const AppLocaleSwitcherButton(),
        actions: const [AppThemeModeSwitcherButton()],
      );
}

class _Header extends StatelessWidget {
  const _Header(
    this.title, {
    super.key, // ignore: unused_element
  });

  /// Title of the header.
  final String title;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            'Version: ${Pubspec.version.canonical}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
}

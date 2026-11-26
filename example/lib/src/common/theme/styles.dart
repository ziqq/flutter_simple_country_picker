import 'package:material_ui/material_ui.dart';

/// {@template styles}
/// Common styles of the application.
/// {@endtemplate}
class AppStyles {
  /// {@macro styles}
  const AppStyles(this.context);

  /// {@macro styles}
  factory AppStyles.of(BuildContext context) => AppStyles(context);

  /// The [BuildContext] of the application.
  final BuildContext context;

  /// The common dark background color of the application.
  Color? get backgroundColor => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF212121)
      : null;
}

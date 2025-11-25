import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  /// The defalt border of the input fields.
  OutlineInputBorder get defaultBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(
      width: 1,
      color: CupertinoDynamicColor.resolve(CupertinoColors.separator, context),
    ),
  );

  /// The focused border of the input fields.
  InputBorder? get focusedBorder => defaultBorder.copyWith(
    borderSide: defaultBorder.borderSide.copyWith(
      color: Theme.of(context).colorScheme.primary,
    ),
  );

  /// The default text style of the input field.
  TextStyle? get textStyle => Theme.of(context).textTheme.bodyLarge;

  /// The secondary text style of the input field.
  TextStyle? get secodaryTextStyle => textStyle?.copyWith(
    fontSize: 14,
    color: CupertinoDynamicColor.resolve(
      CupertinoColors.secondaryLabel,
      context,
    ),
  );
}

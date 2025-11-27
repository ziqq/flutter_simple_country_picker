import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => group('CountryPickerTheme -', () {
  test('constructs with default values', () {
    final theme = CountryPickerTheme(
      accentColor: CupertinoColors.systemRed,
      backgroundColor: CupertinoColors.systemGrey,
      barrierColor: CupertinoColors.systemBlue,
      dividerColor: CupertinoColors.opaqueSeparator,
      secondaryBackgroundColor: CupertinoColors.systemBackground,
      textStyle: const TextStyle(fontSize: 16),
      searchTextStyle: const TextStyle(fontSize: 14),
      flagSize: 25,
      padding: 16,
      indent: 10,
      radius: 10,
      inputDecoration: const InputDecoration(),
    );

    expect(theme.accentColor, CupertinoColors.systemRed);
    expect(theme.backgroundColor, CupertinoColors.systemGrey);
    expect(theme.barrierColor, CupertinoColors.systemBlue);
    expect(theme.dividerColor, CupertinoColors.opaqueSeparator);
    expect(theme.secondaryBackgroundColor, CupertinoColors.systemBackground);
    expect(theme.textStyle?.fontSize, 16);
    expect(theme.searchTextStyle?.fontSize, 14);
    expect(theme.flagSize, 25.0);
    expect(theme.padding, 16.0);
    expect(theme.indent, 10.0);
    expect(theme.radius, 10.0);
    expect(theme.inputDecoration, isA<InputDecoration>());
  });

  test('copyWith updates properties', () {
    final theme = CountryPickerTheme(
      accentColor: CupertinoColors.systemRed,
      backgroundColor: CupertinoColors.systemGrey,
      barrierColor: CupertinoColors.systemBlue,
      dividerColor: CupertinoColors.opaqueSeparator,
      secondaryBackgroundColor: CupertinoColors.systemBackground,
      textStyle: const TextStyle(fontSize: 16),
      searchTextStyle: const TextStyle(fontSize: 14),
      flagSize: 25,
      padding: 16,
      indent: 10,
      radius: 10,
      inputDecoration: const InputDecoration(),
    );

    final updatedTheme = theme.copyWith(
      accentColor: CupertinoColors.systemYellow,
      backgroundColor: CupertinoColors.systemYellow,
      flagSize: 30,
    );

    expect(updatedTheme.accentColor, CupertinoColors.systemYellow);
    expect(updatedTheme.backgroundColor, CupertinoColors.systemYellow);
    expect(updatedTheme.flagSize, 30.0);
    expect(updatedTheme.barrierColor, theme.barrierColor);
  });

  test('lerp interpolates properties', () {
    final theme1 = CountryPickerTheme(
      accentColor: CupertinoColors.systemRed,
      backgroundColor: Colors.red,
      barrierColor: Colors.blue,
      dividerColor: Colors.green,
      secondaryBackgroundColor: Colors.yellow,
      textStyle: const TextStyle(fontSize: 16),
      searchTextStyle: const TextStyle(fontSize: 14),
      flagSize: 25,
      padding: 10,
      indent: 10,
      radius: 10,
      inputDecoration: const InputDecoration(),
    );

    final theme2 = CountryPickerTheme(
      accentColor: CupertinoColors.systemBlue,
      backgroundColor: Colors.blue,
      barrierColor: Colors.red,
      dividerColor: Colors.purple,
      secondaryBackgroundColor: Colors.orange,
      textStyle: const TextStyle(fontSize: 18),
      searchTextStyle: const TextStyle(fontSize: 16),
      flagSize: 35,
      padding: 20,
      indent: 15,
      radius: 20,
      inputDecoration: const InputDecoration(),
    );

    final lerpedTheme = theme1.lerp(theme2, 0.5) as CountryPickerTheme;

    expect(
      lerpedTheme.accentColor,
      Color.lerp(CupertinoColors.systemRed, CupertinoColors.systemBlue, 0.5),
    );
    expect(
      lerpedTheme.backgroundColor,
      Color.lerp(Colors.red, Colors.blue, 0.5),
    );
    expect(lerpedTheme.barrierColor, Color.lerp(Colors.blue, Colors.red, 0.5));
    expect(lerpedTheme.flagSize, ui.lerpDouble(25.0, 35.0, 0.5));
    expect(lerpedTheme.padding, ui.lerpDouble(10.0, 20.0, 0.5));
    expect(lerpedTheme.radius, ui.lerpDouble(10.0, 20.0, 0.5));
    expect(lerpedTheme.textStyle?.fontSize, 17.0);
  });

  test('equality and hashCode', () {
    final theme1 = CountryPickerTheme(
      accentColor: CupertinoColors.systemRed,
      backgroundColor: Colors.red,
      barrierColor: Colors.blue,
      dividerColor: Colors.green,
      secondaryBackgroundColor: Colors.yellow,
      textStyle: const TextStyle(fontSize: 16),
      searchTextStyle: const TextStyle(fontSize: 14),
      flagSize: 25,
      padding: 10,
      indent: 10,
      radius: 10,
      inputDecoration: const InputDecoration(),
    );

    final theme2 = CountryPickerTheme(
      accentColor: CupertinoColors.systemRed,
      backgroundColor: Colors.red,
      barrierColor: Colors.blue,
      dividerColor: Colors.green,
      secondaryBackgroundColor: Colors.yellow,
      textStyle: const TextStyle(fontSize: 16),
      searchTextStyle: const TextStyle(fontSize: 14),
      flagSize: 25,
      padding: 10,
      indent: 10,
      radius: 10,
      inputDecoration: const InputDecoration(),
    );

    expect(theme1, equals(theme2));
    expect(theme1.hashCode, equals(theme2.hashCode));
  });
});

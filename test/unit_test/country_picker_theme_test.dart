/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 25 October 2024
 */

import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => group('CountryPickerTheme -', () {
  testWidgets('resolves divider and badge colors from a partial theme', (
    tester,
  ) async {
    for (final brightness in Brightness.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: InheritedCountryPickerTheme(
            data: CountryPickerTheme(),
            child: Builder(
              builder: (context) {
                final resolved = CountryPickerTheme.resolve(context);
                expect(
                  resolved.dividerColor,
                  CupertinoDynamicColor.resolve(
                    CupertinoColors.opaqueSeparator,
                    context,
                  ),
                );
                expect(
                  resolved.secondaryBackgroundColor,
                  CupertinoDynamicColor.resolve(
                    CupertinoColors.secondarySystemBackground,
                    context,
                  ),
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    }
  });

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
      baseCornerRadius: 10,
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
    expect(theme.baseCornerRadius, 10.0);
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
      baseCornerRadius: 10,
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
      baseCornerRadius: 10,
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
      baseCornerRadius: 20,
      inputDecoration: const InputDecoration(),
    );

    final lerpedTheme = switch (theme1.lerp(theme2, 0.5)) {
      CountryPickerTheme theme => theme,
      _ => throw StateError('Expected a picker theme.'),
    };

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
    expect(lerpedTheme.baseCornerRadius, ui.lerpDouble(10.0, 20.0, 0.5));
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
      baseCornerRadius: 10,
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
      baseCornerRadius: 10,
      inputDecoration: const InputDecoration(),
    );

    expect(theme1, equals(theme2));
    expect(theme1.hashCode, equals(theme2.hashCode));
  });

  test('lerp with identical other returns same instance', () {
    final theme = CountryPickerTheme(
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
      baseCornerRadius: 10,
      inputDecoration: const InputDecoration(),
    );
    expect(identical(theme.lerp(theme, 0.5), theme), isTrue);
  });

  test('lerp with non-CountryPickerTheme other returns this', () {
    final theme = CountryPickerTheme(
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
      baseCornerRadius: 10,
      inputDecoration: const InputDecoration(),
    );
    // lerp(null, t) → other is! CountryPickerTheme → returns this
    expect(identical(theme.lerp(null, 0.5), theme), isTrue);
  });

  test('equality returns false for non-CountryPickerTheme object', () {
    final theme = CountryPickerTheme(
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
      baseCornerRadius: 10,
      inputDecoration: const InputDecoration(),
    );
    // ignore: unrelated_type_equality_checks
    expect(theme == Object(), isFalse);
  });

  test('equality returns false when individual fields differ', () {
    final base = CountryPickerTheme(
      accentColor: CupertinoColors.systemRed,
      backgroundColor: Colors.red,
      onBackgroundColor: Colors.black,
      barrierColor: Colors.blue,
      dividerColor: Colors.green,
      secondaryBackgroundColor: Colors.yellow,
      onSecondaryBackgroundColor: Colors.purple,
      textStyle: const TextStyle(fontSize: 16),
      searchTextStyle: const TextStyle(fontSize: 14),
      flagSize: 25,
      padding: 10,
      indent: 10,
      baseCornerRadius: 10,
      inputDecoration: const InputDecoration(),
    );

    expect(
      base == base.copyWith(accentColor: CupertinoColors.systemBlue),
      isFalse,
    );
    expect(base == base.copyWith(backgroundColor: Colors.blue), isFalse);
    expect(base == base.copyWith(onBackgroundColor: Colors.white), isFalse);
    expect(base == base.copyWith(dividerColor: Colors.purple), isFalse);
    expect(
      base == base.copyWith(onSecondaryBackgroundColor: Colors.red),
      isFalse,
    );
    expect(
      base == base.copyWith(secondaryBackgroundColor: Colors.green),
      isFalse,
    );
    expect(base == base.copyWith(flagSize: 30), isFalse);
    expect(base == base.copyWith(padding: 20), isFalse);
    expect(base == base.copyWith(indent: 20), isFalse);
    expect(base == base.copyWith(baseCornerRadius: 20), isFalse);
  });

  test('copyWith preserves optional fields (onBackgroundColor etc.)', () {
    final base = CountryPickerTheme(
      accentColor: CupertinoColors.systemRed,
      backgroundColor: Colors.red,
      onBackgroundColor: Colors.black,
      barrierColor: Colors.blue,
      dividerColor: Colors.green,
      secondaryBackgroundColor: Colors.yellow,
      onSecondaryBackgroundColor: Colors.purple,
      textStyle: const TextStyle(fontSize: 16),
      searchTextStyle: const TextStyle(fontSize: 14),
      secondaryTextStyle: const TextStyle(fontSize: 12),
      flagSize: 25,
      padding: 10,
      indent: 10,
      baseCornerRadius: 10,
      inputDecoration: const InputDecoration(),
      inputHeight: 56,
    );

    final updated = base.copyWith(accentColor: CupertinoColors.systemBlue);
    expect(updated.onBackgroundColor, Colors.black);
    expect(updated.onSecondaryBackgroundColor, Colors.purple);
    expect(updated.secondaryTextStyle?.fontSize, 12.0);
    expect(updated.inputHeight, 56.0);
  });

  test('debugFillProperties lists all expected property names', () {
    final theme = CountryPickerTheme(
      accentColor: CupertinoColors.systemRed,
      backgroundColor: Colors.red,
      onBackgroundColor: Colors.black,
      barrierColor: Colors.blue,
      dividerColor: Colors.green,
      secondaryBackgroundColor: Colors.yellow,
      onSecondaryBackgroundColor: Colors.purple,
      textStyle: const TextStyle(fontSize: 16),
      searchTextStyle: const TextStyle(fontSize: 14),
      secondaryTextStyle: const TextStyle(fontSize: 12),
      flagSize: 25,
      padding: 10,
      indent: 10,
      baseCornerRadius: 10,
      inputDecoration: const InputDecoration(),
    );

    final builder = DiagnosticPropertiesBuilder();
    theme.debugFillProperties(builder);
    final names = builder.properties.map((p) => p.name).toList();

    expect(
      names,
      containsAll(<String>[
        'accentColor',
        'backgroundColor',
        'onBackgroundColor',
        'barrierColor',
        'dividerColor',
        'inputDecoration',
        'inputHeight',
        'secondaryBackgroundColor',
        'onSecondaryBackgroundColor',
        'textStyle',
        'secondaryTextStyle',
        'searchTextStyle',
        'flagSize',
        'padding',
        'indent',
        'baseCornerRadius',
        'sheetCornerRadius',
      ]),
    );
  });

  group('indent (deprecated) -', () {
    test('defaults to 10 and is optional in raw', () {
      // ignore: deprecated_member_use_from_same_package
      expect(CountryPickerTheme().indent, 10);
      const theme = CountryPickerTheme.raw(
        accentColor: null,
        backgroundColor: null,
        onBackgroundColor: null,
        barrierColor: null,
        dividerColor: null,
        secondaryBackgroundColor: null,
        onSecondaryBackgroundColor: null,
        inputDecoration: null,
        inputHeight: 56,
        secondaryTextStyle: null,
        searchTextStyle: null,
        textStyle: null,
        flagSize: 22,
        padding: 16,
        // ignore: deprecated_member_use_from_same_package
        radius: 12,
      );
      // ignore: deprecated_member_use_from_same_package
      expect(theme.indent, 10);
      expect(theme.baseCornerRadius, 12);
      expect(theme.sheetCornerRadius, 38);
    });
  });

  group('corner radii -', () {
    test('defaults keep input and sheet corners independent', () {
      final theme = CountryPickerTheme();
      expect(theme.baseCornerRadius, 12);
      expect(theme.sheetCornerRadius, 38);
    });

    test('constructors and copyWith preserve the deprecated radius alias', () {
      // ignore: deprecated_member_use_from_same_package
      final legacy = CountryPickerTheme(radius: 9);
      expect(legacy.baseCornerRadius, 9);
      expect(legacy.sheetCornerRadius, 38);
      // ignore: deprecated_member_use_from_same_package
      expect(legacy.radius, 9);
      // ignore: deprecated_member_use_from_same_package
      expect(legacy.copyWith(radius: 7).baseCornerRadius, 7);
      // ignore: deprecated_member_use_from_same_package
      final preferred = CountryPickerTheme(radius: 9, baseCornerRadius: 16);
      expect(preferred.baseCornerRadius, 16);
      // ignore: deprecated_member_use_from_same_package
      expect(
        legacy.copyWith(radius: 7, baseCornerRadius: 20).baseCornerRadius,
        20,
      );
    });

    test(
      'sheet overrides allow square corners without changing input radius',
      () {
        final theme = CountryPickerTheme(sheetCornerRadius: 0);
        expect(theme.sheetCornerRadius, 0);
        expect(theme.baseCornerRadius, 12);
        expect(theme.copyWith(sheetCornerRadius: 24).sheetCornerRadius, 24);
        expect(theme.copyWith(sheetCornerRadius: 24).baseCornerRadius, 12);
      },
    );

    test('both radii participate in equality, hashing and interpolation', () {
      final start = CountryPickerTheme(
        baseCornerRadius: 8,
        sheetCornerRadius: 0,
      );
      final end = start.copyWith(baseCornerRadius: 16, sheetCornerRadius: 38);
      expect(start, isNot(end));
      expect(start.hashCode, isNot(end.hashCode));
      expect(start, start.copyWith());
      expect(start.hashCode, start.copyWith().hashCode);
      if (start.lerp(end, .5) case CountryPickerTheme middle) {
        expect(middle.baseCornerRadius, 12);
        expect(middle.sheetCornerRadius, 19);
      } else {
        fail('Expected an interpolated CountryPickerTheme.');
      }
    });

    test('diagnostics describe separate corner radii', () {
      final builder = DiagnosticPropertiesBuilder();
      CountryPickerTheme(
        baseCornerRadius: 8,
        sheetCornerRadius: 24,
      ).debugFillProperties(builder);
      final values = {
        for (final property in builder.properties)
          property.name: property.value,
      };
      expect(values['baseCornerRadius'], 8);
      expect(values['sheetCornerRadius'], 24);
      expect(values.containsKey('radius'), isFalse);
    });
  });
});

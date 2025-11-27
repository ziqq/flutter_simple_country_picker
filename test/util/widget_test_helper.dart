// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

/// Example for use it:
/// ```dart
/// testWidgets('description for test',
///   (WidgetTester t) async {
///     await t.pumpWidget(
///       WidgetTestHelper.createWidgetUnderTest(child: const AuthView())
///     );
///
///     final WidgetTestResult result =
///           await WidgetTestHelper.getLocalizationsAndContextUnderTests(t);
///
///     final BuildContext result =
///           await WidgetTestHelper.getContextUnderTest(t);
///
///     final String text =
///                  await WidgetTestHelper.getLocalizationsUnderTests(t)
///                  .then((l) => l.actionSignIn);
///
///     expect(find.text(text), findsOneWidget);
///   },
/// );
/// ```

@internal
final class WidgetTestHelper {
  const WidgetTestHelper._();

  @isTest
  static Future<WidgetTestResult> getLocalizationsAndContextUnderTests(
    WidgetTester t,
  ) async {
    late WidgetTestResult result;
    await t.pumpWidget(
      MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          CountryLocalizations.delegate,
        ],
        supportedLocales: CountryLocalizations.supportedLocales,
        locale: const Locale('ru'),
        home: Material(
          child: Builder(
            builder: (context) {
              result = WidgetTestResult(
                localizations: CountryLocalizations.of(context),
                context: context,
              );

              // The builder function must return a widget.
              return const Placeholder();
            },
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    return result;
  }

  @isTest
  static Future<BuildContext> getContextUnderTest(WidgetTester t) async {
    late BuildContext result;
    await t.pumpWidget(
      Builder(
        builder: (context) {
          result = context;

          // The builder function must return a widget.
          return const Placeholder();
        },
      ),
    );
    return result;
  }

  @isTest
  static Widget createWidgetUnderTest({
    required WidgetBuilder builder,
    Locale locale = const Locale.fromSubtags(languageCode: 'ru'),
  }) => MaterialApp(
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      CountryLocalizations.delegate,
    ],
    locale: locale,
    supportedLocales: CountryLocalizations.supportedLocales,
    home: Builder(builder: (context) => builder(context)),
  );
}

@immutable
@internal
class WidgetTestResult {
  const WidgetTestResult({required this.localizations, required this.context});

  final CountryLocalizations? localizations;
  final BuildContext context;

  @override
  String toString() => 'WidgetTestResult{locale: ${localizations?.locale}}';
}

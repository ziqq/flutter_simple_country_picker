import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/src/util/country_flag_font_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => group('CountryFlagFontUtil -', () {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    CountryFlagFontUtil.debugReset();
    rootBundle.evict(CountryFlagFontUtil.asset);
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    CountryFlagFontUtil.debugReset();
    rootBundle.evict(CountryFlagFontUtil.asset);
    binding.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      null,
    );
  });

  test('uses the platform emoji font outside Windows', () async {
    for (final platform in TargetPlatform.values.where((p) => p != .windows)) {
      debugDefaultTargetPlatformOverride = platform;
      expect(CountryFlagFontUtil.isRequired, isFalse);
      expect(CountryFlagFontUtil.fontFamily, isNull);
      expect(CountryFlagFontUtil.fontFamilyFallback, isNull);
      await CountryFlagFontUtil.ensureLoaded();
    }
  });

  testWidgets('loads the packaged font once and shares the pending load', (
    tester,
  ) async {
    var loads = 0;
    final bytes = File(
      'assets/fonts/TwemojiCountryFlags.ttf',
    ).readAsBytesSync();
    binding.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (
      message,
    ) async {
      expect(
        const StringCodec().decodeMessage(message),
        CountryFlagFontUtil.asset,
      );
      loads++;
      return ByteData.sublistView(bytes);
    });

    await tester.runAsync(() async {
      final first = CountryFlagFontUtil.ensureLoaded();
      expect(CountryFlagFontUtil.ensureLoaded(), same(first));
      expect(CountryFlagFontUtil.fontFamily, CountryFlagFontUtil.family);
      expect(CountryFlagFontUtil.fontFamilyFallback, [
        CountryFlagFontUtil.family,
      ]);
      await first;
      await CountryFlagFontUtil.ensureLoaded();
    });

    expect(loads, 1);
  }, variant: TargetPlatformVariant.only(.windows));

  testWidgets(
    'reports a missing font and retries after the asset is available',
    (tester) async {
      final errors = <FlutterErrorDetails>[];
      final previousOnError = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = previousOnError);
      binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        (_) async => null,
      );

      try {
        await tester.runAsync(CountryFlagFontUtil.ensureLoaded);
      } finally {
        FlutterError.onError = previousOnError;
      }

      expect(errors, hasLength(1));
      expect(errors.single.exception, isA<FlutterError>());
      expect(errors.single.library, 'flutter_simple_country_picker');
      expect(errors.single.context.toString(), contains('while loading'));

      rootBundle.evict(CountryFlagFontUtil.asset);
      final bytes = File(
        'assets/fonts/TwemojiCountryFlags.ttf',
      ).readAsBytesSync();
      var retries = 0;
      binding.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (
        _,
      ) async {
        retries++;
        return ByteData.sublistView(bytes);
      });
      await tester.runAsync(CountryFlagFontUtil.ensureLoaded);
      expect(retries, 1);
      expect(errors, hasLength(1));
    },
    variant: TargetPlatformVariant.only(.windows),
  );
});

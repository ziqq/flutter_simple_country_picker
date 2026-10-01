/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 01 October 2026
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// {@template country_flag_font}
/// Flag glyphs for platforms whose emoji font has no country flags.
///
/// Windows' Segoe UI Emoji renders a flag emoji as two regional indicator
/// letters. On Windows the package loads the bundled "Twemoji Country Flags"
/// font (a flags-only subset of Twemoji, CC-BY 4.0), which is declared as a
/// Windows-only asset, so other platforms do not ship it.
///
/// Flutter web is not affected: it always falls back to Noto Color Emoji.
/// {@endtemplate}
@internal
abstract final class CountryFlagFont {
  /// {@macro country_flag_font}
  const CountryFlagFont._();

  /// The font family registered with [FontLoader].
  static const String family = 'TwemojiCountryFlags';

  /// The bundled font asset key.
  static const String asset =
      'packages/flutter_simple_country_picker/assets/fonts/'
      'TwemojiCountryFlags.ttf';

  static Future<void>? _loading;

  /// Whether flags need the bundled font on the current platform.
  static bool get isRequired =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  /// The family to use for a flag-only text, or `null` to use the
  /// platform emoji font.
  ///
  /// Starts loading the font on first use; text is laid out again
  /// automatically once the font is registered.
  /// Apply this family to a flag's text span so the surrounding text style's
  /// package and fallback fonts are preserved.
  static String? get fontFamily {
    if (!isRequired) return null;
    ensureLoaded();
    return family;
  }

  /// The fallback list for a text that mixes flags with other characters,
  /// or `null` to use the platform emoji font.
  static List<String>? get fontFamilyFallback {
    if (!isRequired) return null;
    ensureLoaded();
    return const <String>[family];
  }

  /// Loads the font once. Safe to call from `build`.
  static Future<void> ensureLoaded() {
    if (!isRequired) return Future<void>.value();
    return _loading ??= (FontLoader(family)..addFont(rootBundle.load(asset)))
        .load()
        .catchError((Object error, StackTrace stackTrace) {
          // Allow a retry and fall back to the platform emoji font.
          _loading = null;
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stackTrace,
              library: 'flutter_simple_country_picker',
              context: ErrorDescription('while loading $family'),
            ),
          );
        });
  }

  /// Forgets the loading state, for tests.
  @visibleForTesting
  static void debugReset() => _loading = null;
}

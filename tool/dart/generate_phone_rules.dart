/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 4 November 2026
 */

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_simple_country_picker/src/constant/country_codes.dart';
import 'package:xml/xml.dart';

const _kMetadataCommit = '8593ab70fa4fadffc042b2714034f4c52bef7daf';
const _kMetadataSha256 =
    'b6491939ddaeb9d585a34fe0f0ebd096e83c5ac9a1c5d6dddf38ba4b162b28ca';
const _kMetadataUrl =
    'https://raw.githubusercontent.com/google/libphonenumber/$_kMetadataCommit/resources/PhoneNumberMetadata.xml';
const _kTypeTags = <String>[
  'fixedLine',
  'mobile',
  'pager',
  'tollFree',
  'premiumRate',
  'sharedCost',
  'personalNumber',
  'voip',
  'uan',
  'voicemail',
];

/// Generates pinned, internal formatting rules without changing the country data.
///
/// Run with fvm dart run tool/dart/generate_phone_rules.dart.
/// --metadata accepts an offline XML copy; --check never writes the output.
Future<void> main(List<String> arguments) async {
  final options = _Options(arguments);
  if (options.help) {
    stdout.writeln(
      'Usage: dart run tool/dart/generate_phone_rules.dart '
      '[--metadata <XML>] [--output <Dart>] [--check] [--report <JSON>]',
    );
    return;
  }
  final root = File.fromUri(Platform.script).parent.parent.parent;
  final output = File(
    options.outputPath ??
        '${root.path}/lib/src/constant/country_phone_rules.g.dart',
  );
  _checkReportDestination(output, options.reportPath);
  final metadata = switch (options.metadataPath) {
    String path => await File(path).readAsBytes(),
    null => await _fetchMetadata(),
  };
  final digest = sha256.convert(metadata).toString();
  if (digest != _kMetadataSha256) {
    throw FormatException('Pinned XML checksum mismatch: $digest');
  }
  final generated = _generate(XmlDocument.parse(utf8.decode(metadata)));
  final temporary = await Directory.systemTemp.createTemp(
    'country-phone-rules-',
  );
  final List<int> result;
  try {
    final formatted = File('${temporary.path}/country_phone_rules.g.dart');
    await formatted.writeAsString(generated.source);
    final process = await Process.run(Platform.resolvedExecutable, <String>[
      'format',
      '--language-version',
      '3.10',
      '--line-length',
      '80',
      formatted.path,
    ]);
    if (process.exitCode != 0) {
      throw ProcessException(
        Platform.resolvedExecutable,
        const ['format'],
        '${process.stdout}\n${process.stderr}',
        process.exitCode,
      );
    }
    result = await formatted.readAsBytes();
  } finally {
    await temporary.delete(recursive: true);
  }
  if (options.check) {
    if (!output.existsSync() ||
        !_sameBytes(await output.readAsBytes(), result)) {
      stderr.writeln('Generated phone rules are stale: ${output.path}');
      exitCode = 1;
      return;
    }
    stdout.writeln('OK: ${output.path} matches pinned metadata');
  } else {
    await output.parent.create(recursive: true);
    await output.writeAsBytes(result);
    stdout.writeln('Wrote ${output.path} (${result.length} bytes)');
  }
  final report =
      '${const JsonEncoder.withIndent('  ').convert(generated.report)}\n';
  if (options.reportPath case String path) {
    // Recheck after normal generation creates a previously missing output.
    _checkReportDestination(output, path);
    await File(path).writeAsString(report);
  }
  stdout.write(report);
}

/// Keeps provenance output from overwriting rules, including filesystem aliases.
void _checkReportDestination(File output, String? reportPath) {
  if (reportPath == null) return;
  final report = File(reportPath);
  if (_destinationPath(output) == _destinationPath(report) ||
      (output.existsSync() &&
          report.existsSync() &&
          FileSystemEntity.identicalSync(output.path, report.path))) {
    throw ArgumentError.value(
      reportPath,
      '--report',
      'must be a different file from --output',
    );
  }
}

/// Resolves existing links and parent links without creating destination files.
String _destinationPath(File file) {
  final absolute = file.absolute;
  if (absolute.existsSync()) return absolute.resolveSymbolicLinksSync();
  final parent = absolute.parent;
  if (!parent.existsSync()) return absolute.uri.normalizePath().toFilePath();
  return '${parent.resolveSymbolicLinksSync()}${Platform.pathSeparator}'
      '${absolute.uri.normalizePath().pathSegments.last}';
}

/// Reads only the small set of supported generator arguments.
final class _Options {
  _Options(List<String> arguments) {
    for (var index = 0; index < arguments.length; index++) {
      final argument = arguments[index];
      switch (argument) {
        case '--check':
          check = true;
        case '--help' || '-h':
          help = true;
        case '--metadata' || '--output' || '--report':
          if (++index >= arguments.length) {
            throw FormatException('Missing value for $argument');
          }
          final value = arguments[index];
          switch (argument) {
            case '--metadata':
              metadataPath = value;
            case '--output':
              outputPath = value;
            case '--report':
              reportPath = value;
          }
        default:
          throw FormatException('Unknown argument: $argument');
      }
    }
  }

  /// Offline copy of the pinned XML; null selects the verified download.
  String? metadataPath;

  /// Optional destination instead of the bundled rules file.
  String? outputPath;

  /// Optional machine-readable provenance report destination.
  String? reportPath;

  /// Compares formatted bytes without replacing the destination.
  bool check = false;

  /// Prints usage without downloading or generating metadata.
  bool help = false;
}

/// Downloads the exact revision; its checksum is verified before XML parsing.
Future<List<int>> _fetchMetadata() async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 60);
  try {
    final request = await client.getUrl(Uri.parse(_kMetadataUrl));
    final response = await request.close().timeout(const Duration(seconds: 60));
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('Metadata download returned ${response.statusCode}');
    }
    return await response
        .fold<List<int>>(<int>[], (bytes, chunk) => bytes..addAll(chunk))
        .timeout(const Duration(seconds: 60));
  } finally {
    client.close(force: true);
  }
}

/// Compares formatted UTF-8 output without relying on modification times.
bool _sameBytes(List<int> left, List<int> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

/// Removes formatting whitespace from metadata patterns and examples.
String _removeWhitespace(String? value) =>
    (value ?? '').replaceAll(RegExp(r'\s+'), '');

/// Expands finite length ranges from the pinned metadata.
Set<int> _declaredLengths(String? value) {
  final result = <int>{};
  for (final item in (value ?? '').split(',')) {
    final text = item.trim();
    if (text.isEmpty) continue;
    if (text.startsWith('[')) {
      final range = text.substring(1, text.length - 1).split('-');
      final first = int.parse(range[0]);
      final last = int.parse(range[1]);
      for (var length = first; length <= last; length++) result.add(length);
    } else {
      result.add(int.parse(text));
    }
  }
  return result;
}

/// Computes exact lengths for the restricted regex grammar used by this pin.
///
/// Unknown operations and unbounded repetitions fail rather than approximate
/// new upstream rules. This replaces Python's private regular-expression AST.
final class _PatternLengths {
  _PatternLengths(this.pattern);

  /// Whitespace-free expression from the verified metadata revision.
  final String pattern;
  int _offset = 0;

  /// Requires the complete expression to belong to the supported grammar.
  Set<int> parse() {
    if (pattern.isEmpty) return <int>{};
    final result = _alternatives();
    if (_offset != pattern.length) _unsupported();
    return result;
  }

  /// Adds possible lengths of consecutive atoms, bounded by the old generator.
  Set<int> _combine(Set<int> left, Set<int> right) => <int>{
    for (final a in left)
      for (final b in right)
        if (a + b <= 32) a + b,
  };

  /// Unions each branch without losing lengths accepted by another branch.
  Set<int> _alternatives() {
    final result = _sequence();
    while (_consume('|')) result.addAll(_sequence());
    return result;
  }

  /// Resolves concatenation and finite greedy quantifiers.
  Set<int> _sequence() {
    var result = <int>{0};
    while (_offset < pattern.length &&
        pattern[_offset] != ')' &&
        pattern[_offset] != '|') {
      final atom = _atom();
      var low = 1;
      var high = 1;
      if (_consume('?')) {
        low = 0;
      } else if (_consume('{')) {
        low = _number();
        high = _consume(',') ? _number() : low;
        if (!_consume('}') || high < low || high > 32) _unsupported();
      } else if (_offset < pattern.length && '*+'.contains(pattern[_offset])) {
        _unsupported();
      }
      final local = <int>{};
      var repeated = <int>{0};
      for (var count = 0; count <= high; count++) {
        if (count >= low) local.addAll(repeated);
        repeated = _combine(repeated, atom);
      }
      result = _combine(result, local);
    }
    return result;
  }

  /// Recognizes literal digits, character classes, digit escapes and groups.
  Set<int> _atom() {
    final character = pattern[_offset++];
    if (character == '(') {
      if (_consume('?') && !_consume(':')) _unsupported();
      final result = _alternatives();
      if (!_consume(')')) _unsupported();
      return result;
    }
    if (character == '[') {
      var closed = false;
      while (_offset < pattern.length) {
        final next = pattern[_offset++];
        if (next == r'\') {
          if (_offset >= pattern.length) _unsupported();
          _offset++;
        } else if (next == ']') {
          closed = true;
          break;
        }
      }
      if (!closed) _unsupported();
      return <int>{1};
    }
    if (character == r'\') {
      if (!_consume('d')) _unsupported();
      return <int>{1};
    }
    if (RegExp('[0-9]').hasMatch(character)) return <int>{1};
    _unsupported();
  }

  /// Reads a bounded repetition count; open-ended counts are rejected.
  int _number() {
    final start = _offset;
    while (_offset < pattern.length &&
        RegExp('[0-9]').hasMatch(pattern[_offset]))
      _offset++;
    if (start == _offset) _unsupported();
    return int.parse(pattern.substring(start, _offset));
  }

  /// Advances only when the next token matches, preserving branch boundaries.
  bool _consume(String value) {
    if (!pattern.startsWith(value, _offset)) return false;
    _offset += value.length;
    return true;
  }

  /// Rejects upstream grammar changes that require a fresh metadata audit.
  Never _unsupported() => throw FormatException(
    'Unsupported regular expression at $_offset: $pattern',
  );
}

/// Resolves effective fixed/mobile lengths, including general-description limits.
List<int> _supportedNationalLengths(XmlElement territory) {
  final general = <int>{};
  for (final tag in _kTypeTags) {
    final description = territory.getElement(tag);
    if (description == null) continue;
    for (final node in description.findElements('possibleLengths')) {
      general.addAll(_declaredLengths(node.getAttribute('national')));
    }
  }
  general.remove(-1);
  final generalPattern = _removeWhitespace(
    territory
        .getElement('generalDesc')
        ?.getElement('nationalNumberPattern')
        ?.innerText,
  );
  final accepted = _PatternLengths(generalPattern).parse();
  final result = <int>{};
  for (final tag in const <String>['fixedLine', 'mobile']) {
    final description = territory.getElement(tag);
    if (description == null) continue;
    final lengths = description.getElement('possibleLengths');
    final declared = lengths == null
        ? general
        : _declaredLengths(lengths.getAttribute('national'));
    final ownPattern = _removeWhitespace(
      description.getElement('nationalNumberPattern')?.innerText,
    );
    final pattern = ownPattern.isEmpty ? generalPattern : ownPattern;
    final effective = declared
        .intersection(_PatternLengths(pattern).parse())
        .intersection(accepted);
    final example = _removeWhitespace(
      description.getElement('exampleNumber')?.innerText,
    );
    if (example.isNotEmpty &&
        (!effective.contains(example.length) ||
            !RegExp('^(?:$pattern)\$').hasMatch(example))) {
      throw FormatException(
        'Invalid ${territory.getAttribute('id')} $tag example',
      );
    }
    result.addAll(effective);
  }
  if (result.isEmpty)
    throw FormatException(
      'No fixed/mobile lengths for ${territory.getAttribute('id')}',
    );
  return result.toList()..sort();
}

/// Computes greedy capture lengths exactly, retaining upstream format order.
Map<int, List<int>> _captureWidthsByLength(String pattern, List<int> lengths) {
  final capture = RegExp(r'\(\\d(?:\{(\d+)(?:,(\d+))?\})?\)');
  final tokens = capture.allMatches(pattern).toList();
  if (tokens.map((match) => match.group(0) ?? '').join() != pattern) {
    throw FormatException('Unsupported formatting pattern: $pattern');
  }
  final options = <(int, int)>[
    for (final token in tokens)
      (
        int.parse(token.group(1) ?? '1'),
        int.parse(token.group(2) ?? token.group(1) ?? '1'),
      ),
  ];
  final result = <int, List<int>>{};
  final expression = RegExp('^(?:$pattern)\$');
  void visit(int index, List<int> groups) {
    if (index < options.length) {
      final (low, high) = options[index];
      for (var count = high; count >= low; count--)
        visit(index + 1, <int>[...groups, count]);
      return;
    }
    final size = groups.fold<int>(0, (sum, count) => sum + count);
    if (!lengths.contains(size) || result.containsKey(size)) return;
    final matched = expression.firstMatch('9' * size);
    if (matched == null || matched.groupCount != groups.length) {
      throw FormatException('Capture length mismatch: $pattern, $size');
    }
    for (var group = 0; group < groups.length; group++) {
      if (matched.group(group + 1)?.length != groups[group]) {
        throw FormatException('Capture length mismatch: $pattern, $size');
      }
    }
    result[size] = groups;
  }

  visit(0, <int>[]);
  return <int, List<int>>{
    for (final size in result.keys.toList()..sort())
      size: result[size] ?? const <int>[],
  };
}

/// Display captures and their exact greedy lengths in upstream order.
typedef _PhoneFormat = ({
  String leadingDigits,
  String pattern,
  String replacement,
  Map<int, List<int>> groupLengths,
});

/// One compatible bundled region before its Dart representation is rendered.
typedef _PhoneRules = ({
  String callingCode,
  String regionPrefix,
  String? nationalPrefixPattern,
  String? literalTrunkPrefix,
  List<int> possibleLengths,
  List<_PhoneFormat> formats,
});

/// Inherits missing display formats from the main country for a calling code.
List<_PhoneFormat> _formats(
  XmlElement territory,
  Iterable<XmlElement> territories,
  List<int> lengths,
) {
  var source = territory;
  var rules =
      source
          .getElement('availableFormats')
          ?.findElements('numberFormat')
          .toList() ??
      <XmlElement>[];
  if (rules.isEmpty) {
    for (final other in territories) {
      if (other.getAttribute('countryCode') ==
              territory.getAttribute('countryCode') &&
          other.getAttribute('mainCountryForCode') == 'true') {
        source = other;
        break;
      }
    }
    rules =
        source
            .getElement('availableFormats')
            ?.findElements('numberFormat')
            .toList() ??
        <XmlElement>[];
  }
  final output = <_PhoneFormat>[];
  for (final rule in rules) {
    final international = rule.getElement('intlFormat')?.innerText;
    if (international == 'NA') continue;
    final pattern = _attribute(rule, 'pattern');
    final groups = _captureWidthsByLength(pattern, lengths);
    if (groups.isEmpty) continue;
    final display = international ?? rule.getElement('format')?.innerText;
    if (display == null)
      throw FormatException('Missing format for ${source.getAttribute('id')}');
    final references = RegExp(
      r'\$\d+',
    ).allMatches(display).map((match) => match.group(0)).toList();
    final count = groups.values.first.length;
    if (references.length != count ||
        [for (var index = 1; index <= count; index++) '\$$index'].join() !=
            references.join()) {
      throw FormatException('Unsupported replacement: $display');
    }
    if (RegExp(r'\d').hasMatch(display.replaceAll(RegExp(r'\$\d+'), ''))) {
      throw FormatException('Literal digits in replacement: $display');
    }
    final leading = rule.findElements('leadingDigits').toList();
    output.add((
      leadingDigits: leading.isEmpty
          ? ''
          : _removeWhitespace(leading.last.innerText),
      pattern: pattern,
      replacement: display,
      groupLengths: groups,
    ));
  }
  return output;
}

/// Fails on malformed metadata instead of manufacturing a required attribute.
String _attribute(XmlElement element, String name) =>
    element.getAttribute(name) ??
    (throw FormatException('Missing $name on ${element.name}'));

/// Emits strip-only prefixes; digit-rewriting transforms remain excluded.
String? _nationalPrefixPattern(XmlElement territory) {
  if ((territory.getAttribute('nationalPrefixTransformRule') ?? '')
      .isNotEmpty) {
    return territory.getAttribute('nationalPrefix');
  }
  final expression = _removeWhitespace(
    territory.getAttribute('nationalPrefixForParsing'),
  );
  return expression.isEmpty
      ? territory.getAttribute('nationalPrefix')
      : expression;
}

/// Generates only compatible bundled regions and a reproducible provenance report.
({String source, Map<String, Object?> report}) _generate(XmlDocument document) {
  final territories = <String, XmlElement>{};
  for (final territory in document.findAllElements('territory')) {
    final id = _attribute(territory, 'id');
    if (id == '001') continue;
    if (territories.containsKey(id))
      throw FormatException('Duplicate geographic territory: $id');
    territories[id] = territory;
  }
  final rows = <String, _PhoneRules>{};
  final fallback = <String, String>{};
  final transforms = <String>[];
  for (final country in kCountries) {
    final (iso, bundled) = switch ((country['iso2_cc'], country['e164_cc'])) {
      (String iso, String code) => (iso, code),
      _ => throw const FormatException(
        'Country is missing its ISO/calling code',
      ),
    };
    final territory = territories[iso];
    if (territory == null) {
      fallback[iso] = 'no upstream territory';
      continue;
    }
    final code = _attribute(territory, 'countryCode');
    if (!bundled.startsWith(code)) {
      fallback[iso] = 'bundled +$bundled differs from upstream +$code';
      continue;
    }
    final lengths = _supportedNationalLengths(territory);
    final prefix = bundled.substring(code.length);
    for (final tag in const <String>['fixedLine', 'mobile']) {
      final example = _removeWhitespace(
        territory.getElement(tag)?.getElement('exampleNumber')?.innerText,
      );
      if (prefix.isNotEmpty &&
          example.isNotEmpty &&
          !example.startsWith(prefix)) {
        throw FormatException(
          'Embedded region prefix does not match $iso example',
        );
      }
    }
    final trunk = territory.getAttribute('nationalPrefix');
    rows[iso] = (
      callingCode: code,
      regionPrefix: prefix,
      nationalPrefixPattern: _nationalPrefixPattern(territory),
      literalTrunkPrefix: trunk != null && RegExp(r'^[0-9]+$').hasMatch(trunk)
          ? trunk
          : null,
      possibleLengths: lengths,
      formats: _formats(territory, territories.values, lengths),
    );
    if ((territory.getAttribute('nationalPrefixTransformRule') ?? '')
        .isNotEmpty)
      transforms.add(iso);
  }
  return (
    source: _render(rows),
    report: <String, Object?>{
      'source_commit': _kMetadataCommit,
      'xml_sha256': _kMetadataSha256,
      'bundled_countries': kCountries.length,
      'generated_countries': rows.length,
      'formats': rows.values.fold<int>(
        0,
        (count, row) => count + row.formats.length,
      ),
      'fallback': <String, String>{
        for (final key in fallback.keys.toList()..sort())
          key: fallback[key] ?? '',
      },
      'strip_only_prefix_transform_exclusions': transforms..sort(),
    },
  );
}

/// Escapes Dart literals while keeping regular expressions and replacements raw.
String _dartString(String? value) {
  if (value == null) return 'null';
  if (!value.contains("'") && (value.contains(r'\') || value.contains(r'$')))
    return "r'$value'";
  return "'${value.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll(r'$', r'\$')}'";
}

/// Renders a stable source order before the pinned Dart formatter is applied.
String _render(Map<String, _PhoneRules> rows) {
  final output = StringBuffer(_kHeader);
  for (final iso in rows.keys.toList()..sort()) {
    final row = rows[iso];
    if (row == null) throw StateError('Missing generated rules for $iso');
    output
      ..writeln("  '$iso': CountryPhoneRules(")
      ..writeln('    callingCode: ${_dartString(row.callingCode)},')
      ..writeln('    regionPrefix: ${_dartString(row.regionPrefix)},')
      ..writeln(
        '    nationalPrefixPattern: ${_dartString(row.nationalPrefixPattern)},',
      )
      ..writeln(
        '    literalTrunkPrefix: ${_dartString(row.literalTrunkPrefix)},',
      )
      ..writeln(
        '    possibleLengths: <int>[${row.possibleLengths.join(', ')}],',
      )
      ..writeln('    formats: <CountryPhoneFormat>[');
    for (final format in row.formats) {
      output
        ..writeln('      CountryPhoneFormat(')
        ..writeln(
          '        leadingDigits: ${_dartString(format.leadingDigits)},',
        )
        ..writeln('        pattern: ${_dartString(format.pattern)},')
        ..writeln('        replacement: ${_dartString(format.replacement)},')
        ..writeln('        groupLengths: <int, List<int>>{');
      for (final entry in format.groupLengths.entries) {
        output.writeln(
          '          ${entry.key}: <int>[${entry.value.join(', ')}],',
        );
      }
      output
        ..writeln('        },')
        ..writeln('      ),');
    }
    output
      ..writeln('    ],')
      ..writeln('  ),');
  }
  return (output..writeln('};')).toString();
}

const _kHeader = '''
// Generated by tool/dart/generate_phone_rules.dart. Do not edit by hand.
// Metadata: google/libphonenumber@8593ab70fa4fadffc042b2714034f4c52bef7daf
// XML SHA-256: b6491939ddaeb9d585a34fe0f0ebd096e83c5ac9a1c5d6dddf38ba4b162b28ca
// Source: https://github.com/google/libphonenumber/blob/8593ab70fa4fadffc042b2714034f4c52bef7daf/resources/PhoneNumberMetadata.xml
// Copyright (C) 2009 The Libphonenumber Authors. Apache-2.0.
// See assets/licenses/libphonenumber-LICENSE.txt and libphonenumber-NOTICE.md.

import 'package:meta/meta.dart';

/// Internal national-number formatting metadata for a bundled country.
@internal
@immutable
final class CountryPhoneRules {
  /// Creates one immutable set of national-number formatting rules.
  const CountryPhoneRules({
    required this.callingCode,
    required this.regionPrefix,
    required this.nationalPrefixPattern,
    required this.literalTrunkPrefix,
    required this.possibleLengths,
    required this.formats,
  });

  /// Actual international calling code, without a leading plus sign.
  final String callingCode;

  /// National destination prefix already included in the bundled phone code.
  ///
  /// For example, the Bahamas has calling code `1` and region prefix `242`.
  final String regionPrefix;

  /// Strip-only national trunk/carrier regexp, without an initial anchor.
  ///
  /// Apply only when the original number is unsupported and the remaining
  /// national number has a supported prefix and length. Transform rules that
  /// add or rewrite digits are intentionally excluded.
  final String? nationalPrefixPattern;

  /// Literal national trunk prefix for the legacy manual formatter.
  ///
  /// Only the source territory's numeric nationalPrefix is retained here;
  /// carrier regexes and transformations are never inferred as a literal.
  final String? literalTrunkPrefix;

  /// Supported fixed/mobile national lengths, including [regionPrefix].
  ///
  /// Excludes calling code, trunk prefix, local-only and short service lengths.
  /// Length alone does not establish number validity or SMS capability.
  final List<int> possibleLengths;

  /// International display formats in upstream order, without trunk prefixes.
  final List<CountryPhoneFormat> formats;
}

/// Internal prefix-dependent grouping of a complete national number.
@internal
@immutable
final class CountryPhoneFormat {
  /// Creates one immutable national-number display rule.
  const CountryPhoneFormat({
    required this.leadingDigits,
    required this.pattern,
    required this.replacement,
    required this.groupLengths,
  });

  /// Most specific upstream prefix regexp; an empty value matches any prefix.
  final String leadingDigits;

  /// Complete national-number regexp with ordered capture groups.
  final String pattern;

  /// International replacement containing ordered capture references.
  final String replacement;

  /// Greedy capture sizes by supported full national length.
  ///
  /// Keys and group sizes include [CountryPhoneRules.regionPrefix]. These are
  /// presentation groups; input beyond them must remain available as a tail.
  final Map<int, List<int>> groupLengths;
}

/// Pinned formatting rules for compatible entries of the bundled dataset.
///
/// HM/GS have no upstream territory; bundled VA's `379` conflicts with upstream
/// operational `39`. They intentionally use the caller's existing fallback.
/// Non-geographic `001` entries and territories absent from the bundle are not
/// added. Regions without formats inherit their calling code's main region.
@internal
const Map<String, CountryPhoneRules>
kCountryPhoneRules = <String, CountryPhoneRules>{
''';

import 'dart:convert';
import 'dart:io';

/// Generate `country_codes.json` from `country_codes.dart`.
/// Usage: fvm dart --disable-analytics run tool/generate_json.dart
void main(List<String> args) {
  final options = _Options.parse(args);

  final inputFile = File(options.inputPath);
  if (!inputFile.existsSync()) {
    stderr.writeln('Input not found: ${options.inputPath}');
    exitCode = 2;
    return;
  }

  final source = inputFile.readAsStringSync();
  final listLiteral = _extractCountriesListLiteral(source);
  final parser = _DartLiteralParser(listLiteral);

  final value = parser.parseValue();
  parser.expectEnd();

  if (value is! List<Object?>) {
    stderr.writeln('Parsed value is not a List.');
    exitCode = 3;
    return;
  }

  final encoder = options.minify
      ? const JsonEncoder()
      : const JsonEncoder.withIndent('  ');
  final jsonText = '${encoder.convert(value)}\n';

  if (options.validateOnly) {
    stdout.writeln('OK: parsed ${value.length} countries.');
    return;
  }

  final outputFile = File(options.outputPath);
  outputFile.parent.createSync(recursive: true);
  outputFile.writeAsStringSync(jsonText);

  stdout.writeln('Wrote ${options.outputPath} (${value.length} countries).');
}

String _extractCountriesListLiteral(String source) {
  final anchorIndex = source.indexOf('countries');
  if (anchorIndex == -1) {
    throw const FormatException('Could not find `countries` in source.');
  }

  final assignIndex = source.indexOf('=', anchorIndex);
  if (assignIndex == -1) {
    throw const FormatException('Could not find assignment for `countries`.');
  }

  final listStart = source.indexOf('[', assignIndex);
  if (listStart == -1) {
    throw const FormatException('Could not find list literal start `[`');
  }

  final scanner = _Scanner(source, startOffset: listStart);
  final literal = scanner.readBalancedBrackets(open: '[', close: ']');
  return literal;
}

final class _Options {
  const _Options({
    required this.inputPath,
    required this.outputPath,
    required this.minify,
    required this.validateOnly,
  });

  final String inputPath;
  final String outputPath;
  final bool minify;
  final bool validateOnly;

  // ignore: prefer_constructors_over_static_methods
  static _Options parse(List<String> args) {
    var inputPath = 'lib/src/constant/country_codes.dart';
    var outputPath = 'lib/src/constant/country_codes.json';
    var minify = false;
    var validateOnly = false;

    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      switch (arg) {
        case '-i':
        case '--input':
          if (i + 1 >= args.length) _usageAndExit('Missing value for $arg');
          inputPath = args[++i];
        case '-o':
        case '--output':
          if (i + 1 >= args.length) _usageAndExit('Missing value for $arg');
          outputPath = args[++i];
        case '--minify':
          minify = true;
        case '--validate-only':
          validateOnly = true;
        case '-h':
        case '--help':
          _usageAndExit(null, exitCode: 0);
        default:
          _usageAndExit('Unknown argument: $arg');
      }
    }

    return _Options(
      inputPath: inputPath,
      outputPath: outputPath,
      minify: minify,
      validateOnly: validateOnly,
    );
  }

  static Never _usageAndExit(String? error, {int exitCode = 64}) {
    if (error != null) {
      stderr
        ..writeln(error)
        ..writeln('');
    }

    stderr
      ..writeln('Usage:')
      ..writeln(
        '  dart run tool/generate_country_codes_json.dart '
        '[--input <path>] [--output <path>] [--minify] [--validate-only]',
      )
      ..writeln('')
      ..writeln('Defaults:')
      ..writeln('  --input  lib/src/constant/country_codes.dart')
      ..writeln('  --output lib/src/constant/country_codes.json');

    exit(exitCode);
  }
}

final class _Scanner {
  _Scanner(this._source, {required int startOffset}) : _i = startOffset;

  final String _source;
  int _i;

  String readBalancedBrackets({required String open, required String close}) {
    var depth = 0;
    final start = _i;

    var inSingle = false;
    var inDouble = false;
    var isEscaped = false;
    var inLineComment = false;
    var inBlockComment = false;

    while (_i < _source.length) {
      final c = _source[_i];
      final next = _i + 1 < _source.length ? _source[_i + 1] : '';

      if (inLineComment) {
        if (c == '\n') inLineComment = false;
        _i++;
        continue;
      }

      if (inBlockComment) {
        if (c == '*' && next == '/') {
          inBlockComment = false;
          _i += 2;
          continue;
        }
        _i++;
        continue;
      }

      if (!inSingle && !inDouble && c == '/' && next == '/') {
        inLineComment = true;
        _i += 2;
        continue;
      }

      if (!inSingle && !inDouble && c == '/' && next == '*') {
        inBlockComment = true;
        _i += 2;
        continue;
      }

      if (isEscaped) {
        isEscaped = false;
        _i++;
        continue;
      }

      if (inSingle) {
        if (c == r'\\') {
          isEscaped = true;
        } else if (c == "'") {
          inSingle = false;
        }
        _i++;
        continue;
      }

      if (inDouble) {
        if (c == r'\\') {
          isEscaped = true;
        } else if (c == '"') {
          inDouble = false;
        }
        _i++;
        continue;
      }

      if (c == "'") {
        inSingle = true;
        _i++;
        continue;
      }

      if (c == '"') {
        inDouble = true;
        _i++;
        continue;
      }

      if (c == open) {
        depth++;
      } else if (c == close) {
        depth--;
        if (depth == 0) {
          _i++;
          return _source.substring(start, _i);
        }
      }

      _i++;
    }

    throw FormatException('Unterminated bracketed literal starting at $start');
  }
}

final class _DartLiteralParser {
  _DartLiteralParser(this._text);

  final String _text;
  int _i = 0;

  Object? parseValue() {
    _skipWhitespaceAndComments();
    if (_i >= _text.length) {
      throw const FormatException('Unexpected end of input.');
    }

    final c = _text[_i];
    return switch (c) {
      '[' => _parseList(),
      '{' => _parseMap(),
      '\'' || '"' => _parseString(),
      '-' ||
      '0' ||
      '1' ||
      '2' ||
      '3' ||
      '4' ||
      '5' ||
      '6' ||
      '7' ||
      '8' ||
      '9' => _parseNumber(),
      _ => _parseIdentifierLike(),
    };
  }

  void expectEnd() {
    _skipWhitespaceAndComments();
    if (_i != _text.length) {
      throw FormatException('Unexpected trailing content at offset $_i');
    }
  }

  List<Object?> _parseList() {
    _expect('[');
    final result = <Object?>[];

    while (true) {
      _skipWhitespaceAndComments();
      if (_tryConsume(']')) break;

      final value = parseValue();
      result.add(value);

      _skipWhitespaceAndComments();
      if (_tryConsume(',')) {
        continue;
      }
      if (_tryConsume(']')) break;

      throw FormatException('Expected , or ] at offset $_i');
    }

    return result;
  }

  Map<String, Object?> _parseMap() {
    _expect('{');
    final result = <String, Object?>{};

    while (true) {
      _skipWhitespaceAndComments();
      if (_tryConsume('}')) break;

      final key = _parseMapKey();
      _skipWhitespaceAndComments();
      _expect(':');

      final value = parseValue();
      result[key] = value;

      _skipWhitespaceAndComments();
      if (_tryConsume(',')) {
        continue;
      }
      if (_tryConsume('}')) break;

      throw FormatException('Expected , or } at offset $_i');
    }

    return result;
  }

  String _parseMapKey() {
    _skipWhitespaceAndComments();
    final key = _parseString();
    return key;
  }

  String _parseString() {
    final quote = _text[_i];
    if (quote != '\'' && quote != '"') {
      throw FormatException('Expected string at offset $_i');
    }
    _i++;

    final buffer = StringBuffer();
    while (_i < _text.length) {
      final c = _text[_i++];
      if (c == quote) return buffer.toString();

      if (c != r'\\') {
        buffer.write(c);
        continue;
      }

      if (_i >= _text.length) {
        throw FormatException('Unterminated escape at offset $_i');
      }

      final esc = _text[_i++];
      switch (esc) {
        case 'n':
          buffer.write('\n');
        case 'r':
          buffer.write('\r');
        case 't':
          buffer.write('\t');
        case 'b':
          buffer.write('\b');
        case 'f':
          buffer.write('\f');
        case "'":
          buffer.write("'");
        case '"':
          buffer.write('"');
        case r'\\':
          buffer.write(r'\\');
        case 'u':
          buffer.write(_parseUnicodeEscape());
        case 'x':
          buffer.write(_parseHexEscape());
        default:
          buffer.write(esc);
      }
    }

    throw const FormatException('Unterminated string literal.');
  }

  String _parseUnicodeEscape() {
    if (_i < _text.length && _text[_i] == '{') {
      _i++;
      final start = _i;
      while (_i < _text.length && _text[_i] != '}') _i++;
      if (_i >= _text.length) {
        throw FormatException('Invalid unicode escape at offset $_i');
      }
      final hex = _text.substring(start, _i);
      _i++;
      final codePoint = int.parse(hex, radix: 16);
      return String.fromCharCode(codePoint);
    }

    if (_i + 4 > _text.length) {
      throw FormatException('Invalid unicode escape at offset $_i');
    }
    final hex = _text.substring(_i, _i + 4);
    _i += 4;
    final value = int.parse(hex, radix: 16);
    return String.fromCharCode(value);
  }

  String _parseHexEscape() {
    if (_i + 2 > _text.length) {
      throw FormatException('Invalid hex escape at offset $_i');
    }
    final hex = _text.substring(_i, _i + 2);
    _i += 2;
    final value = int.parse(hex, radix: 16);
    return String.fromCharCode(value);
  }

  num _parseNumber() {
    final start = _i;
    if (_text[_i] == '-') _i++;

    while (_i < _text.length && _isDigit(_text[_i])) _i++;

    if (_i < _text.length && _text[_i] == '.') {
      _i++;
      while (_i < _text.length && _isDigit(_text[_i])) _i++;
    }

    final raw = _text.substring(start, _i);
    return num.parse(raw);
  }

  Object? _parseIdentifierLike() {
    final start = _i;
    while (_i < _text.length && _isIdentChar(_text[_i])) _i++;
    if (start == _i) throw FormatException('Unexpected token at offset $_i');

    final ident = _text.substring(start, _i);
    return switch (ident) {
      'true' => true,
      'false' => false,
      'null' => null,
      _ => throw FormatException('Unsupported identifier `$ident`'),
    };
  }

  void _skipWhitespaceAndComments() {
    while (_i < _text.length) {
      final c = _text[_i];

      if (_isWhitespace(c)) {
        _i++;
        continue;
      }

      if (_i + 1 < _text.length && c == '/' && _text[_i + 1] == '/') {
        _i += 2;
        while (_i < _text.length && _text[_i] != '\n') _i++;
        continue;
      }

      if (_i + 1 < _text.length && c == '/' && _text[_i + 1] == '*') {
        _i += 2;
        while (_i + 1 < _text.length) {
          if (_text[_i] == '*' && _text[_i + 1] == '/') {
            _i += 2;
            break;
          }
          _i++;
        }
        continue;
      }

      break;
    }
  }

  void _expect(String ch) {
    _skipWhitespaceAndComments();
    if (_i >= _text.length || _text[_i] != ch) {
      throw FormatException('Expected `$ch` at offset $_i');
    }
    _i++;
  }

  bool _tryConsume(String ch) {
    _skipWhitespaceAndComments();
    if (_i < _text.length && _text[_i] == ch) {
      _i++;
      return true;
    }
    return false;
  }

  static bool _isWhitespace(String c) =>
      c == ' ' || c == '\n' || c == '\r' || c == '\t';

  static bool _isDigit(String c) => c.codeUnitAt(0) ^ 0x30 <= 9;

  static bool _isIdentChar(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 0x30 && code <= 0x39) ||
        (code >= 0x41 && code <= 0x5A) ||
        (code >= 0x61 && code <= 0x7A) ||
        c == '_';
  }
}

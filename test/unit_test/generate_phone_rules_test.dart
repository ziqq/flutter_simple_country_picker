import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('phone rules generator', () {
    const rules = 'lib/src/constant/country_phone_rules.g.dart';
    late Directory temporary;
    late String dart;
    late File metadata;

    setUpAll(() async {
      dart = _dartExecutable();
      temporary = await Directory.systemTemp.createTemp('phone-rules-test-');
      addTearDown(() => temporary.delete(recursive: true));
      final compressed = await File(
        'test/fixtures/libphonenumber-metadata.xml.gz',
      ).readAsBytes();
      metadata = await File.fromUri(
        temporary.uri.resolve('PhoneNumberMetadata.xml'),
      ).writeAsBytes(gzip.decode(compressed));
    });

    Future<ProcessResult> runGenerator(List<String> arguments) =>
        Process.run(dart, [
          '--packages=.dart_tool/package_config.json',
          'tool/generate_phone_rules.dart',
          '--metadata',
          metadata.path,
          ...arguments,
        ]);

    test('default output matches the pinned metadata', () async {
      final result = await runGenerator(['--check']);

      expect(result.exitCode, 0, reason: result.stderr.toString());
      expect(result.stdout, contains('country_phone_rules.g.dart matches'));
    });

    test('writes deterministic rules and provenance', () async {
      final output = File.fromUri(temporary.uri.resolve('generated.g.dart'));
      final report = File.fromUri(temporary.uri.resolve('provenance.json'));
      final result = await runGenerator([
        '--output',
        output.path,
        '--report',
        report.path,
      ]);

      expect(result.exitCode, 0, reason: result.stderr.toString());
      expect(await output.readAsBytes(), await File(rules).readAsBytes());
      final provenance = jsonDecode(await report.readAsString());
      expect(provenance, containsPair('generated_countries', 238));
      expect(
        provenance,
        containsPair(
          'source_commit',
          '8593ab70fa4fadffc042b2714034f4c52bef7daf',
        ),
      );
    });

    test(
      'check rejects stale rules without replacing the destination',
      () async {
        final output = File.fromUri(temporary.uri.resolve('stale.g.dart'));
        const stale = '// stale\n';
        await output.writeAsString(stale);

        final result = await runGenerator(['--check', '--output', output.path]);

        expect(result.exitCode, 1);
        expect(result.stderr, contains('Generated phone rules are stale'));
        expect(await output.readAsString(), stale);
      },
    );

    test('rejects unpinned metadata before writing any rules', () async {
      final other = File.fromUri(temporary.uri.resolve('other.xml'));
      final output = File.fromUri(temporary.uri.resolve('rejected.g.dart'));
      await other.writeAsString('<phoneNumberMetadata/>');

      final result = await runGenerator([
        '--metadata',
        other.path,
        '--output',
        output.path,
      ]);

      expect(result.exitCode, isNonZero);
      expect(result.stderr, contains('Pinned XML checksum mismatch'));
      expect(output.existsSync(), isFalse);
    });
  });
}

/// Finds the Dart CLI next to the Flutter SDK used by the test runner.
String _dartExecutable() {
  final config = File('.dart_tool/package_config.json').absolute;
  final Object? contents = jsonDecode(config.readAsStringSync());
  if (contents case {'packages': List<Object?> packages}) {
    for (final package in packages) {
      if (package case {'name': 'flutter', 'rootUri': String root}) {
        final sdk = Directory.fromUri(config.uri.resolve(root)).parent.parent;
        final name = Platform.isWindows ? 'dart.exe' : 'dart';
        return sdk.uri.resolve('bin/cache/dart-sdk/bin/$name').toFilePath();
      }
    }
  }
  throw StateError('Flutter SDK not found in ${config.path}');
}

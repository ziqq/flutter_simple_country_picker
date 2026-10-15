import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  writeResponseOnFailure: true,
  responseDataCallback: (data) async {
    final directory = Directory(
      Platform.environment['COUNTRY_PICKER_SCREENSHOTS'] ??
          'build/platform-screenshots',
    );
    await directory.create(recursive: true);
    final captures = (data?.remove('captures') as Map<String, dynamic>?) ?? {};
    data?['capture_host_os'] = Platform.operatingSystemVersion;
    data?['capture_host_runtime'] = Platform.version;
    for (final entry in captures.entries) {
      await File(
        '${directory.path}/${entry.key}.png',
      ).writeAsBytes(base64Decode(entry.value as String));
    }
    await File(
      '${directory.path}/manifest.json',
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(data));
  },
);

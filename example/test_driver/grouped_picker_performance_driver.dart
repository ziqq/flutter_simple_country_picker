import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    final output = File(
      Platform.environment['COUNTRY_PICKER_BENCH_OUTPUT'] ??
          'build/grouped-picker-performance.json',
    );
    await output.parent.create(recursive: true);
    await output.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );
  },
);

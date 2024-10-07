import 'package:flutter_test/flutter_test.dart';

import 'unit_test/flutter_simple_country_picker_test.dart' as unit_test;
import 'widget_test/flutter_simple_country_picker_test.dart' as widget_test;

void main() {
  group('flutter_simple_country_picker -', () {
    group('unit_test -', unit_test.main);
    group('widget_test -', widget_test.main);
  });
}

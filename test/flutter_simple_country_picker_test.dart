import 'package:flutter_test/flutter_test.dart';

import 'unit_test/countries_controller_test.dart'
    as unit_countries_controller_test;
import 'unit_test/countries_parser_test.dart' as unit_countries_parser_test;
import 'unit_test/countries_provider_test.dart' as unit_country_provider_test;
import 'unit_test/countries_state_test.dart' as unit_countries_state_test;
import 'widget_test/countries_parser_test.dart' as widget_countries_parser_test;

void main() {
  group('flutter_simple_country_picker -', () {
    group('unit_test -', () {
      unit_countries_controller_test.main();
      unit_countries_parser_test.main();
      unit_country_provider_test.main();
      unit_countries_state_test.main();
    });
    group('widget_test -', widget_countries_parser_test.main);
  });
}

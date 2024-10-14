import 'package:flutter_test/flutter_test.dart';

import 'unit_test/countries_controller_test.dart'
    as unit_countries_controller_test;
import 'unit_test/countries_parser_test.dart' as unit_countries_parser_test;
import 'unit_test/countries_provider_test.dart' as unit_country_provider_test;
import 'unit_test/countries_state_test.dart' as unit_countries_state_test;
import 'unit_test/countries_util_test.dart' as unit_countries_util_test;
import 'unit_test/country_input_formater_test.dart'
    as unit_country_input_formater_test;
import 'widget_test/countries_parser_test.dart' as widget_countries_parser_test;
import 'widget_test/countries_scope_test.dart' as widget_countries_scope_test;
import 'widget_test/country_input_formater_test.dart'
    as widget_country_input_formater_test;

void main() {
  group('flutter_simple_country_picker -', () {
    group('unit_test -', () {
      unit_country_input_formater_test.main();
      unit_countries_controller_test.main();
      unit_countries_parser_test.main();
      unit_country_provider_test.main();
      unit_countries_state_test.main();
      unit_countries_util_test.main();
    });
    group('widget_test -', () {
      widget_country_input_formater_test.main();
      widget_countries_parser_test.main();
      widget_countries_scope_test.main();
    });
  });
}

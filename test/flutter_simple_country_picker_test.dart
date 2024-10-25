import 'package:flutter_test/flutter_test.dart';

import 'unit_test/countries_controller_test.dart'
    as unit_countries_controller_test;
import 'unit_test/countries_parser_test.dart' as unit_countries_parser_test;
import 'unit_test/countries_provider_test.dart' as unit_country_provider_test;
import 'unit_test/countries_state_test.dart' as unit_countries_state_test;
import 'unit_test/countries_util_test.dart' as unit_countries_util_test;
import 'unit_test/country_codes_test.dart' as unit_country_codes_test;
import 'unit_test/country_input_formater_test.dart'
    as unit_country_input_formater_test;
import 'unit_test/country_picker_theme_test.dart'
    as unit_country_picker_theme_test;
import 'unit_test/country_test.dart' as unit_country_test;
import 'widget_test/countries_parser_test.dart' as widget_countries_parser_test;
import 'widget_test/countries_scope_test.dart' as widget_countries_scope_test;
import 'widget_test/country_input_formater_test.dart'
    as widget_country_input_formater_test;
import 'widget_test/country_phone_input_test.dart'
    as widget_country_phone_input_test;
import 'widget_test/country_picker_theme_test.dart'
    as widget_country_picker_theme_test;
import 'widget_test/country_test.dart' as widget_country_test;
import 'widget_test/show_country_picker_test.dart'
    as widget_show_country_picker_test;
import 'widget_test/status_bar_gesture_detector_test.dart'
    as widget_status_bar_gesture_detector_test;

void main() {
  group('flutter_simple_country_picker -', () {
    group('unit_test -', () {
      unit_country_input_formater_test.main();
      unit_countries_controller_test.main();
      unit_countries_parser_test.main();
      unit_country_provider_test.main();
      unit_countries_state_test.main();
      unit_countries_util_test.main();
      unit_country_codes_test.main();
      unit_country_test.main();
      unit_country_picker_theme_test.main();
    });
    group('widget_test -', () {
      widget_country_input_formater_test.main();
      widget_country_phone_input_test.main();
      widget_countries_parser_test.main();
      widget_countries_scope_test.main();
      widget_country_test.main();
      widget_country_picker_theme_test.main();
      widget_show_country_picker_test.main();
      widget_status_bar_gesture_detector_test.main();
    });
  });
}

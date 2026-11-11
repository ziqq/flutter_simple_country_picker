/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 7 October 2024
 */

import 'package:flutter_test/flutter_test.dart';

import 'unit_test/country_automatic_formatter_test.dart'
    as unit_country_automatic_formatter_test;
import 'unit_test/country_codes_test.dart' as unit_country_codes_test;
import 'unit_test/country_controller_test.dart' as unit_country_controller_test;
import 'unit_test/country_flag_font_util_test.dart'
    as unit_country_flag_font_util_test;
import 'unit_test/country_input_formater_test.dart'
    as unit_country_input_formater_test;
import 'unit_test/country_localizations_test.dart'
    as unit_country_localizations_test;
import 'unit_test/country_parser_test.dart' as unit_country_parser_test;
import 'unit_test/country_phone_controller_test.dart'
    as unit_country_phone_controller_test;
import 'unit_test/country_phone_format_resolver_test.dart'
    as unit_country_phone_format_resolver_test;
import 'unit_test/country_picker_theme_test.dart'
    as unit_country_picker_theme_test;
import 'unit_test/country_provider_test.dart' as unit_country_provider_test;
import 'unit_test/country_test.dart' as unit_country_test;
import 'unit_test/country_util_test.dart' as unit_country_util_test;
import 'unit_test/generate_phone_rules_test.dart' as generate_phone_rules_test;
import 'widget_test/country_accessibility_test.dart'
    as widget_country_accessibility_test;
import 'widget_test/country_automatic_phone_input_test.dart'
    as widget_country_automatic_phone_input_test;
import 'widget_test/country_flag_cache_test.dart'
    as widget_country_flag_cache_test;
import 'widget_test/country_input_formater_test.dart'
    as widget_country_input_formater_test;
import 'widget_test/country_list_view_test.dart'
    as widget_country_list_view_test;
import 'widget_test/country_localizations_test.dart'
    as widget_country_localizations_test;
import 'widget_test/country_parser_test.dart' as widget_countries_parser_test;
import 'widget_test/country_phone_input_test.dart'
    as widget_country_phone_input_test;
import 'widget_test/country_picker_theme_test.dart'
    as widget_country_picker_theme_test;
import 'widget_test/country_scope_test.dart' as widget_countries_scope_test;
import 'widget_test/country_test.dart' as widget_country_test;
import 'widget_test/show_country_picker_test.dart'
    as widget_show_country_picker_test;

void main() {
  group('flutter_simple_country_picker -', () {
    group('unit_test -', () {
      unit_country_automatic_formatter_test.main();
      unit_country_codes_test.main();
      unit_country_controller_test.main();
      unit_country_flag_font_util_test.main();
      unit_country_input_formater_test.main();
      unit_country_localizations_test.main();
      unit_country_parser_test.main();
      unit_country_phone_controller_test.main();
      unit_country_phone_format_resolver_test.main();
      unit_country_picker_theme_test.main();
      unit_country_provider_test.main();
      unit_country_test.main();
      unit_country_util_test.main();
      generate_phone_rules_test.main();
    });
    group('widget_test -', () {
      widget_country_accessibility_test.main();
      widget_country_automatic_phone_input_test.main();
      widget_country_flag_cache_test.main();
      widget_country_input_formater_test.main();
      widget_country_list_view_test.main();
      widget_country_localizations_test.main();
      widget_countries_parser_test.main();
      widget_country_phone_input_test.main();
      widget_country_picker_theme_test.main();
      widget_countries_scope_test.main();
      widget_country_test.main();
      widget_show_country_picker_test.main();
    });
  });
}

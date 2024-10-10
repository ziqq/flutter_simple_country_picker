import 'package:flutter_test/flutter_test.dart';

import 'countries_controller_test.dart' as countries_controller_test;
import 'countries_parser_test.dart' as countries_parser_test;
import 'countries_provider_test.dart' as country_provider_test;
import 'countries_state_test.dart' as countries_state_test;

void main() {
  group('Example_first_unit_test -', () {
    countries_controller_test.main();
    countries_parser_test.main();
    country_provider_test.main();
    countries_state_test.main();
  });
}

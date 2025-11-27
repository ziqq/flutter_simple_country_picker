import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/widget/country_list_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/widget_test_helper.dart';

void main() => group('showCountryPicker -', () {
  testWidgets('displays bottom sheet with country list view', (tester) async {
    await tester.pumpWidget(
      WidgetTestHelper.createWidgetUnderTest(
        builder: (context) => Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showCountryPicker(context: context, onSelect: (_) {});
              },
              child: const Text('Show Picker'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Picker'));
    await tester.pumpAndSettle();

    // Проверяем, что виджет BottomSheet с country list отображен
    expect(find.byType(CountryListView), findsOneWidget);
  });

  testWidgets('calls onSelect callback when country is selected', (
    tester,
  ) async {
    Country? selectedCountry;

    await tester.pumpWidget(
      WidgetTestHelper.createWidgetUnderTest(
        builder: (context) => Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showCountryPicker(
                  context: context,
                  onSelect: (country) => selectedCountry = country,
                );
              },
              child: const Text('Show Picker'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Picker'));
    await tester.pumpAndSettle();

    // Симулируем выбор страны
    final listView = tester.widget<CountryListView>(
      find.byType(CountryListView),
    );
    listView.onSelect!(Country.ru());

    await tester.pumpAndSettle();
    expect(selectedCountry, isNotNull);
  });

  testWidgets('applies theme correctly', (tester) async {
    final themeData = CountryPickerTheme(
      accentColor: CupertinoColors.systemBlue,
      backgroundColor: Colors.white,
      barrierColor: Colors.black54,
      dividerColor: Colors.grey,
      secondaryBackgroundColor: Colors.blueAccent,
      textStyle: const TextStyle(fontSize: 16),
      searchTextStyle: const TextStyle(fontSize: 14),
      flagSize: 25,
      padding: 10,
      indent: 10,
      radius: 15,
      inputDecoration: const InputDecoration(),
    );

    await tester.pumpWidget(
      WidgetTestHelper.createWidgetUnderTest(
        builder: (context) => Scaffold(
          body: InheritedCountryPickerTheme(
            data: themeData,
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showCountryPicker(context: context, onSelect: (_) {});
                },
                child: const Text('Show Picker'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Picker'));
    await tester.pumpAndSettle();

    final modalSheet = tester.widget<ClipRRect>(find.byType(ClipRRect));
    expect(
      modalSheet.borderRadius,
      const BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      ),
    );
  });

  testWidgets('shows search bar when showSearch is true', (tester) async {
    await tester.pumpWidget(
      WidgetTestHelper.createWidgetUnderTest(
        builder: (context) => Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showCountryPicker(
                  context: context,
                  onSelect: (_) {},
                  showSearch: true,
                );
              },
              child: const Text('Show Picker'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Picker'));
    await tester.pumpAndSettle();

    // Expect search bar to be displayed
    expect(find.byType(CupertinoSearchTextField), findsOneWidget);
  });

  testWidgets('calls onDone callback when picker is dismissed', (tester) async {
    var onDoneCalled = false;

    await tester.pumpWidget(
      WidgetTestHelper.createWidgetUnderTest(
        builder: (context) => Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showCountryPicker(
                  context: context,
                  onSelect: (_) {},
                  onDone: () => onDoneCalled = true,
                );
              },
              child: const Text('Show Picker'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Picker'));
    await tester.pumpAndSettle();

    // Dismiss the picker
    Navigator.of(tester.element(find.text('Show Picker'))).pop();
    await tester.pumpAndSettle();

    expect(onDoneCalled, isTrue);
  });

  testWidgets('applies haptic feedback on show', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    var hapticFeedbackTriggered = false;

    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (methodCall) async {
        if (methodCall.method == 'HapticFeedback.vibrate') {
          hapticFeedbackTriggered = true;
        }
        return null;
      },
    );

    await tester.pumpWidget(
      WidgetTestHelper.createWidgetUnderTest(
        builder: (context) => Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showCountryPicker(
                  context: context,
                  onSelect: (_) {},
                  useHaptickFeedback: true,
                );
              },
              child: const Text('Show Picker'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Picker'));
    await tester.pumpAndSettle();

    // Check if haptic feedback was triggered
    expect(hapticFeedbackTriggered, isTrue);

    // Reset mock handler
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
  });
});

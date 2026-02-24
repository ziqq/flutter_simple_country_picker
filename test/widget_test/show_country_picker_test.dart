import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/widget/country_list_view.dart';
import 'package:flutter_simple_country_picker/src/widget/show_country_picker.dart'
    show CountryPickerOptions;
import 'package:flutter_test/flutter_test.dart';

import '../util/test_util.dart';

void main() => group('showCountryPicker -', () {
  testWidgets('displays bottom sheet with country list view', (tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
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
    await tester.pumpAndSettle();

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
      createWidgetUnderTest(
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
    await tester.pumpAndSettle();

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
      secondaryBackgroundColor: Colors.blueAccent,
      barrierColor: Colors.black54,
      dividerColor: Colors.grey,
      textStyle: const TextStyle(fontSize: 16),
      searchTextStyle: const TextStyle(fontSize: 14),
      inputHeight: 70,
      flagSize: 25,
      padding: 10,
      indent: 10,
      radius: 15,
      inputDecoration: const InputDecoration(),
    );

    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (context) => InheritedCountryPickerTheme(
          data: themeData,
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
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
    await tester.pumpAndSettle();

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
      createWidgetUnderTest(
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
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show Picker'));
    await tester.pumpAndSettle();

    // Expect search bar to be displayed
    expect(find.byType(CupertinoSearchTextField), findsOneWidget);
  });

  testWidgets('calls onDone callback when picker is dismissed', (tester) async {
    var onDoneCalled = false;

    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (context) => Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showCountryPicker(
                  context: context,
                  onSelect: (_) {},
                  whenComplete: () => onDoneCalled = true,
                );
              },
              child: const Text('Show Picker'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

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
      createWidgetUnderTest(
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
    await tester.pumpAndSettle();

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

  // ignore: deprecated_member_use
  testWidgets(
    'onDone (deprecated) callback is called when picker is dismissed',
    (tester) async {
      var onDoneCalled = false;

      await tester.pumpWidget(
        createWidgetUnderTest(
          builder: (context) => Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showCountryPicker(
                    context: context,
                    onSelect: (_) {},
                    // ignore: deprecated_member_use
                    onDone: () => onDoneCalled = true,
                    // whenComplete is intentionally null so onDone is used.
                  );
                },
                child: const Text('Show Picker'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();

      Navigator.of(tester.element(find.text('Show Picker'))).pop();
      await tester.pumpAndSettle();

      expect(onDoneCalled, isTrue);
    },
  );

  test('CountryPickerOptions constructs with default values', () {
    const options = CountryPickerOptions(onSelect: null);

    expect(options.expand, isFalse);
    expect(options.adaptive, isFalse);
    expect(options.autofocus, isFalse);
    expect(options.isDismissible, isTrue);
    expect(options.isScrollControlled, isTrue);
    expect(options.showPhoneCode, isFalse);
    expect(options.showWorldWide, isFalse);
    expect(options.useHaptickFeedback, isTrue);
    expect(options.useRootNavigator, isFalse);
    expect(options.useSafeArea, isTrue);
    expect(options.exclude, isNull);
    expect(options.filter, isNull);
    expect(options.favorites, isNull);
    expect(options.whenComplete, isNull);
  });

  test('CountryPickerOptions accepts all optional fields', () {
    final options = CountryPickerOptions(
      exclude: const ['RU'],
      favorites: const ['US'],
      filter: const ['GB'],
      onSelect: (_) {},
      whenComplete: () {},
      expand: true,
      showPhoneCode: true,
      showWorldWide: true,
      showGroup: true,
      showSearch: false,
      isDismissible: false,
      initialChildSize: 0.8,
      minChildSize: 0.4,
    );

    expect(options.exclude, contains('RU'));
    expect(options.favorites, contains('US'));
    expect(options.filter, contains('GB'));
    expect(options.expand, isTrue);
    expect(options.showPhoneCode, isTrue);
    expect(options.showWorldWide, isTrue);
    expect(options.showGroup, isTrue);
    expect(options.showSearch, isFalse);
    expect(options.isDismissible, isFalse);
    expect(options.initialChildSize, 0.8);
    expect(options.minChildSize, 0.4);
  });
});

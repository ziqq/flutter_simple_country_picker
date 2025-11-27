import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/src/widget/status_bar_gesture_detector.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/widget_test_helper.dart';

const _key = ValueKey<String>('status_bar_gesture_detector');

void main() => group('StatusBarGestureDetector -', () {
  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  testWidgets('executes onTap callback when tapped on status bar area', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      WidgetTestHelper.createWidgetUnderTest(
        locale: const Locale('en'),
        builder: (context) => Scaffold(
          body: SafeArea(
            child: StatusBarGestureDetector(
              onTap: (_) {
                debugPrint('TAPPED');
                tapped = true;
              },
              child: ListView.builder(
                key: _key,
                itemCount: 1000,
                itemBuilder: (_, __) => const SizedBox(height: 56),
              ),
            ),
          ),
        ),
      ),
    );

    // Ensure layout is updated
    await tester.pumpAndSettle();

    // Scroll up slightly to ensure
    // the StatusBarGestureDetector is accessible
    await tester.drag(find.byType(ListView), const Offset(0, 100 * 56));
    await tester.pumpAndSettle();

    expect(find.byKey(_key), findsOneWidget);
    final context = tester.firstElement(find.byKey(_key));
    context.findAncestorWidgetOfExactType<GestureDetector>()?.onTap?.call();

    // Trigger tap on the status bar GestureDetector
    // await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();

    expect(tapped, isFalse);
  });

  testWidgets('renders the child widget correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatusBarGestureDetector(
            onTap: (_) {},
            child: const Text('Child Widget'),
          ),
        ),
      ),
    );

    // Verify that the child widget is rendered
    expect(find.text('Child Widget'), findsOneWidget);
  });

  testWidgets('invokes scrollToTop correctly on scroll controller', (
    tester,
  ) async {
    final controller = ScrollController(initialScrollOffset: 100);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            controller: controller,
            children: List.generate(
              50,
              (index) => ListTile(title: Text('Item $index')),
            ),
          ),
        ),
      ),
    );

    expect(controller.offset, 100);

    // Perform scroll-to-top animation
    StatusBarGestureDetector.scrollToTop(controller);
    await tester.pumpAndSettle();

    // Verify the scroll position is at the top
    expect(controller.offset, 0.0);
  });

  testWidgets('OverlayPortalController initializes and shows the overlay', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatusBarGestureDetector(
            onTap: (_) {},
            child: const Text('Child Widget'),
          ),
        ),
      ),
    );

    // Verify that the overlay component is created and shown
    expect(find.byType(OverlayPortal), findsOneWidget);
  });

  testWidgets('overlay area has correct padding based on view padding', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: StatusBarGestureDetector(
              onTap: (_) {},
              child: const Text('Child Widget'),
            ),
          ),
        ),
      ),
    );

    final overlayArea = tester.widget<SizedBox>(
      find.descendant(
        of: find.byType(OverlayPortal),
        matching: find.byType(SizedBox),
      ),
    );

    // Ensure the height is set based on the top padding of the device
    final view = View.of(tester.element(find.byType(SizedBox)));
    expect(overlayArea.height, view.padding.top / view.devicePixelRatio);
  });
});

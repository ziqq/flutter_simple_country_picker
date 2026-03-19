import 'package:example/main.dart' show Preview;
import 'package:example/src/common/widget/app.dart';
import 'package:flutter/foundation.dart' show ValueKey;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the preview phone input', (tester) async {
    await tester.pumpWidget(const App(home: Preview()));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('country_phone_input')),
      findsOneWidget,
    );
  });
}

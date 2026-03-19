import 'package:example/main.dart' show Preview;
import 'package:example/src/common/widget/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders preview tabs', (tester) async {
    await tester.pumpWidget(const App(home: Preview()));
    await tester.pumpAndSettle();

    expect(find.text('Preview'), findsWidgets);
    expect(find.text('Preview extended'), findsOneWidget);
  });
}

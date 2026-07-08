import 'package:flutter_test/flutter_test.dart';
import 'package:blood_donation/app.dart';
import 'package:blood_donation/bootstrap/app_initializer.dart';

void main() {
  testWidgets('App should initialize', (WidgetTester tester) async {
    final appInitializer = AppInitializer();
    await tester.pumpWidget(
      BloodDonorApp(appInitializer: appInitializer),
    );
    await tester.pump();
    expect(find.text('Blood Donor Network'), findsOneWidget);
  });
}

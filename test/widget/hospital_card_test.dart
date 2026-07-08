import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blood_donation/features/hospitals/screens/hospitals_screen.dart';

/// Helper to render a HospitalCard in a MaterialApp with ScreenUtil initialized.
Future<void> pumpHospitalCard(WidgetTester tester, Widget cardWidget) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, _) => MaterialApp(
        useInheritedMediaQuery: true,
        home: Scaffold(
          body: SingleChildScrollView(
            child: cardWidget,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('HospitalCard renders name and address', (tester) async {
    await pumpHospitalCard(tester,
      const HospitalCard(
        name: 'City General Hospital',
        address: '123 Main Street, New York',
      ),
    );

    expect(find.text('City General Hospital'), findsOneWidget);
    expect(find.text('123 Main Street, New York'), findsOneWidget);
  });

  testWidgets('HospitalCard shows Verified badge when verified', (tester) async {
    await pumpHospitalCard(tester,
      const HospitalCard(
        name: 'Verified Hospital',
        address: '456 Oak Ave',
        phone: '+1-555-1234',
        latitude: 40.7128,
        longitude: -74.0060,
        verified: true,
      ),
    );

    expect(find.text('Verified'), findsOneWidget);
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Navigate'), findsOneWidget);
  });

  testWidgets('HospitalCard hides Verified badge when not verified', (tester) async {
    await pumpHospitalCard(tester,
      const HospitalCard(
        name: 'Unverified Hospital',
        address: '789 Pine Rd',
        verified: false,
      ),
    );

    expect(find.text('Verified'), findsNothing);
  });

  testWidgets('HospitalCard shows call and navigate buttons when phone and coords present', (tester) async {
    await pumpHospitalCard(tester,
      const HospitalCard(
        name: 'Full Hospital',
        address: '321 Elm St',
        phone: '+1-555-1234',
        latitude: 40.7128,
        longitude: -74.0060,
        verified: true,
      ),
    );

    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Navigate'), findsOneWidget);
  });

  testWidgets('HospitalCard hides call button when no phone', (tester) async {
    await pumpHospitalCard(tester,
      const HospitalCard(
        name: 'No Phone Hospital',
        address: '555 Cedar Ln',
        latitude: 34.0522,
        longitude: -118.2437,
      ),
    );

    expect(find.text('Call'), findsNothing);
    expect(find.text('Navigate'), findsOneWidget);
  });

  testWidgets('HospitalCard hides navigate button when no coordinates', (tester) async {
    await pumpHospitalCard(tester,
      const HospitalCard(
        name: 'No Location Hospital',
        address: '999 Maple Dr',
        phone: '+1-555-9999',
      ),
    );

    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Navigate'), findsNothing);
  });

  testWidgets('HospitalCard shows operating hours when provided', (tester) async {
    await pumpHospitalCard(tester,
      const HospitalCard(
        name: 'Hours Hospital',
        address: '777 Birch St',
        hours: 'Mon-Fri 9AM-6PM',
      ),
    );

    expect(find.text('Mon-Fri 9AM-6PM'), findsOneWidget);
  });

  testWidgets('HospitalCard hides hours when not provided', (tester) async {
    await pumpHospitalCard(tester,
      const HospitalCard(
        name: 'No Hours Hospital',
        address: '888 Walnut Ave',
      ),
    );

    // There should be no clock icon since hours is null
    expect(find.byIcon(Icons.access_time_rounded), findsNothing);
  });

  testWidgets('HospitalCard displays hospital icon', (tester) async {
    await pumpHospitalCard(tester,
      const HospitalCard(
        name: 'Icon Hospital',
        address: '111 Test Blvd',
      ),
    );

    expect(find.byIcon(Icons.local_hospital_rounded), findsOneWidget);
  });
}

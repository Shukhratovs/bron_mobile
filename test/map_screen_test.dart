import 'package:bron_mobile/core/widgets/bron_logo.dart';
import 'package:bron_mobile/features/map/presentation/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (context, _) => MaterialApp(
        home: child,
      ),
    );
  }

  testWidgets('MapScreen renders header, map, pins, and venue cards carousel',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestableWidget(const MapScreen()));
    await tester.pumpAndSettle();

    // Verify Bron Logo in Header
    expect(find.byType(BronLogo), findsOneWidget);

    // Verify Header Action Buttons
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

    // Verify Venue Cards Carousel Items
    expect(find.text('Osteria Da Vinci'), findsWidgets);
    expect(find.text('1,2 km · ~120 ming'), findsOneWidget);

    // Verify Bron Pins
    expect(find.text('B'), findsWidgets);
  });
}

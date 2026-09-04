import 'package:bron_mobile/core/constants/app_strings.dart';
import 'package:bron_mobile/features/main/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:bron_mobile/features/main/presentation/widgets/ios_liquid_glass_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => MaterialApp(
        home: Scaffold(
          extendBody: true,
          body: const Center(child: Text('Content')),
          bottomNavigationBar: child,
        ),
      ),
    );
  }

  testWidgets('IosLiquidGlassNavBar renders items and switches tabs on tap',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    int selectedIndex = 0;

    await tester.pumpWidget(
      buildTestableWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return IosLiquidGlassNavBar(
              currentIndex: selectedIndex,
              onTap: (i) {
                setState(() {
                  selectedIndex = i;
                });
              },
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify all 4 tabs are present
    expect(find.text(AppStrings.navHome), findsOneWidget);
    expect(find.text(AppStrings.navMap), findsOneWidget);
    expect(find.text(AppStrings.navBookings), findsOneWidget);
    expect(find.text(AppStrings.navProfile), findsOneWidget);

    // Tap Map tab (index 1)
    await tester.tap(find.text(AppStrings.navMap));
    await tester.pumpAndSettle();
    expect(selectedIndex, 1);

    // Tap Bookings tab (index 2)
    await tester.tap(find.text(AppStrings.navBookings));
    await tester.pumpAndSettle();
    expect(selectedIndex, 2);

    // Tap Profile tab (index 3)
    await tester.tap(find.text(AppStrings.navProfile));
    await tester.pumpAndSettle();
    expect(selectedIndex, 3);
  });

  testWidgets('IosLiquidGlassNavBar handles horizontal drag gestures',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    int selectedIndex = 0;

    await tester.pumpWidget(
      buildTestableWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return IosLiquidGlassNavBar(
              currentIndex: selectedIndex,
              onTap: (i) {
                setState(() {
                  selectedIndex = i;
                });
              },
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Drag from left to right across the navbar
    await tester.drag(find.byType(IosLiquidGlassNavBar), const Offset(200, 0));
    await tester.pumpAndSettle();
    expect(selectedIndex >= 1, isTrue);
  });
}

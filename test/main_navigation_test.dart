import 'package:bron_mobile/core/constants/app_strings.dart';
import 'package:bron_mobile/features/bookings/presentation/screens/bookings_screen.dart';
import 'package:bron_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:bron_mobile/features/main/presentation/screens/main_navigation_screen.dart';
import 'package:bron_mobile/features/main/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:bron_mobile/features/map/presentation/screens/map_screen.dart';
import 'package:bron_mobile/features/profile/presentation/screens/profile_screen.dart';
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
        home: child,
      ),
    );
  }

  testWidgets('MainNavigationScreen renders bottom nav bar with all 4 tabs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestableWidget(const MainNavigationScreen()));

    expect(find.byType(CustomBottomNavBar), findsOneWidget);
    expect(find.text(AppStrings.navHome), findsOneWidget);
    expect(find.text(AppStrings.navMap), findsOneWidget);
    expect(find.text(AppStrings.navBookings), findsOneWidget);
    expect(find.text(AppStrings.navProfile), findsOneWidget);

    // Initial tab is HomeScreen
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('MainNavigationScreen switches tabs when bottom nav item tapped',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestableWidget(const MainNavigationScreen()));

    // Tap Map tab
    await tester.tap(find.text(AppStrings.navMap));
    await tester.pumpAndSettle();
    expect(find.byType(MapScreen), findsOneWidget);

    // Tap Bookings tab
    await tester.tap(find.text(AppStrings.navBookings));
    await tester.pumpAndSettle();
    expect(find.byType(BookingsScreen), findsOneWidget);

    // Tap Profile tab
    await tester.tap(find.text(AppStrings.navProfile));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);

    // Tap Home tab
    await tester.tap(find.text(AppStrings.navHome));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}

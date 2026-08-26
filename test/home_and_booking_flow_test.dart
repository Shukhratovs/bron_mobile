import 'package:bron_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:bron_mobile/features/home/presentation/widgets/home_available_today_section.dart';
import 'package:bron_mobile/features/home/presentation/widgets/home_banner_widget.dart';
import 'package:bron_mobile/features/home/presentation/widgets/home_categories_widget.dart';
import 'package:bron_mobile/features/home/presentation/widgets/home_header_widget.dart';
import 'package:bron_mobile/features/home/presentation/widgets/home_search_bar_widget.dart';
import 'package:bron_mobile/features/home/presentation/widgets/venue_card_widget.dart';
import 'package:bron_mobile/features/venue_detail/presentation/screens/venue_detail_screen.dart';
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

  testWidgets('HomeScreen renders all primary Figma sections',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestableWidget(const HomeScreen()));

    // 1. Header with Logo & City
    expect(find.byType(HomeHeaderWidget), findsOneWidget);

    // 2. Search Bar
    expect(find.byType(HomeSearchBarWidget), findsOneWidget);

    // 3. Category Selectors
    expect(find.byType(HomeCategoriesWidget), findsOneWidget);

    // 4. Promo Banner
    expect(find.byType(HomeBannerWidget), findsOneWidget);

    // 5. Bugun 19:30 ga borish
    expect(find.byType(HomeAvailableTodaySection), findsOneWidget);
    expect(find.text('Bugun 19:30 ga borish'), findsOneWidget);

    // 6. Near Places / Feed
    expect(find.text('Yaqin atrofda'), findsOneWidget);
    expect(find.byType(VenueCardWidget), findsWidgets);
  });

  testWidgets('Tapping on a venue card navigates to VenueDetailScreen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestableWidget(const HomeScreen()));

    // Tap first venue card (scroll into view if needed)
    final venueCard = find.byType(VenueCardWidget).first;
    await tester.scrollUntilVisible(
      venueCard,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(venueCard);
    await tester.pumpAndSettle();

    expect(find.byType(VenueDetailScreen), findsOneWidget);
    expect(find.text('Bron qilish'), findsOneWidget);
    expect(find.text('Mashhur taomlar'), findsOneWidget);
  });
}

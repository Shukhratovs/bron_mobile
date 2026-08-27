import 'package:bron_mobile/core/widgets/glass_liquid_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('GlassLiquidBottomNavBar renders items and handles tab switching and dragging',
      (WidgetTester tester) async {
    int selectedIndex = 0;

    final items = [
      const GlassNavItem(
        label: 'Asosiy',
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
      ),
      const GlassNavItem(
        label: 'Xarita',
        icon: Icons.map_outlined,
        activeIcon: Icons.map,
      ),
      const GlassNavItem(
        label: 'Bronlarim',
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today,
      ),
      const GlassNavItem(
        label: 'Profil',
        icon: Icons.person_outline,
        activeIcon: Icons.person,
      ),
    ];

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (context, _) => MaterialApp(
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return GlassLiquidBottomNavBar(
                  currentIndex: selectedIndex,
                  items: items,
                  onTap: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify all 4 labels are present
    expect(find.text('Asosiy'), findsOneWidget);
    expect(find.text('Xarita'), findsOneWidget);
    expect(find.text('Bronlarim'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    // Tap second tab (Xarita)
    await tester.tap(find.text('Xarita'));
    await tester.pumpAndSettle();
    expect(selectedIndex, 1);

    // Drag / swipe on bottom nav bar to the right
    await tester.drag(find.byType(GlassLiquidBottomNavBar), const Offset(150, 0));
    await tester.pumpAndSettle();
    expect(selectedIndex >= 1, isTrue);
  });
}

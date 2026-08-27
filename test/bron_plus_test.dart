import 'package:bron_mobile/features/profile/presentation/screens/bonus_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BonusScreen / BRON PLUS Tests', () {
    testWidgets('Renders Purchase View when not subscribed', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, child) {
            return const MaterialApp(
              home: BonusScreen(initialIsActive: false),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('BRON PLUS'), findsOneWidget);
      expect(find.text('Pik soatlarda ham\nbron kafolati'), findsOneWidget);
      expect(find.text('Prioritet bron'), findsOneWidget);
      expect(find.text('Har bronda 10% chegirma'), findsOneWidget);
      expect(find.text('Depozitsiz bron'), findsOneWidget);
      expect(find.text('Tug\'ilgan kun sovg\'asi'), findsOneWidget);
      expect(find.text('1 oy'), findsOneWidget);
      expect(find.text('12 oy'), findsOneWidget);
      expect(find.text('Plus\'ni yoqish · 390 000 so\'m'), findsOneWidget);

      // Ensure visible and Select 1 month plan
      await tester.ensureVisible(find.text('1 oy'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1 oy'));
      await tester.pumpAndSettle();

      expect(find.text('Plus\'ni yoqish · 39 000 so\'m'), findsOneWidget);
    });

    testWidgets('Renders Active Subscription View and opens Cancel Bottom Sheet', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, child) {
            return const MaterialApp(
              home: BonusScreen(initialIsActive: true),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Obuna'), findsOneWidget);
      expect(find.text('Obuna faol'), findsOneWidget);
      expect(find.text('480 000 so\'m'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('FAOL IMTIYOZLAR'), findsOneWidget);
      expect(find.text('Obunani bekor qilish'), findsOneWidget);

      // Scroll and Tap Obunani bekor qilish
      await tester.ensureVisible(find.text('Obunani bekor qilish'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Obunani bekor qilish'));
      await tester.pumpAndSettle();

      expect(find.text('Obunani bekor qilasizmi?'), findsOneWidget);
      expect(find.text('Yo\'q, obunani qoldiraman'), findsOneWidget);
      expect(find.text('Ha, bekor qilaman'), findsOneWidget);

      // Ensure visible inside bottom sheet and tap cancel
      await tester.ensureVisible(find.text('Ha, bekor qilaman'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ha, bekor qilaman'));
      await tester.pumpAndSettle();

      // Should revert to purchase view
      expect(find.text('Pik soatlarda ham\nbron kafolati'), findsOneWidget);
    });
  });
}

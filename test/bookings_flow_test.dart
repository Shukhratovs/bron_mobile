import 'package:bron_mobile/features/bookings/presentation/screens/booking_detail_screen.dart';
import 'package:bron_mobile/features/bookings/presentation/screens/bookings_screen.dart';
import 'package:bron_mobile/features/bookings/presentation/screens/live_queue_scanner_screen.dart';
import 'package:bron_mobile/features/bookings/presentation/widgets/table_ready_bottom_sheet.dart';
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

  group('Bookings Flow Tests', () {
    testWidgets('BookingsScreen renders all sections, tabs and handles interactions',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const BookingsScreen()));
      await tester.pumpAndSettle();

      // Check title and Jonli navbat button
      expect(find.text('Bronlarim'), findsOneWidget);
      expect(find.text('Jonli navbat'), findsOneWidget);

      // Check Segmented Tabs
      expect(find.text('Faol'), findsOneWidget);
      expect(find.text('O\'tgan'), findsOneWidget);

      // Check Live Queue Card
      expect(find.text('NAVBATDASIZ'), findsOneWidget);
      expect(find.text('19:00–20:00'), findsOneWidget);
      expect(find.text('~25 daqiqa'), findsOneWidget);

      // Check Sections
      expect(find.text('BUGUN'), findsOneWidget);
      expect(find.text('KEYINGI KUNLAR'), findsOneWidget);
      expect(find.text('Chorsu Osh Markazi'), findsOneWidget);
      expect(find.text('Plov Center'), findsOneWidget);

      // Switch to O'tgan tab
      await tester.tap(find.text('O\'tgan'));
      await tester.pumpAndSettle();
      expect(find.text('Level Up Game Club'), findsOneWidget);
      expect(find.text('Bahor Choyxonasi'), findsOneWidget);

      // Switch back to Faol
      await tester.tap(find.text('Faol'));
      await tester.pumpAndSettle();
      expect(find.text('BUGUN'), findsOneWidget);
    });

    testWidgets('Tapping live queue card opens TableReadyBottomSheet and confirms',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const BookingsScreen()));
      await tester.pumpAndSettle();

      // Tap Live queue card
      await tester.tap(find.text('NAVBATDASIZ'));
      await tester.pumpAndSettle();

      // Verify TableReadyBottomSheet is shown
      expect(find.byType(TableReadyBottomSheet), findsOneWidget);
      expect(find.text('Stol bo\'shadi'), findsOneWidget);
      expect(find.text('Bronni tasdiqlash'), findsOneWidget);

      // Confirm table
      await tester.tap(find.text('Bronni tasdiqlash'));
      await tester.pumpAndSettle();

      // Verify navigated to BookingDetailScreen
      expect(find.byType(BookingDetailScreen), findsOneWidget);
      expect(find.text('Bron tafsilotlari'), findsOneWidget);
      expect(find.text('BRN-4821'), findsOneWidget);
      expect(find.text('Men shu yerdaman'), findsOneWidget);
    });

    testWidgets('LiveQueueScannerScreen renders correctly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const LiveQueueScannerScreen()));
      await tester.pump();

      expect(find.text('QR kodni skanerlang'), findsOneWidget);
      expect(find.text('Kodni qo\'lda kiritish'), findsOneWidget);
      expect(find.text('Kod topilmadi kamerani yaqinroq tuting'), findsOneWidget);
    });
  });
}

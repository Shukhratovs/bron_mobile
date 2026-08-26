import 'package:bron_mobile/core/widgets/bron_logo.dart';
import 'package:bron_mobile/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget({Widget? nextScreen, Duration? duration, VoidCallback? onInit}) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (context, _) => MaterialApp(
        home: SplashScreen(
          duration: duration ?? const Duration(milliseconds: 500),
          nextScreen: nextScreen,
          onInitialization: onInit,
        ),
      ),
    );
  }

  testWidgets('SplashScreen renders BronLogo and slogan text',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());

    expect(find.byType(BronLogo), findsOneWidget);
    expect(find.text('Tez va oson bron qilish'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('SplashScreen calls onInitialization and navigates to nextScreen',
      (WidgetTester tester) async {
    bool initCalled = false;

    await tester.pumpWidget(
      buildTestWidget(
        duration: const Duration(milliseconds: 200),
        onInit: () => initCalled = true,
        nextScreen: const Scaffold(body: Center(child: Text('Next Screen'))),
      ),
    );

    expect(initCalled, isTrue);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Next Screen'), findsOneWidget);
  });
}

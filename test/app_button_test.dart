import 'package:bron_mobile/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (context, _) => MaterialApp(
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }

  testWidgets('AppButton.white renders correctly and fires callback',
      (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      buildTestableWidget(
        AppButton.white(
          text: 'Boshlash',
          onPressed: () => tapped = true,
        ),
      ),
    );

    expect(find.text('Boshlash'), findsOneWidget);
    await tester.tap(find.text('Boshlash'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('AppButton.primary renders with text',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        AppButton.primary(
          text: 'Davom etish',
          onPressed: () {},
        ),
      ),
    );

    expect(find.text('Davom etish'), findsOneWidget);
  });

  testWidgets('AppButton shows loading indicator when isLoading is true',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        const AppButton(
          text: 'Yuklanmoqda',
          isLoading: true,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Yuklanmoqda'), findsNothing);
  });
}

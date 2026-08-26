import 'package:bron_mobile/core/constants/app_strings.dart';
import 'package:bron_mobile/core/network/api_client.dart';
import 'package:bron_mobile/core/network/api_result.dart';
import 'package:bron_mobile/features/onboarding/data/datasources/onboarding_remote_data_source.dart';
import 'package:bron_mobile/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:bron_mobile/features/onboarding/domain/entities/onboarding_entity.dart';
import 'package:bron_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OnboardingRepository returns 5 items successfully', () async {
    final dataSource = OnboardingRemoteDataSourceImpl(
      apiClient: DummyApiClient(),
    );
    final repository = OnboardingRepositoryImpl(remoteDataSource: dataSource);

    final result = await repository.getOnboardingItems();

    expect(result, isA<Success<List<OnboardingEntity>>>());
    if (result is Success<List<OnboardingEntity>>) {
      expect(result.data.length, 5);
      expect(result.data.first.title, AppStrings.onboardingTitle1);
    }
  });

  testWidgets('OnboardingScreen renders correctly and shows story indicator',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (context, child) {
          return const MaterialApp(
            home: OnboardingScreen(),
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(PageView), findsOneWidget);
    expect(find.text(AppStrings.onboardingSkip), findsOneWidget);
    expect(find.text(AppStrings.onboardingTitle1), findsOneWidget);
  });
}

class DummyApiClient implements ApiClient {
  @override
  Future<dynamic> get(String url, {Map<String, String>? headers}) async => [];
  @override
  Future<dynamic> post(String url, {Map<String, String>? headers, dynamic body}) async => null;
  @override
  Future<dynamic> put(String url, {Map<String, String>? headers, dynamic body}) async => null;
  @override
  Future<dynamic> delete(String url, {Map<String, String>? headers}) async => null;
}

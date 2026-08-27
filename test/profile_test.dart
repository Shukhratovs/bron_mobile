import 'package:bron_mobile/core/constants/app_strings.dart';
import 'package:bron_mobile/core/network/api_client.dart';
import 'package:bron_mobile/core/network/api_result.dart';
import 'package:bron_mobile/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:bron_mobile/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:bron_mobile/features/profile/domain/entities/booking_entity.dart';
import 'package:bron_mobile/features/profile/domain/entities/user_profile_entity.dart';
import 'package:bron_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ProfileRepository returns user profile and bookings successfully', () async {
    final dataSource = ProfileRemoteDataSourceImpl(apiClient: DummyApiClient());
    final repository = ProfileRepositoryImpl(remoteDataSource: dataSource);

    final userResult = await repository.getUserProfile();
    expect(userResult, isA<Success<UserProfileEntity>>());
    if (userResult is Success<UserProfileEntity>) {
      expect(userResult.data.firstName, 'Aziz');
      expect(userResult.data.bonusBalance, 25000);
    }

    final bookingsResult = await repository.getMyBookings();
    expect(bookingsResult, isA<Success<List<BookingEntity>>>());
    if (bookingsResult is Success<List<BookingEntity>>) {
      expect(bookingsResult.data.length, greaterThanOrEqualTo(1));
    }
  });

  testWidgets('ProfileScreen renders user information and menu items',
      (WidgetTester tester) async {
    final dataSource = ProfileRemoteDataSourceImpl(apiClient: DummyApiClient());
    final repository = ProfileRepositoryImpl(remoteDataSource: dataSource);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (context, child) {
          return MaterialApp(
            home: ProfileScreen(repository: repository),
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Aziz Karimov'), findsOneWidget);
    expect(find.text(AppStrings.bronPlus), findsOneWidget);
    expect(find.text(AppStrings.myCards), findsOneWidget);
    expect(find.text(AppStrings.myFavorites), findsOneWidget);
    expect(find.text(AppStrings.notifications), findsOneWidget);
    expect(find.text(AppStrings.help), findsOneWidget);
    expect(find.text(AppStrings.becomePartner), findsOneWidget);
    expect(find.text(AppStrings.logoutAccount), findsOneWidget);
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

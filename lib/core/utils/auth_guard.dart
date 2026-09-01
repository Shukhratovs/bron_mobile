import 'package:flutter/material.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../network/app_session.dart';

/// Bron qilish / navbatga yozilish / karta qo'shish каби token talab
/// qiladigan amallardan oldin chaqiriladi. Mehmon ko'rib chiqishda kirmasdan
/// yura oladi (00-boshlash.md §4), lekin yozuv amali oldidan kirish so'raladi.
Future<bool> ensureLoggedIn(BuildContext context) async {
  if (AppSession.authLocalStorage.isLoggedIn) return true;

  final loggedIn = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (context) => LoginScreen(
        authRepository: AuthRepositoryImpl(
          remoteDataSource: AuthRemoteDataSourceImpl(apiClient: AppSession.apiClient),
          authLocalStorage: AppSession.authLocalStorage,
        ),
      ),
    ),
  );
  return loggedIn == true;
}

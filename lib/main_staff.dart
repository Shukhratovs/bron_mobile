import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'features/staff/auth/presentation/screens/staff_login_screen.dart';
import 'features/staff/core/staff_session.dart';
import 'features/staff/main/presentation/screens/staff_main_screen.dart';

/// Xostes (xodim) ilovasining alohida ildizi.
/// Ishga tushirish: `flutter run -t lib/main_staff.dart`
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StaffSession.init();
  runApp(const StaffApp());
}

class StaffApp extends StatelessWidget {
  const StaffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(402, 874),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Bron Xostes',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: StaffSession.localStorage.isLoggedIn ? const StaffMainScreen() : const StaffLoginScreen(),
        );
      },
    );
  }
}

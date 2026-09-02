import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/language/language_cubit.dart';
import 'core/network/app_session.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSession.init();
  // TODO: Firebase push notification — keyinroq yoqish:
  // await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // await PushNotificationService.instance.init();

  final languageCubit = LanguageCubit();
  await languageCubit.init();

  runApp(MyApp(languageCubit: languageCubit));
}

class MyApp extends StatelessWidget {
  final LanguageCubit languageCubit;

  const MyApp({super.key, required this.languageCubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LanguageCubit>.value(
      value: languageCubit,
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, langState) {
              return MaterialApp(
                title: AppStrings.appName,
                debugShowCheckedModeBanner: false,
                themeMode: ThemeMode.light,
                darkTheme: AppTheme.darkTheme,
                theme: AppTheme.lightTheme,
                home: child,
              );
            },
          );
        },
        child: const SplashScreen(),
      ),
    );
  }
}

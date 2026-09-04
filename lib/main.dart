import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'core/language/language_cubit.dart';
import 'core/network/app_session.dart';
import 'core/services/push_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/system_nav.dart';
import 'core/constants/app_strings.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSession.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await AppSession.pushService.init();
  await LiquidGlassWidgets.initialize();

  final languageCubit = LanguageCubit();
  await languageCubit.init();

  runApp(LiquidGlassWidgets.wrap(child: MyApp(languageCubit: languageCubit)));
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
                // 3 tugmali Android navigatsiyasida butun ilova tizim
                // paneli ustiga chiqib ketmasligi uchun yuqoriga suriladi.
                // Imo-ishora (gesture) navigatsiyada bo'sh joy kichik
                // bo'lgani uchun bu shart emas — floating panellar (pastki
                // navigatsiya) o'zining oddiy sobit bo'shlig'i bilan
                // yetarli.
                builder: (context, navigatorChild) => SafeArea(
                  top: false,
                  bottom: isThreeButtonAndroidNav(context),
                  child: navigatorChild ?? const SizedBox.shrink(),
                ),
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

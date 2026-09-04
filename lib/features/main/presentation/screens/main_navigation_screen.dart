import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../../../core/language/language_cubit.dart';
import '../../../bookings/presentation/screens/bookings_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../map/presentation/screens/map_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/ios_liquid_glass_nav_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    HomeScreen(),
    MapScreen(),
    BookingsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
        final body = IndexedStack(
          index: _currentIndex,
          children: _screens,
        );

        if (defaultTargetPlatform == TargetPlatform.iOS || kForceIosNavBarOnAndroid) {
          return GlassScaffold(
            extendBody: true,
            backgroundColor: Colors.white,
            body: body,
            bottomBar: buildIosGlassTabBar(
              selectedIndex: _currentIndex,
              onTabSelected: _onTabSelected,
            ),
          );
        }

        return Scaffold(
          extendBody: true,
          backgroundColor: Colors.white,
          body: body,
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: _onTabSelected,
          ),
        );
      },
    );
  }
}

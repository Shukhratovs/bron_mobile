import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        return Scaffold(
          extendBody: true,
          backgroundColor: Colors.white,
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: defaultTargetPlatform == TargetPlatform.iOS
              ? IosLiquidGlassNavBar(
                  currentIndex: _currentIndex,
                  onTap: _onTabSelected,
                )
              : CustomBottomNavBar(
                  currentIndex: _currentIndex,
                  onTap: _onTabSelected,
                ),
        );
      },
    );
  }
}

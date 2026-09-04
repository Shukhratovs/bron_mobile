import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'custom_bottom_nav_bar.dart' show CustomBottomNavBar;

// TODO(test): revert to false before release — forces the iOS liquid-glass
// navbar to render on Android too, for on-device testing without an iPhone.
const bool kForceIosNavBarOnAndroid = true;

/// Height of the floating glass tab bar (`GlassTabBar.bottom`'s `barHeight`).
const double iosNavBarHeight = 64.0;

const Color _activeColor = Color(0xFFDC3009);
const Color _inactiveColor = Color(0xFF332C2C);

/// Reserved space at the bottom of screens so scrollable content clears the
/// floating iOS glass navbar comfortably.
double iosNavBarReservedBottomSpace(BuildContext context) {
  final bottomInset = MediaQuery.of(context).padding.bottom;
  return iosNavBarHeight + (bottomInset > 0 ? bottomInset : 4) + 16;
}

/// Builds the tab list for `GlassTabBar.bottom` from the same source
/// ([CustomBottomNavBar.items]) Android's navbar uses, so both platforms
/// navigate to the same four screens with the same icons/labels.
List<GlassTab> buildIosGlassTabs() {
  return CustomBottomNavBar.items
      .map(
        (item) => GlassTab(
          label: item.label,
          icon: SvgPicture.asset(
            item.svgPath,
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(_inactiveColor, BlendMode.srcIn),
          ),
          activeIcon: SvgPicture.asset(item.activeSvgPath, width: 22, height: 22),
        ),
      )
      .toList();
}

/// The floating iOS 26 "Liquid Glass" tab bar, built on `liquid_glass_widgets`
/// (a purpose-built glass design-system package) rather than a hand-rolled
/// shader composition — must be placed as `GlassScaffold.bottomBar`.
Widget buildIosGlassTabBar({
  required int selectedIndex,
  required ValueChanged<int> onTabSelected,
}) {
  const unselectedLabelStyle = TextStyle(
    decoration: TextDecoration.none,
    color: _inactiveColor,
    fontWeight: FontWeight.w500,
  );
  const selectedLabelStyle = TextStyle(
    decoration: TextDecoration.none,
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );
  return GlassTabBar.bottom(
    tabs: buildIosGlassTabs(),
    selectedIndex: selectedIndex,
    onTabSelected: onTabSelected,
    barHeight: iosNavBarHeight,
    verticalPadding: 8,
    indicatorColor: _activeColor.withValues(alpha: 0.15),
    selectedLabelStyle: selectedLabelStyle,
    unselectedLabelStyle: unselectedLabelStyle,
  );
}

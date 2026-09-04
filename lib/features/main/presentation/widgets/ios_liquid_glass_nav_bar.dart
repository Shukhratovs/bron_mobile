import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_bottom_nav_bar.dart' show CustomBottomNavBar;

/// iOS-only bottom nav bar: an edge-to-edge, dark "Liquid Glass" panel
/// (frosted blur + thin top border, top corners only) as opposed to
/// [CustomBottomNavBar]'s floating orange pill used on Android. Shares the
/// same tabs/icons/labels via [CustomBottomNavBar.items] so both platforms
/// navigate to the same four screens.
class IosLiquidGlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const IosLiquidGlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const double contentHeight = 80;
  static const Color activeColor = Color(0xFF0A84FF); // iOS systemBlue (dark)
  static const Color inactiveColor = Color(0xFF9E9EA3);

  static double reservedBottomSpace(BuildContext context) =>
      contentHeight + MediaQuery.of(context).padding.bottom;

  @override
  Widget build(BuildContext context) {
    final items = CustomBottomNavBar.items;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: contentHeight + bottomInset,
          padding: EdgeInsets.only(bottom: bottomInset),
          decoration: const BoxDecoration(
            color: Color(0xD91C1C1E), // Color(0xFF1C1C1E) @ ~0.85 opacity
            border: Border(
              top: BorderSide(color: Colors.white24, width: 0.5),
            ),
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTap(index);
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? activeColor.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            isSelected ? item.activeSvgPath : item.svgPath,
                            width: 28,
                            height: 28,
                            colorFilter: ColorFilter.mode(
                              isSelected ? activeColor : inactiveColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

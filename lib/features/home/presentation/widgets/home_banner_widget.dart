import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/banner_model.dart';

class HomeBannerWidget extends StatelessWidget {
  final BannerModel banner;
  final VoidCallback? onTap;

  const HomeBannerWidget({
    super.key,
    required this.banner,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 84.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            if (banner.imagePath != null)
              Image.asset(
                banner.imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: const Color(0xFF2C1810)),
              ),
            // Subtle overlay for text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 16.w, 14.h),
              child: Row(
                children: [
                  // Discount badge
                  Container(
                    width: 56.r,
                    height: 56.r,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        banner.discount,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFFF2EF),
                        ),
                      ),
                    ),
                  ),
                  Gap(14.w),
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          banner.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Gap(3.h),
                        Text(
                          banner.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

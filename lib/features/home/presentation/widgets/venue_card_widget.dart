import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../venue/domain/entities/venue_entity.dart';
import 'time_slot_chip.dart';

class VenueCardWidget extends StatelessWidget {
  final VenueEntity venue;
  final VoidCallback? onTap;
  final Function(String time)? onTimeSlotTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  const VenueCardWidget({
    super.key,
    required this.venue,
    this.onTap,
    this.onTimeSlotTap,
    this.onFavoriteTap,
    this.isFavorite = false,
  });

  String get _subtitle {
    final parts = <String>[
      if (venue.cuisine != null && venue.cuisine!.isNotEmpty) venue.cuisine!,
      if (venue.cuisine == null && venue.district != null && venue.district!.isNotEmpty) venue.district!,
      if (venue.distanceKm != null) '${venue.distanceKm!.toStringAsFixed(1)} km',
      if (venue.avgCheck != null) '~${formatSom(venue.avgCheck!)}',
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                  child: _VenueImage(url: venue.photoUrl, height: 180.h),
                ),
                // Depozit badge
                if (venue.depositRequired == true)
                  Positioned(
                    left: 12.w,
                    top: 12.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        AppStrings.deposit,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                // Favorite heart
                Positioned(
                  right: 12.w,
                  top: 12.h,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: Container(
                      width: 34.r,
                      height: 34.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: AppIcon(
                          isFavorite
                              ? AppAssets.iconHeartFill
                              : AppAssets.iconHeartLine,
                          size: 18.r,
                          color: isFavorite
                              ? AppColors.primary
                              : const Color(0xFF5C5C5C),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Body
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          venue.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF161616),
                          ),
                        ),
                      ),
                      if (venue.rating != null) ...[
                        Gap(8.w),
                        AppIcon(
                          AppAssets.iconStarFill,
                          size: 16.r,
                          color: AppColors.primary,
                        ),
                        Gap(4.w),
                        Text(
                          venue.rating!.toStringAsFixed(1),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF161616),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (_subtitle.isNotEmpty) ...[
                    Gap(4.h),
                    Text(
                      _subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF5C5C5C),
                      ),
                    ),
                  ],
                  // Time slots
                  if (venue.freeSlots.isNotEmpty) ...[
                    Gap(10.h),
                    Row(
                      children: venue.freeSlots
                          .take(4)
                          .map(
                            (time) => Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: TimeSlotChip(
                                time: time,
                                large: true,
                                onTap: () => onTimeSlotTap?.call(time),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VenueImage extends StatelessWidget {
  final String? url;
  final double height;

  const _VenueImage({required this.url, required this.height});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        color: const Color(0xFFFFF2EF),
        child: Center(
          child: AppIcon(
            AppAssets.iconImageLine,
            size: 48.r,
            color: AppColors.textMuted,
          ),
        ),
      );
    }
    return Image.network(
      url!,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        width: double.infinity,
        color: const Color(0xFFFFF2EF),
        child: Center(
          child: AppIcon(
            AppAssets.iconImageLine,
            size: 48.r,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

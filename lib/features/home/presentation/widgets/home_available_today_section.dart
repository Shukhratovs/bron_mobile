import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../venue/domain/entities/venue_entity.dart';
import 'time_slot_chip.dart';

class HomeAvailableTodaySection extends StatelessWidget {
  final List<VenueEntity> venues;
  final ValueChanged<VenueEntity>? onVenueTap;
  final Function(VenueEntity venue, String time)? onTimeSlotTap;
  final VoidCallback? onViewAllTap;

  const HomeAvailableTodaySection({
    super.key,
    required this.venues,
    this.onVenueTap,
    this.onTimeSlotTap,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    if (venues.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                AppStrings.availableToday,
                style: GoogleFonts.unbounded(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF161616),
                ),
              ),
            ),
            GestureDetector(
              onTap: onViewAllTap,
              child: Text(
                AppStrings.viewAll,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFB12A0B),
                ),
              ),
            ),
          ],
        ),
        Gap(14.h),

        // Horizontal cards
        SizedBox(
          height: 214.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: venues.length,
            separatorBuilder: (context, index) => Gap(12.w),
            itemBuilder: (context, index) {
              final venue = venues[index];
              return GestureDetector(
                onTap: () => onVenueTap?.call(venue),
                child: Container(
                  width: 200.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16.r),
                        ),
                        child: venue.photoUrl == null || venue.photoUrl!.isEmpty
                            ? Container(
                                height: 110.h,
                                width: double.infinity,
                                color: const Color(0xFFF7F7F7),
                                child: Center(
                                  child: AppIcon(
                                    AppAssets.iconRestaurantLine,
                                    size: 28.r,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              )
                            : Image.network(
                                venue.photoUrl!,
                                height: 110.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 110.h,
                                  width: double.infinity,
                                  color: const Color(0xFFF7F7F7),
                                  child: Center(
                                    child: AppIcon(
                                      AppAssets.iconRestaurantLine,
                                      size: 28.r,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      // Body
                      Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name + rating
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    venue.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF161616),
                                    ),
                                  ),
                                ),
                                if (venue.rating != null) ...[
                                  Gap(4.w),
                                  AppIcon(
                                    AppAssets.iconStarFill,
                                    size: 13.r,
                                    color: AppColors.primary,
                                  ),
                                  Gap(3.w),
                                  Text(
                                    venue.rating!.toStringAsFixed(1),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF161616),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Gap(2.h),
                            // Meta
                            Text(
                              [
                                if (venue.cuisine != null) venue.cuisine!,
                                if (venue.cuisine == null &&
                                    venue.district != null)
                                  venue.district!,
                                if (venue.distanceKm != null)
                                  '${venue.distanceKm!.toStringAsFixed(1)} km',
                              ].join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFA3A3A3),
                              ),
                            ),
                            // Time slots
                            if (venue.freeSlots.isNotEmpty) ...[
                              Gap(8.h),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: venue.freeSlots
                                      .take(3)
                                      .map(
                                        (time) => Padding(
                                          padding: EdgeInsets.only(right: 6.w),
                                          child: TimeSlotChip(
                                            time: time,
                                            onTap: () => onTimeSlotTap?.call(
                                                venue, time),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

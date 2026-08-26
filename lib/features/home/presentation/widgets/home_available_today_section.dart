import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/venue_model.dart';
import 'time_slot_chip.dart';

class HomeAvailableTodaySection extends StatelessWidget {
  final List<VenueModel> venues;
  final ValueChanged<VenueModel>? onVenueTap;
  final Function(VenueModel venue, String time)? onTimeSlotTap;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Bugun 19:30 ga borish',
                style: GoogleFonts.unbounded(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: onViewAllTap,
              child: Row(
                children: [
                  Text(
                    AppStrings.viewAll,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Gap(2.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16.r,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
        Gap(14.h),

        // Horizontal List of Venues
        SizedBox(
          height: 225.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: venues.length,
            separatorBuilder: (context, index) => Gap(14.w),
            itemBuilder: (context, index) {
              final venue = venues[index];

              return GestureDetector(
                onTap: () => onVenueTap?.call(venue),
                child: Container(
                  width: 210.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Image
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16.r),
                        ),
                        child: Image.asset(
                          venue.imagePath,
                          height: 86.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 86.h,
                            color: const Color(0xFFF3F4F6),
                            child: Icon(
                              Icons.restaurant_rounded,
                              size: 28.r,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),

                      // Venue Info
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    venue.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 15.r,
                                    ),
                                    Gap(2.w),
                                    Text(
                                      venue.rating.toString(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Gap(4.h),
                            Text(
                              '${venue.address.split(' ').first} • ${venue.distance}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Gap(8.h),

                            // Time Slot Chips Row
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: venue.availableTimeSlots
                                    .take(3)
                                    .map(
                                      (time) => Padding(
                                        padding: EdgeInsets.only(right: 6.w),
                                        child: TimeSlotChip(
                                          time: time,
                                          onTap: () => onTimeSlotTap?.call(venue, time),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
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

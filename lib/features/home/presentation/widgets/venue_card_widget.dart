import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/venue_model.dart';
import 'time_slot_chip.dart';

class VenueCardWidget extends StatelessWidget {
  final VenueModel venue;
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image with Overlays
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(18.r),
                  ),
                  child: Image.asset(
                    venue.imagePath,
                    height: 154.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 154.h,
                      color: const Color(0xFFF3F4F6),
                      child: Icon(
                        Icons.image_outlined,
                        size: 48.r,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),

                // Category Tag
                Positioned(
                  left: 12.w,
                  top: 12.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      venue.category,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Favorite Heart Button
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18.r,
                          color: isFavorite ? AppColors.primary : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Card Body Info
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
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
                          style: GoogleFonts.unbounded(
                            fontSize: 15.sp,
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
                            size: 17.r,
                          ),
                          Gap(3.w),
                          Text(
                            venue.rating.toString(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            ' (${venue.reviewsCount})',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Gap(6.h),

                  // Location, Distance & Price
                  Text(
                    '${venue.address} • ${venue.distance} • ${venue.priceRange}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Gap(12.h),

                  // Available Time Slots Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: venue.availableTimeSlots
                          .map(
                            (time) => Padding(
                              padding: EdgeInsets.only(right: 6.w),
                              child: TimeSlotChip(
                                time: time,
                                onTap: () => onTimeSlotTap?.call(time),
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
  }
}

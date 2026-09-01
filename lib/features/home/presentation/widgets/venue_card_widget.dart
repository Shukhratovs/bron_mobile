import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../venue/domain/entities/venue_entity.dart';
import '../../../venue/venue_kind.dart';
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
      if (venue.district != null && venue.district!.isNotEmpty) venue.district!,
      if (venue.distanceKm != null) '${venue.distanceKm!.toStringAsFixed(1)} km',
      if (venue.avgCheck != null) '~${formatSom(venue.avgCheck!)}',
    ];
    return parts.join(' • ');
  }

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
                  child: _VenueImage(url: venue.photoUrl, height: 154.h),
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
                      venueKindLabel(venue.kind),
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
                      if (venue.rating != null)
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 17.r,
                            ),
                            Gap(3.w),
                            Text(
                              venue.rating!.toStringAsFixed(1),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (venue.reviewsCount != null)
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
                    _subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  // Available Time Slots Chips
                  if (venue.freeSlots.isNotEmpty) ...[
                    Gap(12.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: venue.freeSlots
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
        color: const Color(0xFFF3F4F6),
        child: Icon(
          Icons.image_outlined,
          size: 48.r,
          color: AppColors.textMuted,
        ),
      );
    }
    return Image.network(
      url!,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        color: const Color(0xFFF3F4F6),
        child: Icon(
          Icons.image_outlined,
          size: 48.r,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

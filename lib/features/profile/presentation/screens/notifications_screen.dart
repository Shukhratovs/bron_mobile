import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/entities/notification_item_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class NotificationsScreen extends StatefulWidget {
  final ProfileRepository repository;

  const NotificationsScreen({
    super.key,
    required this.repository,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItemEntity> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final result = await widget.repository.getNotifications();
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          _notifications = data;
          _isLoading = false;
        });
      case Failure():
        setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: AppStrings.notifications,
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.markAllAsRead),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: Text(
              'O\'qilgan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 64.r, color: AppColors.textMuted),
                      Gap(12.h),
                      Text(
                        AppStrings.noNotifications,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  itemCount: _notifications.length,
                  separatorBuilder: (context, index) => Gap(12.h),
                  itemBuilder: (context, index) {
                    final item = _notifications[index];
                    return _buildNotificationCard(item);
                  },
                ),
    );
  }

  Widget _buildNotificationCard(NotificationItemEntity item) {
    final (icon, iconColor, iconBg) = switch (item.type) {
      NotificationType.booking => (Icons.calendar_today_rounded, AppColors.primary, AppColors.primarySoft),
      NotificationType.bonus => (Icons.stars_rounded, AppColors.warning, AppColors.warningSoft),
      NotificationType.promo => (Icons.local_offer_rounded, AppColors.info, AppColors.infoSoft),
      NotificationType.system => (Icons.info_outline_rounded, AppColors.textSecondary, AppColors.borderLight),
    };

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: item.isRead ? AppColors.borderLight : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22.r, color: iconColor),
          ),
          Gap(14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.sp,
                          fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (!item.isRead)
                      Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
                Gap(4.h),
                Text(
                  item.message,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                Gap(8.h),
                Text(
                  item.time,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

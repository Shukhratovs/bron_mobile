import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/language/language_cubit.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/notification_item_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/constants/app_assets.dart';

class NotificationsScreen extends StatefulWidget {
  final ProfileRepository? repository;

  const NotificationsScreen({
    super.key,
    this.repository,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final ProfileRepository _repository;
  List<NotificationItemEntity> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        ProfileRepositoryImpl(
          remoteDataSource: ProfileRemoteDataSourceImpl(apiClient: AppSession.apiClient),
        );
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final result = await _repository.getNotifications();
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        setState(() {
          _notifications = data;
          _isLoading = false;
        });
      case Failure():
        setState(() {
          _notifications = [];
          _isLoading = false;
        });
    }
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) {
        return NotificationItemEntity(
          id: n.id,
          title: n.title,
          message: n.message,
          time: n.time,
          type: n.type,
          isRead: true,
        );
      }).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Barcha bildirishnomalar o\'qildi deb belgilandi'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const AppIcon(AppAssets.iconArrowLeftLine, color: Color(0xFF181A20)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppStrings.notifications,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF181A20),
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: _markAllAsRead,
            icon: const Icon(
              Icons.done_all_rounded,
              size: 16,
              color: Color(0xFFE53935),
            ),
            label: Text(
              AppStrings.markAllAsRead,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE53935),
              ),
            ),
          ),
          Gap(6.w),
        ],
      ),
      body: _isLoading
          ? Padding(padding: EdgeInsets.all(16.w), child: const ListRowSkeletonGroup(count: 5, leadingIsCircle: true))
          : _notifications.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppIcon(AppAssets.iconNotification, size: 56.r, color: const Color(0xFF9CA3AF)),
                        Gap(12.h),
                        Text(
                          AppStrings.noNotifications,
                          style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, color: const Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                  itemCount: _notifications.length,
                  separatorBuilder: (context, index) => Gap(10.h),
                  itemBuilder: (context, index) {
                    final item = _notifications[index];
                    return _buildNotificationCard(item);
                  },
                ),
    );
      },
    );
  }

  Widget _buildNotificationCard(NotificationItemEntity item) {
    final IconData icon;
    final Color iconColor;
    final Color iconBg;

    switch (item.type) {
      case NotificationType.booking:
        icon = Icons.calendar_month_outlined;
        iconColor = const Color(0xFFE53935);
        iconBg = const Color(0xFFFEE2E2).withValues(alpha: 0.6);
      case NotificationType.bonus:
        icon = Icons.credit_card_outlined;
        iconColor = const Color(0xFF6B7280);
        iconBg = const Color(0xFFF3F4F6);
      case NotificationType.promo:
      case NotificationType.system:
        icon = Icons.star_rounded;
        iconColor = const Color(0xFF6B7280);
        iconBg = const Color(0xFFF3F4F6);
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFECEFF3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20.r, color: iconColor),
          ),
          Gap(12.w),
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
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF181A20),
                        ),
                      ),
                    ),
                    Text(
                      item.time,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                Gap(4.h),
                Text(
                  item.message,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                    height: 1.35,
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

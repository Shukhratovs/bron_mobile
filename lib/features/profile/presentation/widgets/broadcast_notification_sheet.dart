import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

/// Faqat admin telefon raqami uchun ko'rinadigan panel — barcha
/// qurilmalarga (FCM `all_devices` topic'i orqali) push yuborish uchun
/// sarlavha va matn kiritiladi.
class BroadcastNotificationSheet extends StatefulWidget {
  final Future<void> Function(String title, String body, String adminSecret) onSend;

  const BroadcastNotificationSheet({super.key, required this.onSend});

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function(String title, String body, String adminSecret) onSend,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BroadcastNotificationSheet(onSend: onSend),
    );
  }

  @override
  State<BroadcastNotificationSheet> createState() => _BroadcastNotificationSheetState();
}

class _BroadcastNotificationSheetState extends State<BroadcastNotificationSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _secretController = TextEditingController();
  bool _sending = false;
  bool _obscureSecret = true;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  Future<void> _onSendPressed() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final secret = _secretController.text.trim();
    if (title.isEmpty || body.isEmpty || secret.isEmpty || _sending) return;

    setState(() => _sending = true);
    await widget.onSend(title, body, secret);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Gap(20.h),
              Text(
                'Barchaga bildirishnoma',
                style: GoogleFonts.unbounded(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Gap(4.h),
              Text(
                'Bu xabar ilovadan foydalanadigan barcha qurilmalarga yuboriladi.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              Gap(20.h),
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Sarlavha',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
              ),
              Gap(14.h),
              TextField(
                controller: _bodyController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Matn',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
              ),
              Gap(14.h),
              TextField(
                controller: _secretController,
                obscureText: _obscureSecret,
                decoration: InputDecoration(
                  labelText: 'Admin kaliti',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureSecret ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscureSecret = !_obscureSecret),
                  ),
                ),
              ),
              Gap(20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sending ? null : _onSendPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: Size(double.infinity, 50.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: _sending
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Yuborish',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

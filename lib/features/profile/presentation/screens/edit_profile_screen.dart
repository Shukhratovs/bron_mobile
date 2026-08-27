import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfileEntity user;
  final ProfileRepository repository;

  const EditProfileScreen({
    super.key,
    required this.user,
    required this.repository,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _birthDateController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _birthDateController = TextEditingController(
      text: widget.user.birthDate != null && widget.user.birthDate!.isNotEmpty
          ? widget.user.birthDate!
          : '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1996, 8, 15),
      firstDate: DateTime(1940),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      final year = picked.year.toString();
      setState(() {
        _birthDateController.text = '$day.$month.$year';
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    final updated = widget.user.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      birthDate: _birthDateController.text.trim(),
    );

    final result = await widget.repository.updateProfile(updated);

    if (!mounted) return;
    setState(() => _isSaving = false);

    switch (result) {
      case Success(:final data):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.profileUpdatedSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(data);
      case Failure(:final exception):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exception.message),
            backgroundColor: AppColors.error,
          ),
        );
    }
  }

  String _formatPhoneSuffix(String fullPhone) {
    var cleaned = fullPhone.replaceAll('+998', '').trim();
    if (cleaned.isEmpty) return '90 123-45-67';
    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    final avatarPath = widget.user.avatarUrl ?? AppAssets.me;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF181A20)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Profilni tahrirlash',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF181A20),
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // 1. Avatar with Green Status Dot and Change Photo link
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 90.r,
                                height: 90.r,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFF3F4F6),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    avatarPath,
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.high,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: AppColors.primarySoft,
                                      child: Icon(
                                        Icons.person_rounded,
                                        size: 48.r,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 2.w,
                                bottom: 4.h,
                                child: Container(
                                  width: 16.r,
                                  height: 16.r,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Gap(12.h),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Rasm tanlash oynasi ochilmoqda...'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            },
                            child: Text(
                              "Rasmni o'zgartirish",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap(24.h),

                    // 2. Ism
                    _buildFieldLabel('Ism'),
                    Gap(6.h),
                    _buildTextInput(
                      controller: _firstNameController,
                      prefixIcon: Icons.person_outline_rounded,
                      hintText: 'Ismingizni kiriting',
                    ),
                    Gap(16.h),

                    // 3. Familiya
                    _buildFieldLabel('Familiya'),
                    Gap(6.h),
                    _buildTextInput(
                      controller: _lastNameController,
                      prefixIcon: Icons.person_outline_rounded,
                      hintText: 'Familiyangizni kiriting',
                    ),
                    Gap(16.h),

                    // 4. Telefon (Disabled / Protected)
                    _buildFieldLabel('Telefon'),
                    Gap(6.h),
                    Container(
                      height: 52.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: const Color(0xFFECEFF3)),
                      ),
                      child: Row(
                        children: [
                          Gap(14.w),
                          // Uzbekistan Flag Mini Badge
                          Container(
                            width: 20.r,
                            height: 20.r,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Column(
                                children: [
                                  Expanded(child: Container(color: const Color(0xFF0099B5))),
                                  Container(height: 0.8, color: const Color(0xFFD62612)),
                                  Expanded(child: Container(color: Colors.white)),
                                  Container(height: 0.8, color: const Color(0xFFD62612)),
                                  Expanded(child: Container(color: const Color(0xFF1EB53A))),
                                ],
                              ),
                            ),
                          ),
                          Gap(6.w),
                          Text(
                            '+998',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF8E8E93),
                            ),
                          ),
                          Gap(2.w),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18.r,
                            color: const Color(0xFF8E8E93),
                          ),
                          Gap(10.w),
                          Container(
                            width: 1,
                            height: 26.h,
                            color: const Color(0xFFE5E7EB),
                          ),
                          Gap(14.w),
                          Expanded(
                            child: Text(
                              _formatPhoneSuffix(widget.user.phoneNumber),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF8E8E93),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap(6.h),
                    Text(
                      "Raqamni o'zgartirish uchun qo'llab-quvvatlashga murojaat qiling",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                    Gap(16.h),

                    // 5. Tug'ilgan kun
                    _buildFieldLabel("Tug'ilgan kun"),
                    Gap(6.h),
                    GestureDetector(
                      onTap: _selectBirthDate,
                      child: Container(
                        height: 52.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: const Color(0xFFECEFF3)),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 20.r,
                              color: const Color(0xFF8E8E93),
                            ),
                            Gap(12.w),
                            Expanded(
                              child: Text(
                                _birthDateController.text.isNotEmpty
                                    ? _birthDateController.text
                                    : 'KK / OO / YYYY',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.5.sp,
                                  fontWeight: _birthDateController.text.isNotEmpty
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                  color: _birthDateController.text.isNotEmpty
                                      ? AppColors.textPrimary
                                      : const Color(0xFFC7C7CC),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Gap(6.h),
                    Text(
                      "Tug'ilgan kuningizda restoranlardan bonus olasiz",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                    Gap(24.h),
                  ],
                ),
              ),
            ),

            // Bottom Save Button
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: 22.r,
                          height: 22.r,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Saqlash',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
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

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF181A20),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required IconData prefixIcon,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      cursorColor: AppColors.primary,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF181A20),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14.5.sp,
          color: const Color(0xFFC7C7CC),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(
          prefixIcon,
          size: 20.r,
          color: const Color(0xFF8E8E93),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFFECEFF3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFFECEFF3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

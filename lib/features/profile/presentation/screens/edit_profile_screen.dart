import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/widgets/custom_app_bar.dart';
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
  late final TextEditingController _phoneController;
  late final TextEditingController _birthDateController;
  late String _selectedGender;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _birthDateController = TextEditingController(text: widget.user.birthDate ?? '15.08.1996');
    _selectedGender = widget.user.gender ?? AppStrings.genderMale;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    final updated = widget.user.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      birthDate: _birthDateController.text.trim(),
      gender: _selectedGender,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: AppStrings.editProfile,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with change photo button
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 88.r,
                      height: 88.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(44.r),
                        child: Image.asset(
                          widget.user.avatarUrl ?? AppAssets.me,
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
                    Gap(8.h),
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
                        AppStrings.changePhoto,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Gap(24.h),

              // Form fields
              _buildInputField(
                label: AppStrings.firstName,
                controller: _firstNameController,
                icon: Icons.person_outline_rounded,
              ),
              Gap(16.h),
              _buildInputField(
                label: AppStrings.lastName,
                controller: _lastNameController,
                icon: Icons.person_outline_rounded,
              ),
              Gap(16.h),

              // Gender Selector
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppStrings.gender,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Gap(8.h),
              Row(
                children: [
                  Expanded(
                    child: _buildGenderOption(AppStrings.genderMale),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: _buildGenderOption(AppStrings.genderFemale),
                  ),
                ],
              ),
              Gap(16.h),

              _buildInputField(
                label: AppStrings.birthDate,
                controller: _birthDateController,
                icon: Icons.calendar_today_outlined,
              ),
              Gap(16.h),

              _buildInputField(
                label: AppStrings.phoneNumber,
                controller: _phoneController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                readOnly: true,
                helperText: 'Telefon raqam o\'zgartirilmaydi',
              ),
              Gap(32.h),

              // Save Button
              ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
                    ? SizedBox(
                        width: 22.r,
                        height: 22.r,
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(AppStrings.saveChanges),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        Gap(6.h),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly ? AppColors.backgroundLight : AppColors.surfaceLight,
            helperText: helperText,
            helperStyle: GoogleFonts.plusJakartaSans(fontSize: 11.sp, color: AppColors.textMuted),
            prefixIcon: Icon(icon, size: 20.r, color: AppColors.textMuted),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            gender,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

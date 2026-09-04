import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/language/language_cubit.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../../../core/network/auth_local_storage.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../../core/widgets/app_avatar_image.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_toast.dart';
import '../widgets/photo_source_sheet.dart';

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
  late String _avatarPath;
  bool _isSaving = false;

  bool get _hasCustomAvatar => !_avatarPath.startsWith('assets/');

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
    _avatarPath = widget.user.avatarUrl ?? AppAssets.me;
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

  Future<void> _changePhoto() async {
    final action = await PhotoSourceSheet.show(context, canRemove: _hasCustomAvatar);
    if (action == null || !mounted) return;

    if (action == PhotoSourceAction.remove) {
      setState(() => _avatarPath = AppAssets.me);
      return;
    }

    try {
      final picked = await ImagePicker().pickImage(
        source: action == PhotoSourceAction.camera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked == null || !mounted) return;

      final savedPath = await _copyToPermanentStorage(picked.path);
      if (!mounted) return;
      setState(() => _avatarPath = savedPath);
    } catch (_) {
      if (mounted) AppToast.error(context, AppStrings.imagePickFailed);
    }
  }

  /// `image_picker` vaqtinchalik keshga (`cache/`) qaytaradi — OS uni
  /// istalgan payt tozalashi mumkin. Ilova qayta ochilganda ham rasm
  /// ko'rinishi uchun doimiy hujjatlar papkasiga, sobit nom bilan
  /// nusxalanadi (qayta tanlansa avvalgisi ustidan yoziladi).
  Future<String> _copyToPermanentStorage(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final ext = sourcePath.contains('.') ? sourcePath.split('.').last : 'jpg';
    final destPath = '${dir.path}/profile_avatar.$ext';
    final copied = await File(sourcePath).copy(destPath);
    return copied.path;
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    final updated = widget.user.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      birthDate: _birthDateController.text.trim(),
      avatarUrl: _avatarPath,
    );

    final result = await widget.repository.updateProfile(updated);

    if (!mounted) return;
    setState(() => _isSaving = false);

    switch (result) {
      case Success(:final data):
        // Backend'da avatar maydoni yo'q — server javobidagi
        // `avatarUrl` doim standart bo'ladi, shuning uchun mahalliy
        // tanlangan rasmni shu yerda qayta qo'shamiz va qurilmada
        // saqlaymiz (ProfileRepositoryImpl.getUserProfile() keyingi
        // yuklashlarda shu qiymatni o'qiydi).
        final storage = AppSession.authLocalStorage;
        if (storage is AuthLocalStorageImpl) {
          if (_hasCustomAvatar) {
            await storage.saveLocalAvatarPath(_avatarPath);
          } else {
            await storage.clearLocalAvatarPath();
          }
        }
        if (!mounted) return;
        AppToast.success(context, AppStrings.profileUpdatedSuccess);
        Navigator.of(context).pop(data.copyWith(avatarUrl: _avatarPath));
      case Failure(:final exception):
        AppToast.error(context, exception.message);
    }
  }

  String _formatPhoneSuffix(String fullPhone) {
    var cleaned = fullPhone.replaceAll('+998', '').trim();
    if (cleaned.isEmpty) return '90 123-45-67';
    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
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
            icon: const AppIcon(AppAssets.iconArrowLeftLine, color: Color(0xFF181A20)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            AppStrings.editProfile,
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
                                child: AppAvatarImage(
                                  avatarPath: _avatarPath,
                                  size: 90.r,
                                  fallback: Container(
                                    color: AppColors.primarySoft,
                                    child: Icon(
                                      Icons.person_rounded,
                                      size: 48.r,
                                      color: AppColors.primary,
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
                            onTap: _changePhoto,
                            child: Text(
                              AppStrings.changePhoto,
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
                    _buildFieldLabel(AppStrings.firstName),
                    Gap(6.h),
                    _buildTextInput(
                      controller: _firstNameController,
                      prefixIcon: Icons.person_outline_rounded,
                      hintText: AppStrings.firstNameHint,
                    ),
                    Gap(16.h),

                    // 3. Familiya
                    _buildFieldLabel(AppStrings.lastName),
                    Gap(6.h),
                    _buildTextInput(
                      controller: _lastNameController,
                      prefixIcon: Icons.person_outline_rounded,
                      hintText: AppStrings.lastNameHint,
                    ),
                    Gap(16.h),

                    // 4. Telefon (Disabled / Protected)
                    _buildFieldLabel(AppStrings.phoneNumber),
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
                      AppStrings.phoneChangeNote,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                    Gap(16.h),

                    // 5. Tug'ilgan kun
                    _buildFieldLabel(AppStrings.birthDate),
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
                                    : AppStrings.birthDatePlaceholder,
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
                      AppStrings.birthDateBonusNote,
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
                          AppStrings.saveChanges,
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
      },
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

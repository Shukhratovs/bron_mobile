import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/repositories/profile_repository.dart';

class BecomePartnerScreen extends StatefulWidget {
  final ProfileRepository repository;

  const BecomePartnerScreen({
    super.key,
    required this.repository,
  });

  @override
  State<BecomePartnerScreen> createState() => _BecomePartnerScreenState();
}

class _BecomePartnerScreenState extends State<BecomePartnerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedCategory = 'Restoran / Kafe';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Restoran / Kafe',
    'Geym klub (PlayStation/PC)',
    'Sartaroshxona / Barbershop',
    'Go\'zallik saloni',
    'Sport maydoni (Futbol/Tennis)',
    'Kovorking markazi',
  ];

  @override
  void dispose() {
    _businessNameController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final result = await widget.repository.submitPartnerApplication(
      businessName: _businessNameController.text.trim(),
      category: _selectedCategory,
      contactPerson: _contactPersonController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case Success():
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64.r,
                    height: 64.r,
                    decoration: const BoxDecoration(
                      color: AppColors.successSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_circle_rounded, size: 36.r, color: AppColors.success),
                  ),
                  Gap(16.h),
                  Text(
                    'Ariza qabul qilindi!',
                    style: GoogleFonts.unbounded(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Gap(8.h),
                  Text(
                    AppStrings.applicationSuccess,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  Gap(20.h),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Tushunarli'),
                  ),
                ],
              ),
            ),
          ),
        );
      case Failure(:final exception):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(exception.message), backgroundColor: AppColors.error),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: AppStrings.becomePartner,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner
            Container(
              height: 160.h,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF1E2024),
                image: DecorationImage(
                  image: AssetImage(AppAssets.partnerBack),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  alignment: Alignment.center,
                ),
              ),
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    AppStrings.partnerTitle,
                    style: GoogleFonts.unbounded(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ),
            ),

            // Form
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.partnerDesc,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    Gap(20.h),

                    _buildField(
                      label: AppStrings.businessName,
                      controller: _businessNameController,
                      hint: 'Masalan: Osteria Restoran',
                      icon: Icons.storefront_rounded,
                    ),
                    Gap(16.h),

                    // Category Dropdown
                    Text(
                      AppStrings.businessCategory,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Gap(6.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary),
                          items: _categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(
                                cat,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategory = val);
                          },
                        ),
                      ),
                    ),
                    Gap(16.h),

                    _buildField(
                      label: AppStrings.contactPerson,
                      controller: _contactPersonController,
                      hint: 'Ism va familiyangiz',
                      icon: Icons.person_outline_rounded,
                    ),
                    Gap(16.h),

                    _buildField(
                      label: AppStrings.phoneNumber,
                      controller: _phoneController,
                      hint: '+998 90 123 45 67',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    Gap(16.h),

                    _buildField(
                      label: AppStrings.cityAddress,
                      controller: _addressController,
                      hint: 'Toshkent sh., Chilonzor tumani...',
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                    Gap(28.h),

                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? SizedBox(
                              width: 22.r,
                              height: 22.r,
                              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text(AppStrings.submitApplication),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: (val) => (val == null || val.isEmpty) ? 'Ushbu maydon to\'ldirilishi shart' : null,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceLight,
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14.sp, color: AppColors.textMuted),
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
}

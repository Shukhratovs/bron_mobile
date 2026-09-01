import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/utils/uz_phone_formatter.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../../core/widgets/app_icon.dart';

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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedCategory = 'Restoran';
  bool _isSubmitting = false;

  final List<String> _row1Categories = [
    'Restoran',
    'Geym klub',
    'Sartaroshxona',
  ];

  final List<String> _row2Categories = [
    'Go\'zallik',
    'Boshqa',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  Future<void> _submitApplication() async {
    _unfocus();

    if (_businessNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iltimos, biznes nomini kiriting'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final phone = uzPhoneToE164(_phoneController.text.trim());
    if (phone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telefon raqamini to\'liq kiriting')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await widget.repository.submitPartnerApplication(
      businessName: _businessNameController.text.trim(),
      category: _selectedCategory,
      contactPerson: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : 'Aziz Karimov',
      phone: phone,
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : 'Toshkent shahar',
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
                    width: 60.r,
                    height: 60.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD1FAE5),
                      shape: BoxShape.circle,
                    ),
                    child: AppIcon(AppAssets.iconCheckboxCircleFill, size: 36.r, color: AppColors.success),
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
                    'Menejerimiz tez orada siz bilan bog\'lanadi va tizimga ulanishda yordam beradi.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5.sp,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  Gap(20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'Tushunarli',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
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
      case Failure(:final exception):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(exception.message), backgroundColor: AppColors.error),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _unfocus,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Dark Header with Rounded Bottom Edge & Amber Beam Graphic
                    Container(
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: const Color(0xFF141211),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(28.r),
                        ),
                        image: const DecorationImage(
                          image: AssetImage(AppAssets.partnerBack),
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          alignment: Alignment.topRight,
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 24.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Back button
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  width: 38.r,
                                  height: 38.r,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.14),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                      size: 20.r,
                                    ),
                                  ),
                                ),
                              ),
                              Gap(16.h),

                              // Title: "Biznesingizni Bron'ga ulang"
                              Text(
                                'Biznesingizni Bron\'ga ulang',
                                style: GoogleFonts.unbounded(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.4,
                                  height: 1.22,
                                ),
                              ),
                              Gap(8.h),

                              // Subtitle
                              Text(
                                'Mijozlar sizni bir tegishda band qiladi,\nqo\'ng\'iroqsiz, navbatsiz.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  height: 1.45,
                                ),
                              ),
                              Gap(18.h),

                              // Category Circle Chips Row (🍽️, 🎮, ✂️, ✨)
                              Row(
                                children: [
                                  _buildCircleCategoryIcon(AppAssets.iconRestaurant),
                                  Gap(10.w),
                                  _buildCircleCategoryIcon(AppAssets.iconGym),
                                  Gap(10.w),
                                  _buildCircleCategoryIcon(AppAssets.iconBarber),
                                  Gap(10.w),
                                  _buildCircleCategoryIcon(AppAssets.iconBeauty),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Gap(16.h),

                    // Main Content Padding
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Key Value Props (Benefits Card)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: const Color(0xFFECEFF3)),
                            ),
                            child: Column(
                              children: [
                                _buildBenefitItem(
                                  icon: Icons.event_available_outlined,
                                  title: 'Bo\'sh vaqtlarni to\'ldiring',
                                  subtitle: 'Mijoz real bo\'sh slotni ko\'radi va darhol band qiladi',
                                ),
                                Gap(14.h),
                                _buildBenefitItem(
                                  icon: Icons.person_outline_rounded,
                                  title: 'No-show kamayadi',
                                  subtitle: 'Depozit va eslatmalar kelmaslikni qisqartiradi',
                                ),
                                Gap(14.h),
                                _buildBenefitItem(
                                  icon: Icons.credit_card_outlined,
                                  title: 'To\'lov faqat natijaga',
                                  subtitle: 'Mehmon kelgani uchun komissiya — oylik to\'lov yo\'q',
                                ),
                              ],
                            ),
                          ),
                          Gap(20.h),

                          // ARIZA Header
                          Text(
                            'ARIZA',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF8E8E93),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Gap(10.h),

                          // Application Form Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: const Color(0xFFECEFF3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. Ismingiz
                                _buildInputLabel('Ismingiz'),
                                Gap(6.h),
                                _buildTextInput(
                                  controller: _nameController,
                                  hintText: 'Masalan: Aziz Karimov',
                                  prefixIcon: Icons.person_outline_rounded,
                                ),
                                Gap(16.h),

                                // 2. Biznes nomi
                                _buildInputLabel('Biznes nomi'),
                                Gap(6.h),
                                _buildTextInput(
                                  controller: _businessNameController,
                                  hintText: 'Masalan: Osteria Da Vinci',
                                  prefixIcon: Icons.storefront_outlined,
                                ),
                                Gap(16.h),

                                // 3. Yo'nalish
                                _buildInputLabel('Yo\'nalish'),
                                Gap(8.h),
                                Row(
                                  children: _row1Categories.map((cat) {
                                    return Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          right: cat != _row1Categories.last ? 8.w : 0,
                                        ),
                                        child: _buildCategoryChip(cat),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                Gap(8.h),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: _buildCategoryChip(_row2Categories[0]),
                                    ),
                                    Gap(8.w),
                                    Expanded(
                                      flex: 2,
                                      child: _buildCategoryChip(_row2Categories[1]),
                                    ),
                                    const Spacer(flex: 2),
                                  ],
                                ),
                                Gap(16.h),

                                // 4. Manzil
                                _buildInputLabel('Manzil'),
                                Gap(6.h),
                                _buildTextInput(
                                  controller: _addressController,
                                  hintText: 'Masalan: Bunyodkor ko\'chasi 12',
                                  prefixIcon: Icons.location_on_outlined,
                                ),
                                Gap(8.h),
                                GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Xaritadan joy tanlash ochilmoqda...'),
                                        backgroundColor: AppColors.primary,
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: const Color(0xFFE53935),
                                        size: 16.r,
                                      ),
                                      Gap(6.w),
                                      Text(
                                        'Xaritada nuqta belgilash',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFFE53935),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Gap(16.h),

                                // 5. Telefon
                                _buildInputLabel('Telefon'),
                                Gap(6.h),
                                Container(
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14.r),
                                    border: Border.all(color: const Color(0xFFECEFF3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Gap(12.w),
                                      // 🇺🇿 Flag
                                      Container(
                                        width: 18.r,
                                        height: 18.r,
                                        decoration: const BoxDecoration(shape: BoxShape.circle),
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
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF181A20),
                                        ),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 18.r,
                                        color: const Color(0xFF8E8E93),
                                      ),
                                      Gap(8.w),
                                      Container(width: 1, height: 24.h, color: const Color(0xFFE5E7EB)),
                                      Gap(12.w),
                                      Expanded(
                                        child: TextField(
                                          controller: _phoneController,
                                          keyboardType: TextInputType.phone,
                                          cursorColor: AppColors.primary,
                                          onTapOutside: (_) => _unfocus(),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                            UzPhoneInputFormatter(),
                                          ],
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14.5.sp,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF181A20),
                                          ),
                                          decoration: InputDecoration(
                                            hintText: '(90) 123 45 67',
                                            hintStyle: GoogleFonts.plusJakartaSans(
                                              fontSize: 14.sp,
                                              color: const Color(0xFF8E8E93),
                                            ),
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gap(20.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Ariza yuborish Button
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitApplication,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5222),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                                width: 22.r,
                                height: 22.r,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'Ariza yuborish',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    Gap(8.h),
                    Text(
                      'Menejerimiz bir ish kuni ichida bog\'lanadi',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8E8E93),
                      ),
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

  Widget _buildCategoryChip(String cat) {
    final isSelected = _selectedCategory == cat;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = cat),
      child: Container(
        height: 38.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF181A20) : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            cat,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: const Color(0xFF181A20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleCategoryIcon(String asset) {
    return Container(
      width: 38.r,
      height: 38.r,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AppIcon(
          asset,
          color: Colors.white,
          size: 18.r,
        ),
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36.r,
          height: 36.r,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF1F0),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(icon, size: 18.r, color: const Color(0xFFE53935)),
          ),
        ),
        Gap(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF181A20),
                ),
              ),
              Gap(2.h),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13.5.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF181A20),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
  }) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFECEFF3)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Row(
        children: [
          Icon(prefixIcon, color: const Color(0xFF9CA3AF), size: 20.r),
          Gap(10.w),
          Expanded(
            child: TextField(
              controller: controller,
              cursorColor: AppColors.primary,
              onTapOutside: (_) => _unfocus(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF181A20),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

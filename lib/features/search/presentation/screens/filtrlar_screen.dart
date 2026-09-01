import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../home/domain/venue_filters.dart';
import '../../../venue/venue_kind.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/constants/app_assets.dart';

/// Figma: `Filtrlar` (`61:243`) — mijoz/04-katalog.md.
class FiltrlarScreen extends StatefulWidget {
  final VenueFilters initial;

  const FiltrlarScreen({super.key, this.initial = const VenueFilters()});

  @override
  State<FiltrlarScreen> createState() => _FiltrlarScreenState();
}

class _FiltrlarScreenState extends State<FiltrlarScreen> {
  late VenueFilters _filters;

  static const _checkOptions = [
    ('50_gacha', '50 000 gacha'),
    ('50_150', '50 000 – 150 000'),
    ('150_dan', '150 000 dan yuqori'),
  ];

  static const _ratingOptions = [4.0, 4.5, 4.8];

  static const _sortOptions = [
    ('reyting', 'Reyting bo\'yicha'),
    ('arzon', 'Arzonidan'),
    ('qimmat', 'Qimmatidan'),
    // `yaqin` — joylashuv ruxsati yo'q bo'lganda ko'rsatilmaydi (04-katalog.md §2).
  ];

  @override
  void initState() {
    super.initState();
    _filters = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const AppIcon(AppAssets.iconCloseLine, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Filtrlar',
          style: GoogleFonts.unbounded(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => setState(() => _filters = const VenueFilters()),
            child: Text(
              'Tozalash',
              style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('YO\'NALISH'),
            Gap(10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: venueKindOptions
                  .map((k) => _chip(
                        label: k.$2,
                        selected: _filters.kind == k.$1,
                        onTap: () => setState(() =>
                            _filters = _filters.copyWith(kind: _filters.kind == k.$1 ? null : k.$1, clearKind: _filters.kind == k.$1)),
                      ))
                  .toList(),
            ),
            Gap(20.h),
            _sectionTitle('O\'RTACHA CHEK'),
            Gap(10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _checkOptions
                  .map((c) => _chip(
                        label: c.$2,
                        selected: _filters.check == c.$1,
                        onTap: () => setState(() =>
                            _filters = _filters.copyWith(check: _filters.check == c.$1 ? null : c.$1, clearCheck: _filters.check == c.$1)),
                      ))
                  .toList(),
            ),
            Gap(20.h),
            _sectionTitle('REYTING'),
            Gap(10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _ratingOptions
                  .map((r) => _chip(
                        label: '$r+',
                        selected: _filters.ratingMin == r,
                        onTap: () => setState(() => _filters = _filters.copyWith(
                            ratingMin: _filters.ratingMin == r ? null : r, clearRating: _filters.ratingMin == r)),
                      ))
                  .toList(),
            ),
            Gap(20.h),
            _sectionTitle('SARALASH'),
            Gap(10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _sortOptions
                  .map((s) => _chip(
                        label: s.$2,
                        selected: _filters.sort == s.$1,
                        onTap: () => setState(() =>
                            _filters = _filters.copyWith(sort: _filters.sort == s.$1 ? null : s.$1, clearSort: _filters.sort == s.$1)),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
          child: AppButton.primary(
            text: 'Filtrlarni qo\'llash',
            onPressed: () => Navigator.pop(context, _filters),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      );

  Widget _chip({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: selected ? AppColors.primary : const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.sp,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

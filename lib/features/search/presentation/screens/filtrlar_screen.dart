import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../home/domain/venue_filters.dart';
import '../../../venue/data/datasources/venue_remote_data_source.dart';
import '../../../venue/data/repositories/venue_repository_impl.dart';
import '../../../venue/domain/repositories/venue_repository.dart';

/// Figma: `Filtrlar` (`61:243`) — mijoz/04-katalog.md.
/// Asosiy (Bosh sahifa) ekrandan pastdan chiqadigan varaq sifatida
/// ochiladi. "Qo'llash" tugmasi joriy filtrlarga mos joylar sonini
/// jonli (har o'zgarishda backend'dan) ko'rsatib turadi.
class FiltrlarScreen extends StatefulWidget {
  final VenueFilters initial;
  final String? selectedKind;
  final VenueRepository? repository;

  const FiltrlarScreen({super.key, this.initial = const VenueFilters(), this.selectedKind, this.repository});

  static Future<VenueFilters?> show(
    BuildContext context, {
    VenueFilters initial = const VenueFilters(),
    String? selectedKind,
    VenueRepository? repository,
  }) {
    return showModalBottomSheet<VenueFilters>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => FiltrlarScreen(initial: initial, selectedKind: selectedKind, repository: repository),
    );
  }

  @override
  State<FiltrlarScreen> createState() => _FiltrlarScreenState();
}

class _FiltrlarScreenState extends State<FiltrlarScreen> {
  late VenueFilters _filters;
  late final VenueRepository _repository;
  late final List<DateTime> _next5Days;

  int? _liveCount;
  bool _isCountLoading = true;
  Timer? _debounce;

  static const _timeOptions = ['18:00', '18:30', '19:00', '19:30', '20:00', '20:30', '21:00'];

  List<(String, String)> get _checkOptions => [
        ('50_gacha', AppStrings.checkUpTo50),
        ('50_150', AppStrings.check50To150),
        ('150_dan', AppStrings.checkOver150),
      ];

  static const _ratingOptions = [4.0, 4.5, 4.8];

  List<(String, String)> get _sortOptions => [
        ('yaqin', AppStrings.sortByNearby),
        ('reyting', AppStrings.sortByRating),
        ('arzon', AppStrings.sortByCheapest),
        ('qimmat', AppStrings.sortByExpensive),
      ];

  List<(String, String)> get _cuisineOptions => [
        ('milliy', AppStrings.cuisineNational),
        ('yevropa', AppStrings.cuisineEuropean),
        ('osiyo', AppStrings.cuisineAsian),
        ('fast_food', AppStrings.cuisineFastFood),
        ('kofe', AppStrings.cuisineCoffee),
      ];

  List<(String, String)> get _durationOptions => [
        ('1_soat', AppStrings.duration1Hour),
        ('2_soat', AppStrings.duration2Hours),
        ('3_soat', AppStrings.duration3Hours),
        ('kechgacha', AppStrings.durationUntilClose),
      ];

  bool get _isGameClub => widget.selectedKind == 'geym_klub';

  @override
  void initState() {
    super.initState();
    _filters = widget.initial;
    _repository = widget.repository ??
        VenueRepositoryImpl(remoteDataSource: VenueRemoteDataSourceImpl(apiClient: AppSession.apiClient));
    final today = DateTime.now();
    _next5Days = List.generate(5, (i) => DateTime(today.year, today.month, today.day + i));
    _fetchCount();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _update(VenueFilters Function(VenueFilters current) updater) {
    setState(() => _filters = updater(_filters));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _fetchCount);
  }

  Future<void> _fetchCount() async {
    setState(() => _isCountLoading = true);
    final result = await _repository.getVenues(
      kind: widget.selectedKind,
      cuisine: _filters.cuisine,
      check: _filters.check,
      ratingMin: _filters.ratingMin,
      sort: _filters.sort == 'yaqin' ? null : _filters.sort,
      date: _filters.dateParam,
      guests: _filters.effectiveGuests,
      limit: 50,
    );
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        final count = _filters.hasClientOnlyFilters
            ? data.items.where(_filters.matchesClientSide).length
            : data.total;
        setState(() {
          _liveCount = count;
          _isCountLoading = false;
        });
      case Failure():
        setState(() {
          _liveCount = null;
          _isCountLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Gap(10.h),
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2.r)),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 4.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppStrings.filtersTitle,
                  style: GoogleFonts.unbounded(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _card(
                      title: AppStrings.dateSectionLabel,
                      child: Row(
                        children: _next5Days.asMap().entries.map((e) {
                          final index = e.key;
                          final date = e.value;
                          final isSelected = _filters.date != null && _isSameDay(_filters.date!, date);
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: index != _next5Days.length - 1 ? 6.w : 0),
                              child: _dateChip(date, index, isSelected),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Gap(12.h),
                    _card(
                      title: AppStrings.timeSectionLabel,
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: _timeOptions
                            .map((t) => _chip(
                                  label: t,
                                  selected: _filters.time == t,
                                  onTap: () => _update((f) => f.time == t ? f.copyWith(clearTime: true) : f.copyWith(time: t)),
                                ))
                            .toList(),
                      ),
                    ),
                    Gap(12.h),
                    _card(
                      title: AppStrings.guestsSectionLabel,
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          ...List.generate(8, (i) => i + 1).map((n) => _circleChip(
                                label: '$n',
                                selected: _filters.guests == n,
                                onTap: () => _update((f) => f.guests == n ? f.copyWith(clearGuests: true) : f.copyWith(guests: n)),
                              )),
                          _chip(
                            label: '9–12',
                            selected: _filters.guests == 9,
                            onTap: () => _update((f) => f.guests == 9 ? f.copyWith(clearGuests: true) : f.copyWith(guests: 9)),
                          ),
                          _chip(
                            label: AppStrings.guestBanquetOption,
                            selected: _filters.guests == 13,
                            onTap: () => _update((f) => f.guests == 13 ? f.copyWith(clearGuests: true) : f.copyWith(guests: 13)),
                          ),
                        ],
                      ),
                    ),
                    if (_isGameClub) ...[
                      Gap(12.h),
                      _card(
                        title: '${AppStrings.durationSectionLabel} · ${AppStrings.categoryGeymKlub}',
                        child: Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: _durationOptions
                              .map((d) => _chip(
                                    label: d.$2,
                                    selected: _filters.duration == d.$1,
                                    onTap: () => _update(
                                        (f) => f.duration == d.$1 ? f.copyWith(clearDuration: true) : f.copyWith(duration: d.$1)),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                    Gap(12.h),
                    _card(
                      title: AppStrings.filterSectionSort,
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: _sortOptions
                            .map((s) => _chip(
                                  label: s.$2,
                                  selected: _filters.sort == s.$1,
                                  onTap: () => _update((f) => f.sort == s.$1 ? f.copyWith(clearSort: true) : f.copyWith(sort: s.$1)),
                                ))
                            .toList(),
                      ),
                    ),
                    Gap(12.h),
                    _card(
                      title: AppStrings.cuisineSectionLabel,
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: _cuisineOptions
                            .map((c) => _chip(
                                  label: c.$2,
                                  selected: _filters.cuisine == c.$1,
                                  onTap: () =>
                                      _update((f) => f.cuisine == c.$1 ? f.copyWith(clearCuisine: true) : f.copyWith(cuisine: c.$1)),
                                ))
                            .toList(),
                      ),
                    ),
                    Gap(12.h),
                    _card(
                      title: AppStrings.filterSectionCheck,
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: _checkOptions
                            .map((c) => _chip(
                                  label: c.$2,
                                  selected: _filters.check == c.$1,
                                  onTap: () => _update((f) => f.check == c.$1 ? f.copyWith(clearCheck: true) : f.copyWith(check: c.$1)),
                                ))
                            .toList(),
                      ),
                    ),
                    Gap(12.h),
                    _card(
                      title: AppStrings.filterSectionRating,
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: _ratingOptions
                            .map((r) => _chip(
                                  label: '$r+',
                                  selected: _filters.ratingMin == r,
                                  onTap: () => _update(
                                      (f) => f.ratingMin == r ? f.copyWith(clearRating: true) : f.copyWith(ratingMin: r)),
                                ))
                            .toList(),
                      ),
                    ),
                    Gap(12.h),
                    _card(
                      title: AppStrings.additionalSectionLabel,
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          _chip(
                            label: AppStrings.noDepositOption,
                            selected: _filters.noDeposit,
                            onTap: () => _update((f) => f.copyWith(noDeposit: !f.noDeposit)),
                          ),
                          _chip(
                            label: AppStrings.hasAvailableTableOption,
                            selected: _filters.hasAvailableTable,
                            onTap: () => _update((f) => f.copyWith(hasAvailableTable: !f.hasAvailableTable)),
                          ),
                          _chip(
                            label: '${AppStrings.largeCompanyOption} · 8+',
                            selected: _filters.largeCompany,
                            onTap: () => _update((f) => f.copyWith(largeCompany: !f.largeCompany)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _filters = const VenueFilters());
                        _debounce?.cancel();
                        _fetchCount();
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 52.h),
                        side: const BorderSide(color: AppColors.borderLight),
                        backgroundColor: const Color(0xFFF3F4F6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                      child: Text(
                        AppStrings.clearFilters,
                        style: GoogleFonts.plusJakartaSans(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  Gap(10.w),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: _isCountLoading || _liveCount == null
                          ? AppStrings.applyFilters
                          : AppStrings.applyFiltersWithCount(_liveCount!),
                      backgroundColor: AppColors.textPrimary,
                      textColor: Colors.white,
                      height: 52.h,
                      borderRadius: 16.r,
                      onPressed: () => Navigator.pop(context, _filters),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  String _dayLabel(DateTime date, int index) {
    if (index == 0) return AppStrings.today;
    if (index == 1) return AppStrings.tomorrow;
    return weekdayShort(date);
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          Gap(10.h),
          child,
        ],
      ),
    );
  }

  Widget _dateChip(DateTime date, int index, bool isSelected) {
    return GestureDetector(
      onTap: () => _update((f) => isSelected ? f.copyWith(clearDate: true) : f.copyWith(date: date)),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: isSelected ? AppColors.textPrimary : const Color(0xFFE5E7EB), width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _dayLabel(date, index),
              style: GoogleFonts.plusJakartaSans(fontSize: 11.sp, fontWeight: FontWeight.w500, color: const Color(0xFF9CA3AF)),
            ),
            Gap(2.h),
            Text(
              '${date.day}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.textPrimary : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: selected ? AppColors.textPrimary : const Color(0xFFE5E7EB), width: selected ? 1.5 : 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5.sp,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.textPrimary : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }

  Widget _circleChip({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.r,
        height: 40.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: selected ? AppColors.textPrimary : const Color(0xFFE5E7EB), width: selected ? 1.5 : 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.textPrimary : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}

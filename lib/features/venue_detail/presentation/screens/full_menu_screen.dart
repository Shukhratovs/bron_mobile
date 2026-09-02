import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/language/language_cubit.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../../../core/utils/formatters.dart';
import '../../../venue/data/datasources/venue_remote_data_source.dart';
import '../../../venue/data/models/venue_model.dart';
import '../../../venue/data/repositories/venue_repository_impl.dart';
import '../../../venue/domain/entities/venue_entity.dart';
import '../../../venue/domain/repositories/venue_repository.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';

class FullMenuScreen extends StatefulWidget {
  final String venueId;
  final String venueName;
  final VenueRepository? repository;

  const FullMenuScreen({
    super.key,
    required this.venueId,
    required this.venueName,
    this.repository,
  });

  @override
  State<FullMenuScreen> createState() => _FullMenuScreenState();
}

class _FullMenuScreenState extends State<FullMenuScreen> {
  static const _allCategoryId = '__hammasi__';

  late final VenueRepository _repository;
  VenueMenu? _menu;
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategoryId = _allCategoryId;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        VenueRepositoryImpl(
          remoteDataSource: VenueRemoteDataSourceImpl(apiClient: AppSession.apiClient),
        );
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await _repository.getVenueMenu(widget.venueId);
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        setState(() {
          _menu = data;
          _isLoading = false;
        });
      case Failure(:final exception):
        setState(() {
          _errorMessage = exception.message;
          _isLoading = false;
        });
    }
  }

  List<MenuItemEntity> _sortedItems(List<MenuItemEntity> items) {
    final sorted = [...items];
    sorted.sort((a, b) {
      if (a.isPopular != b.isPopular) return a.isPopular ? -1 : 1;
      return a.name.compareTo(b.name);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const AppIcon(AppAssets.iconArrowLeftSLine, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              AppStrings.fullMenu,
              style: GoogleFonts.unbounded(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              widget.venueName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Padding(padding: EdgeInsets.all(16.w), child: const ListRowSkeletonGroup(count: 6));
    }
    if (_errorMessage != null || _menu == null) {
      return Center(
        child: Text(
          _errorMessage ?? AppStrings.menuNotFound,
          style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: AppColors.textSecondary),
        ),
      );
    }

    final menu = _menu!;
    final categories = [...menu.categories]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final items = _selectedCategoryId == _allCategoryId
        ? menu.items
        : menu.items.where((i) => i.categoryId == _selectedCategoryId).toList();
    final filteredItems = _sortedItems(items);

    return Column(
      children: [
        // Category Filter Tabs
        SizedBox(
          height: 48.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1,
            separatorBuilder: (context, index) => Gap(8.w),
            itemBuilder: (context, index) {
              final id = index == 0 ? _allCategoryId : categories[index - 1].id;
              final label = index == 0 ? AppStrings.menuAll : categories[index - 1].name;
              final isSelected = id == _selectedCategoryId;

              return Center(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategoryId = id),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.textPrimary
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.textPrimary
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Gap(12.h),

        // Menu Items List
        Expanded(
          child: filteredItems.isEmpty
              ? Center(
                  child: Text(
                    AppStrings.menuEmptySection,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: AppColors.textSecondary),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: filteredItems.length,
                  separatorBuilder: (context, index) => Gap(12.h),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];

                    return Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Item icon
                          Container(
                            width: 48.r,
                            height: 48.r,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF2ED),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              item.isPopular ? Icons.local_fire_department_rounded : Icons.restaurant_rounded,
                              color: AppColors.primary,
                              size: 24.r,
                            ),
                          ),
                          Gap(14.w),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (item.description != null) ...[
                                  Gap(4.h),
                                  Text(
                                    item.description!,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                                Gap(6.h),
                                Text(
                                  formatSom(item.price),
                                  style: GoogleFonts.unbounded(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

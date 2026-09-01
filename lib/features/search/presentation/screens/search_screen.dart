import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../../home/presentation/widgets/venue_card_widget.dart';
import '../../../venue/data/datasources/venue_remote_data_source.dart';
import '../../../venue/data/repositories/venue_repository_impl.dart';
import '../../../venue/domain/entities/venue_entity.dart';
import '../../../venue/domain/repositories/venue_repository.dart';
import '../../../venue_detail/presentation/screens/venue_detail_screen.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../home/presentation/widgets/venue_card_skeleton.dart';

class SearchScreen extends StatefulWidget {
  final VenueRepository? repository;

  const SearchScreen({super.key, this.repository});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final VenueRepository _repository;
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  List<VenueEntity> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        VenueRepositoryImpl(remoteDataSource: VenueRemoteDataSourceImpl(apiClient: AppSession.apiClient));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(value.trim()));
  }

  Future<void> _search(String query) async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });
    final result = await _repository.getVenues(q: query, limit: 30);
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        setState(() {
          _results = data.items;
          _isLoading = false;
        });
      case Failure():
        setState(() {
          _results = [];
          _isLoading = false;
        });
    }
  }

  void _openVenue(VenueEntity venue) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => VenueDetailScreen(venueId: venue.id)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
              child: Row(
                children: [
                  IconButton(
                    icon: const AppIcon(AppAssets.iconArrowLeftSLine, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Row(
                        children: [
                          AppIcon(AppAssets.iconSearch, color: AppColors.textSecondary, size: 20.r),
                          Gap(8.w),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              autofocus: true,
                              onChanged: _onChanged,
                              style: GoogleFonts.plusJakartaSans(fontSize: 14.5.sp, color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                hintText: AppStrings.searchPlaceholder,
                                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14.sp, color: AppColors.textHint),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                              ),
                            ),
                          ),
                          if (_controller.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _controller.clear();
                                _onChanged('');
                              },
                              child: AppIcon(AppAssets.iconCloseLine, color: AppColors.textSecondary, size: 18.r),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (!_hasSearched) {
      return Center(
        child: Text(
          'Restoran yoki oshxona nomini yozing',
          style: GoogleFonts.plusJakartaSans(fontSize: 13.5.sp, color: AppColors.textSecondary),
        ),
      );
    }
    if (_isLoading) {
      return Padding(padding: EdgeInsets.all(16.w), child: const VenueListSkeleton());
    }
    if (_results.isEmpty) {
      return Center(
        child: Text(
          'Hech narsa topilmadi',
          style: GoogleFonts.plusJakartaSans(fontSize: 13.5.sp, color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: _results.length,
      separatorBuilder: (context, index) => Gap(16.h),
      itemBuilder: (context, index) {
        final venue = _results[index];
        return VenueCardWidget(venue: venue, onTap: () => _openVenue(venue));
      },
    );
  }
}

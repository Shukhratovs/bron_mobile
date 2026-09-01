import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/language/language_cubit.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/bron_logo.dart';
import '../../data/datasources/onboarding_remote_data_source.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/entities/onboarding_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../../main/presentation/screens/main_navigation_screen.dart';
import '../widgets/onboarding_indicator_widget.dart';
import '../widgets/onboarding_item_widget.dart';

class OnboardingScreen extends StatefulWidget {
  final OnboardingRepository? repository;
  final VoidCallback? onCompleted;

  const OnboardingScreen({
    super.key,
    this.repository,
    this.onCompleted,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingRepository _repository;
  late final PageController _pageController;

  List<OnboardingEntity> _items = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _repository = widget.repository ??
        OnboardingRepositoryImpl(
          remoteDataSource: OnboardingRemoteDataSourceImpl(
            apiClient: AppSession.apiClient,
          ),
        );
    _loadOnboardingData();
  }

  Future<void> _loadOnboardingData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repository.getOnboardingItems();

    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          _items = data;
          _isLoading = false;
        });
      case Failure(:final exception):
        setState(() {
          _errorMessage = exception.message;
          _isLoading = false;
        });
    }
  }

  void _nextPage() {
    if (_currentIndex < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _finishOnboarding();
  }

  void _finishOnboarding() {
    AppSession.markOnboardingSeen();
    if (widget.onCompleted != null) {
      widget.onCompleted!();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainNavigationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
        ),
      );
    }
  }

  void _handleTapUp(TapUpDetails details, double screenWidth) {
    if (details.globalPosition.dx < screenWidth * 0.3) {
      _previousPage();
    } else {
      _nextPage();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
    return _buildScreen(context);
      },
    );
  }

  Widget _buildScreen(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(AppAssets.iconErrorWarningLine, size: 64.r, color: AppColors.error),
                Gap(16.h),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    color: AppColors.textWhite,
                  ),
                ),
                Gap(24.h),
                ElevatedButton(
                  onPressed: _loadOnboardingData,
                  child: Text(AppStrings.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final screenWidth = 1.sw;
    final isLastPage = _currentIndex == _items.length - 1;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Yuqori Story-uslubidagi Progress Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: OnboardingIndicatorWidget(
                count: _items.length,
                currentIndex: _currentIndex,
              ),
            ),

            // 2. Header: Haqiqiy Bron Logo va O'tkazib yuborish tugmasi
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BronLogo(width: 86.w, height: 32.h),
                  GestureDetector(
                    onTap: _skipOnboarding,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
                      child: Text(
                        AppStrings.onboardingSkip,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textWhite,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Markaziy PageView (Rasmlar va Matnlar)
            Expanded(
              child: GestureDetector(
                onTapUp: (details) => _handleTapUp(details, screenWidth),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return OnboardingItemWidget(
                      item: _items[index],
                      isLastPage: index == _items.length - 1,
                    );
                  },
                ),
              ),
            ),

            // 4. Oxirgi sahifada "Boshlash" tugmasi
            if (isLastPage)
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 28.h),
                child: AppButton.white(
                  text: AppStrings.onboardingStart,
                  onPressed: _finishOnboarding,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

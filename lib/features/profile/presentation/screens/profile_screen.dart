import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/language/language_cubit.dart';
import '../../../../core/network/app_session.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../staff/auth/presentation/screens/staff_login_screen.dart';
import '../../../staff/core/staff_session.dart';
import '../../data/datasources/card_remote_data_source.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/card_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/card_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/language_selection_sheet.dart';
import '../widgets/logout_confirmation_sheet.dart';
import '../widgets/profile_bonus_card_widget.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_menu_item_widget.dart';
import 'become_partner_screen.dart';
import 'bonus_screen.dart';
import 'edit_profile_screen.dart';
import 'favorites_screen.dart';
import 'help_faq_screen.dart';
import 'my_cards_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ProfileRepository? repository;
  final AuthRepository? authRepository;
  final CardRepository? cardRepository;

  const ProfileScreen({
    super.key,
    this.repository,
    this.authRepository,
    this.cardRepository,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileBloc _profileBloc;
  late final AuthRepository _authRepository;
  late final ProfileRepository _profileRepository;
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _profileRepository = widget.repository ??
        ProfileRepositoryImpl(
          remoteDataSource: ProfileRemoteDataSourceImpl(
            apiClient: AppSession.apiClient,
          ),
        );
    _authRepository = widget.authRepository ??
        AuthRepositoryImpl(
          remoteDataSource: AuthRemoteDataSourceImpl(apiClient: AppSession.apiClient),
          authLocalStorage: AppSession.authLocalStorage,
        );
    final cardRepository = widget.cardRepository ??
        CardRepositoryImpl(
          remoteDataSource: CardRemoteDataSourceImpl(apiClient: AppSession.apiClient),
        );
    _profileBloc = ProfileBloc(
      profileRepository: _profileRepository,
      cardRepository: cardRepository,
    )..add(const ProfileLoadRequested());
    _loadAppVersion();
  }

  @override
  void dispose() {
    _profileBloc.close();
    super.dispose();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _appVersion = info.version);
      }
    } catch (_) {}
  }

  void _onLoginPressed() async {
    final loggedIn = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => LoginScreen(authRepository: _authRepository),
      ),
    );
    if (loggedIn == true && mounted) {
      _profileBloc.add(const ProfileLoadRequested());
    }
  }

  void _onEditProfile() async {
    final currentUser = _profileBloc.state.user;
    if (currentUser == null) return;
    final updated = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(user: currentUser, repository: _profileRepository),
      ),
    );
    if (updated != null && mounted) {
      _profileBloc.add(ProfileUpdated(updated));
    }
  }

  void _onBonusTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BonusScreen(
          initialBalance: _profileBloc.state.user?.bonusBalance ?? 0,
          repository: _profileRepository,
        ),
      ),
    );
  }

  void _onCardsTap() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MyCardsScreen()),
    );
  }

  void _onFavoritesTap() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
    );
    if (mounted) {
      _profileBloc.add(const ProfileLoadRequested());
    }
  }

  void _onNotificationsTap() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NotificationsScreen(repository: _profileRepository)),
    );
  }

  void _onLanguageTap() async {
    await LanguageSelectionSheet.show(context);
  }

  void _onHelpTap() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HelpFaqScreen()),
    );
  }

  void _onStaffModeTap() async {
    await StaffSession.init();
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StaffLoginScreen()),
    );
  }

  void _onPartnerTap() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BecomePartnerScreen(repository: _profileRepository)),
    );
  }

  void _onLogout() {
    LogoutConfirmationSheet.show(
      context,
      onConfirm: () async {
        _profileBloc.add(const ProfileLogoutRequested());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tizimdan chiqildi'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, langState) {
          return BlocBuilder<ProfileBloc, ProfileState>(
            bloc: _profileBloc,
            builder: (context, state) {
              return Scaffold(
                backgroundColor: AppColors.backgroundLight,
                body: state.status == ProfileStatus.loading
                    ? _buildSkeleton()
                    : _buildBody(state, langState.language),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return SafeArea(
      bottom: false,
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 80.w, height: 28.h, radius: 8),
                    Gap(16.h),
                    Row(
                      children: [
                        ShimmerBox(width: 56.r, height: 56.r, radius: 999),
                        Gap(14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerBox(width: 140.w, height: 18.h),
                              Gap(8.h),
                              ShimmerBox(width: 120.w, height: 14.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Gap(14.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Column(
                children: [
                  ShimmerBox(width: double.infinity, height: 106.h, radius: 18),
                  Gap(14.h),
                  ShimmerBox(width: double.infinity, height: 56.h, radius: 16),
                  Gap(14.h),
                  ShimmerBox(width: double.infinity, height: 280.h, radius: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ProfileState state, AppLanguage currentLang) {
    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.profile,
                    style: GoogleFonts.unbounded(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Gap(16.h),
                  ProfileHeaderWidget(
                    user: state.user,
                    onEditPressed: _onEditProfile,
                    onLoginPressed: _onLoginPressed,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Scrollable content
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _profileBloc.add(const ProfileLoadRequested());
              await _profileBloc.stream.firstWhere(
                (s) => s.status != ProfileStatus.loading,
              );
            },
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
              child: Column(
                children: [
                  ProfileBonusCardWidget(onTap: _onBonusTap),
                  Gap(14.h),

                  // Kartalarim
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: ProfileMenuItemWidget(
                      title: AppStrings.myCards,
                      subtitle: state.cardSubtitle,
                      svgPath: AppAssets.iconBankCardLine,
                      showDivider: false,
                      onTap: _onCardsTap,
                    ),
                  ),
                  Gap(14.h),

                  // Main menu
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        ProfileMenuItemWidget(
                          title: AppStrings.myFavorites,
                          subtitle: state.favoritesCount > 0 ? '${state.favoritesCount} ta' : null,
                          svgPath: AppAssets.iconHeartLine,
                          onTap: _onFavoritesTap,
                        ),
                        ProfileMenuItemWidget(
                          title: AppStrings.notifications,
                          svgPath: AppAssets.iconNotification3Line,
                          onTap: _onNotificationsTap,
                        ),
                        ProfileMenuItemWidget(
                          title: AppStrings.language,
                          subtitle: currentLang.title,
                          svgPath: AppAssets.iconTranslate2,
                          onTap: _onLanguageTap,
                        ),
                        ProfileMenuItemWidget(
                          title: AppStrings.help,
                          svgPath: AppAssets.iconQuestionLine,
                          onTap: _onHelpTap,
                        ),
                        ProfileMenuItemWidget(
                          title: AppStrings.becomePartner,
                          svgPath: AppAssets.iconVerifiedBadgeLine,
                          onTap: _onPartnerTap,
                        ),
                        ProfileMenuItemWidget(
                          title: 'Xostes rejimi',
                          subtitle: 'xodimlar uchun (dev)',
                          svgPath: AppAssets.iconUser3Line,
                          showDivider: false,
                          onTap: _onStaffModeTap,
                        ),
                      ],
                    ),
                  ),
                  Gap(14.h),

                  // Logout
                  if (state.isLoggedIn)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: ProfileMenuItemWidget(
                        title: AppStrings.logoutAccount,
                        svgPath: AppAssets.iconLogoutBoxRLine,
                        isDestructive: true,
                        showDivider: false,
                        onTap: _onLogout,
                      ),
                    ),
                  // Version
                  Center(
                    child: Text(
                      'Bron · versiya $_appVersion',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                  Gap(100.h + MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

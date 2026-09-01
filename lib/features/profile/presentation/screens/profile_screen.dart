import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../staff/auth/presentation/screens/staff_login_screen.dart';
import '../../../staff/core/staff_session.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../widgets/language_selection_sheet.dart';
import '../widgets/logout_confirmation_sheet.dart';
import '../widgets/profile_bonus_card_widget.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_menu_item_widget.dart';
import 'become_partner_screen.dart';
import 'bonus_screen.dart';
import 'edit_profile_screen.dart';
import 'favorites_screen.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import 'help_faq_screen.dart';
import 'my_cards_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ProfileRepository? repository;
  final AuthRepository? authRepository;

  const ProfileScreen({
    super.key,
    this.repository,
    this.authRepository,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileRepository _repository;
  late final AuthRepository _authRepository;
  UserProfileEntity? _user;
  bool _isLoading = true;
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
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
    _loadUserProfile();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = info.version;
        });
      }
    } catch (_) {
      // Fallback
    }
  }

  Future<void> _loadUserProfile() async {
    if (!AppSession.authLocalStorage.isLoggedIn) {
      setState(() {
        _user = null;
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    final result = await _repository.getUserProfile();
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          _user = data;
          _isLoading = false;
        });
      case Failure():
        setState(() => _isLoading = false);
    }
  }

  void _onLoginPressed() async {
    final loggedIn = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => LoginScreen(authRepository: _authRepository),
      ),
    );
    if (loggedIn == true && mounted) {
      _loadUserProfile();
    }
  }

  void _onEditProfile() async {
    if (_user == null) return;
    final updated = await Navigator.of(context).push<UserProfileEntity>(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(user: _user!, repository: _repository),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _user = updated);
    }
  }

  void _onBonusTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BonusScreen(
          initialBalance: _user?.bonusBalance ?? 25000,
          repository: _repository,
        ),
      ),
    );
  }

  void _onCardsTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MyCardsScreen(),
      ),
    );
  }

  void _onFavoritesTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FavoritesScreen(repository: _repository),
      ),
    );
  }

  void _onNotificationsTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationsScreen(repository: _repository),
      ),
    );
  }

  void _onLanguageTap() async {
    await LanguageSelectionSheet.show(context);
    if (mounted) setState(() {});
  }

  void _onHelpTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const HelpFaqScreen(),
      ),
    );
  }

  void _onStaffModeTap() async {
    // Dev qulayligi uchun: Xostes ilovasini alohida qurmasdan
    // (`flutter run -t lib/main_staff.dart`), shu jarayon ichidan
    // sinash. Xostesning o'z sessiyasi (`StaffSession`) mijozdan
    // butunlay mustaqil — token/muassasa alohida saqlanadi.
    await StaffSession.init();
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const StaffLoginScreen(),
      ),
    );
  }

  void _onPartnerTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BecomePartnerScreen(repository: _repository),
      ),
    );
  }

  void _onLogout() {
    LogoutConfirmationSheet.show(
      context,
      onConfirm: () async {
        await _repository.logout();
        await AppSession.authLocalStorage.clear();
        if (!mounted) return;
        setState(() => _user = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tizimdan chiqildi'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: AppStrings.currentLanguageNotifier,
      builder: (context, currentLang, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: _isLoading
              ? Padding(padding: EdgeInsets.all(16.w), child: const ListRowSkeletonGroup(count: 5, leadingIsCircle: true))
              : Column(
                  children: [
                    // 1. Top Header with white background & rounded bottom border
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(24.r),
                        ),
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
                              // "Profil" Title
                              Text(
                                AppStrings.profile,
                                style: GoogleFonts.unbounded(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Gap(16.h),

                              // User Info Row (Avatar + Name/Phone + Tahrirlash)
                              ProfileHeaderWidget(
                                user: _user,
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
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                        child: Column(
                          children: [
                            // 2. BRON PLUS Banner Card
                            ProfileBonusCardWidget(
                              onTap: _onBonusTap,
                            ),
                            Gap(14.h),

                            // 3. Kartalarim (Standalone Card)
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: ProfileMenuItemWidget(
                                title: AppStrings.myCards,
                                subtitle: 'UZCARD •••• 4821',
                                iconData: Icons.credit_card_outlined,
                                showDivider: false,
                                onTap: _onCardsTap,
                              ),
                            ),
                            Gap(14.h),

                            // 4. Main Menu Group (Sevimlilar, Bildirishnomalar, Til, Yordam, Hamkor bo'lish)
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
                                    subtitle: '12 ta',
                                    iconData: Icons.favorite_border_rounded,
                                    onTap: _onFavoritesTap,
                                  ),
                                  ProfileMenuItemWidget(
                                    title: AppStrings.notifications,
                                    iconData: Icons.notifications_none_rounded,
                                    onTap: _onNotificationsTap,
                                  ),
                                  ProfileMenuItemWidget(
                                    title: AppStrings.language,
                                    subtitle: currentLang.title,
                                    iconData: Icons.translate_rounded,
                                    onTap: _onLanguageTap,
                                  ),
                                  ProfileMenuItemWidget(
                                    title: AppStrings.help,
                                    iconData: Icons.help_outline_rounded,
                                    onTap: _onHelpTap,
                                  ),
                                  ProfileMenuItemWidget(
                                    title: AppStrings.becomePartner,
                                    iconData: Icons.verified_outlined,
                                    onTap: _onPartnerTap,
                                  ),
                                  ProfileMenuItemWidget(
                                    title: 'Xostes rejimi',
                                    subtitle: 'xodimlar uchun (dev)',
                                    iconData: Icons.badge_outlined,
                                    showDivider: false,
                                    onTap: _onStaffModeTap,
                                  ),
                                ],
                              ),
                            ),
                            Gap(14.h),

                            // 5. Hisobdan chiqish (Standalone Card)
                            if (_user != null)
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: ProfileMenuItemWidget(
                                  title: AppStrings.logoutAccount,
                                  iconData: Icons.logout_rounded,
                                  isDestructive: true,
                                  showDivider: false,
                                  onTap: _onLogout,
                                ),
                              ),
                            Gap(20.h),

                            // 6. Version Footer (e.g. "Bron · versiya 1.0.0")
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
                            Gap(32.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

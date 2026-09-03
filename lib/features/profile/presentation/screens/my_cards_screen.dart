import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/language/language_cubit.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../../booking/presentation/screens/bind_card_screen.dart';
import '../../data/datasources/card_remote_data_source.dart';
import '../../data/repositories/card_repository_impl.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/repositories/card_repository.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../../core/widgets/app_toast.dart';
import '../widgets/delete_card_dialog.dart';

class MyCardsScreen extends StatefulWidget {
  final CardRepository? repository;

  const MyCardsScreen({super.key, this.repository});

  @override
  State<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen> {
  late final CardRepository _repository;
  List<CardEntity> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ??
        CardRepositoryImpl(
          remoteDataSource: CardRemoteDataSourceImpl(
            apiClient: AppSession.apiClient,
          ),
        );
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final result = await _repository.getCards();
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        setState(() {
          _cards = data;
          _isLoading = false;
        });
      case Failure():
        setState(() => _isLoading = false);
    }
  }

  void _onAddNewCard() async {
    final newCardId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => BindCardScreen(repository: _repository),
      ),
    );

    if (newCardId != null && mounted) {
      _load();
      AppToast.success(context, AppStrings.cardAddedSuccess);
    }
  }

  void _onSetDefault(CardEntity card) async {
    if (card.isDefault) return;
    final result = await _repository.setDefaultCard(card.id);
    if (!mounted) return;
    if (result.isSuccess) _load();
  }

  void _onDelete(CardEntity card) async {
    final confirmed = await DeleteCardDialog.show(
      context,
      maskedPan: card.maskedPan,
    );
    if (!confirmed || !mounted) return;

    final result = await _repository.deleteCard(card.id);
    if (!mounted) return;
    switch (result) {
      case Success():
        _load();
      case Failure(:final exception):
        final message = exception.code == 'card_in_use'
            ? AppStrings.cardInUseError
            : exception.message;
        AppToast.error(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const AppIcon(
                AppAssets.iconArrowLeftLine,
                color: Color(0xFF181A20),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              AppStrings.myCards,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF181A20),
              ),
            ),
            centerTitle: false,
          ),
          body: _isLoading
              ? Padding(
                  padding: EdgeInsets.all(16.w),
                  child: const ListRowSkeletonGroup(count: 3),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 14.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cards Group Container
                      if (_cards.isNotEmpty) ...[
                        Container(
                          // `Clip.antiAlias` — ichidagi InkWell to'lqini (birinchi/
                          // oxirgi qatorda) va Slidable'ning o'chirish paneli shu
                          // konteynerning yumaloq burchagidan tashqariga "kvadrat"
                          // bo'lib chiqib ketmasligi uchun (avval shu joyda chekka
                          // effekti buzilgan edi).
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18.r),
                            border: Border.all(color: const Color(0xFFECEFF3)),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _cards.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFECEFF3),
                            ),
                            itemBuilder: (context, index) {
                              final card = _cards[index];
                              // iOS'dagi kabi: chapga suring — "O'chirish" tugmasi
                              // ochiladi (avvalgi "bosib ushlab turing" o'rniga).
                              return Slidable(
                                key: ValueKey(card.id),
                                endActionPane: ActionPane(
                                  motion: const DrawerMotion(),
                                  extentRatio: 0.26,
                                  children: [
                                    SlidableAction(
                                      onPressed: (_) => _onDelete(card),
                                      backgroundColor: AppColors.error,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete_outline_rounded,
                                      label: AppStrings.delete,
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () => _onSetDefault(card),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 14.h,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.credit_card_outlined,
                                          color: const Color(0xFF6B7280),
                                          size: 22.r,
                                        ),
                                        Gap(14.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    card.cardType.toUpperCase(),
                                                    style:
                                                        GoogleFonts.plusJakartaSans(
                                                          fontSize: 15.sp,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: const Color(
                                                            0xFF181A20,
                                                          ),
                                                        ),
                                                  ),
                                                  if (card.isDefault) ...[
                                                    Gap(8.w),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 7.w,
                                                            vertical: 2.h,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFFDBEAFE,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6.r,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        AppStrings
                                                            .cardDefaultBadge,
                                                        style:
                                                            GoogleFonts.plusJakartaSans(
                                                              fontSize: 10.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color:
                                                                  const Color(
                                                                    0xFF2563EB,
                                                                  ),
                                                              letterSpacing:
                                                                  0.3,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              Gap(4.h),
                                              Text(
                                                card.maskedPan,
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      fontSize: 13.5.sp,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: const Color(
                                                        0xFF6B7280,
                                                      ),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          color: const Color(0xFF9CA3AF),
                                          size: 20.r,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Gap(14.h),
                      ],

                      // Dashed / Outlined "+ Yangi karta qo'shish" button
                      GestureDetector(
                        onTap: _onAddNewCard,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7F5),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: const Color(0xFFFFB29D),
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_rounded,
                                  color: const Color(0xFFE53935),
                                  size: 20.r,
                                ),
                                Gap(6.w),
                                Text(
                                  AppStrings.addNewCard,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFE53935),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Gap(16.h),

                      // Footnote
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          AppStrings.cardFootnote,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF9CA3AF),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

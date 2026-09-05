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
import '../../../../core/utils/auth_guard.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../bookings/data/datasources/booking_remote_data_source.dart';
import '../../../bookings/data/repositories/booking_repository_impl.dart';
import '../../../bookings/domain/repositories/booking_repository.dart';
import '../../../profile/data/datasources/card_remote_data_source.dart';
import '../../../profile/data/repositories/card_repository_impl.dart';
import '../../../profile/domain/entities/card_entity.dart';
import '../../../profile/domain/repositories/card_repository.dart';
import '../../../venue/domain/entities/availability_entity.dart';
import '../../../venue/domain/entities/venue_entity.dart';
import '../../../venue_detail/presentation/screens/slot_band_boldi_screen.dart';
import '../widgets/select_card_sheet.dart';
import 'bind_card_screen.dart';
import 'booking_confirmed_screen.dart';

/// Figma: `Depozit` / "Bronni tasdiqlash" (`35:82`) — bron yaratishdan oldin
/// xulosa (joy, sana/vaqt/mehmonlar), depozit sharti va karta tanlovini
/// ko'rsatadigan tasdiqlash oynasi. `VaqtTanlashScreen`da vaqt tanlangach shu
/// yerga o'tiladi; haqiqiy `createBooking` chaqiruvi shu yerda amalga oshadi.
class BookingConfirmationScreen extends StatefulWidget {
  final VenueEntity venue;
  final DateTime startsAt;
  final int guests;
  final String? zoneId;
  final AvailabilityDeposit deposit;
  final BookingRepository? bookingRepository;
  final CardRepository? cardRepository;

  const BookingConfirmationScreen({
    super.key,
    required this.venue,
    required this.startsAt,
    required this.guests,
    this.zoneId,
    required this.deposit,
    this.bookingRepository,
    this.cardRepository,
  });

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  late final BookingRepository _bookingRepository;
  late final CardRepository _cardRepository;

  List<CardEntity> _cards = [];
  CardEntity? _selectedCard;
  bool _isLoadingCards = true;
  bool _isSubmitting = false;

  bool get _depositRequired => widget.deposit.required;

  int? get _depositAmount =>
      widget.deposit.amount ?? (widget.deposit.perPerson != null ? widget.deposit.perPerson! * widget.guests : null);

  @override
  void initState() {
    super.initState();
    _bookingRepository = widget.bookingRepository ??
        BookingRepositoryImpl(remoteDataSource: BookingRemoteDataSourceImpl(apiClient: AppSession.apiClient));
    _cardRepository = widget.cardRepository ??
        CardRepositoryImpl(remoteDataSource: CardRemoteDataSourceImpl(apiClient: AppSession.apiClient));
    if (_depositRequired) {
      _loadCards();
    } else {
      _isLoadingCards = false;
    }
  }

  Future<void> _loadCards() async {
    setState(() => _isLoadingCards = true);
    final result = await _cardRepository.getCards();
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        setState(() {
          _cards = data;
          _selectedCard = data.isEmpty ? null : data.firstWhere((c) => c.isDefault, orElse: () => data.first);
          _isLoadingCards = false;
        });
      case Failure():
        setState(() => _isLoadingCards = false);
    }
  }

  Future<void> _onCardRowTap() async {
    if (_cards.isEmpty) {
      final newCardId = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => BindCardScreen(repository: _cardRepository)),
      );
      if (newCardId != null) await _loadCards();
      return;
    }
    final result = await SelectCardSheet.show(context, cards: _cards, selectedCardId: _selectedCard?.id);
    if (result == null || !mounted) return;
    if (result == SelectCardSheet.addNewCardSentinel) {
      final newCardId = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => BindCardScreen(repository: _cardRepository)),
      );
      if (newCardId != null) await _loadCards();
    } else {
      setState(() => _selectedCard = _cards.firstWhere((c) => c.id == result, orElse: () => _cards.first));
    }
  }

  Future<void> _confirmBooking({String? cardIdOverride}) async {
    if (!await ensureLoggedIn(context)) return;
    if (!mounted) return;
    setState(() => _isSubmitting = true);
    final cardId = cardIdOverride ?? _selectedCard?.id;

    final result = await _bookingRepository.createBooking(
      venueId: widget.venue.id,
      startsAt: widget.startsAt,
      guests: widget.guests,
      zoneId: widget.zoneId,
      cardId: cardId,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case Success(:final data):
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingConfirmedScreen(
              booking: data,
              venueName: widget.venue.name,
              venueAddress: widget.venue.address,
            ),
          ),
        );
      case Failure(:final exception):
        if (exception.code == 'no_table_available') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SlotBandBoldiScreen(
                venue: widget.venue,
                date: widget.startsAt,
                time: formatTime(widget.startsAt),
                guests: widget.guests,
              ),
            ),
          );
        } else if (exception.code == 'card_required') {
          final newCardId = await Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (_) => BindCardScreen(repository: _cardRepository)),
          );
          if (newCardId != null && mounted) {
            _confirmBooking(cardIdOverride: newCardId);
          }
        } else {
          AppToast.error(context, exception.message);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final canSubmit = !_depositRequired || _selectedCard != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const AppIcon(AppAssets.iconArrowLeftLine, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.confirmBookingTitle,
          style: GoogleFonts.unbounded(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryCard(),
            if (_depositRequired) ...[
              Gap(14.h),
              _cardRow(),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 14.h),
          child: AppButton.primary(
            text: _depositRequired ? AppStrings.blockAndBook : AppStrings.bookNow,
            isLoading: _isSubmitting,
            onPressed: canSubmit ? () => _confirmBooking() : null,
          ),
        ),
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _venueAvatar(),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.venue.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    if (widget.venue.address != null) ...[
                      Gap(2.h),
                      Text(
                        widget.venue.address!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          Gap(16.h),
          Divider(height: 1, thickness: 1, color: AppColors.borderLight),
          Gap(16.h),
          _detailRow(AppStrings.dateSectionLabel, formatDateLong(widget.startsAt)),
          Gap(14.h),
          _detailRow(AppStrings.timeSectionLabel, formatTime(widget.startsAt)),
          Gap(14.h),
          _detailRow(AppStrings.guestsSectionLabel, '${widget.guests} ${AppStrings.persons}'),
          if (_depositRequired) ...[
            Gap(16.h),
            _depositNotice(),
          ],
        ],
      ),
    );
  }

  Widget _venueAvatar() {
    final photoUrl = widget.venue.photoUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 48.r,
        height: 48.r,
        color: AppColors.borderLight,
        child: photoUrl == null || photoUrl.isEmpty
            ? Icon(Icons.storefront_outlined, color: AppColors.textMuted, size: 22.r)
            : Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.storefront_outlined, color: AppColors.textMuted, size: 22.r),
              ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, color: AppColors.textSecondary)),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _depositNotice() {
    final amount = _depositAmount;
    final cancelWindowHours = widget.venue.cancelWindowHours ?? 6;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcon(AppAssets.iconWallet3Line, size: 18.r, color: AppColors.primary),
              Gap(8.w),
              Expanded(
                child: Text(
                  '${AppStrings.deposit}${amount != null ? ' · ${formatSom(amount)}' : ''}',
                  style: GoogleFonts.plusJakartaSans(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
            ],
          ),
          Gap(10.h),
          Text(
            "Bu summa kartangizda bloklanadi — hisobingizdan yechilmaydi. "
            "Restoranda hisobingizga o'tadi. Bronni $cancelWindowHours soat oldin "
            "bekor qilsangiz, blok butunlay olib tashlanadi.",
            style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, color: AppColors.primary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _cardRow() {
    if (_isLoadingCards) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 2, offset: const Offset(0, 1))],
        ),
        child: SizedBox(
          height: 20.h,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(width: 20.r, height: 20.r, child: const CircularProgressIndicator(strokeWidth: 2)),
          ),
        ),
      );
    }
    final card = _selectedCard;
    return GestureDetector(
      onTap: _onCardRowTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 2, offset: const Offset(0, 1))],
        ),
        child: Row(
          children: [
            AppIcon(AppAssets.iconWallet3Line, size: 20.r, color: AppColors.textSecondary),
            Gap(12.w),
            Expanded(
              child: Text(
                card != null ? '${card.cardType.toUpperCase()} ${card.maskedPan}' : AppStrings.noCardLinked,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: card != null ? AppColors.textPrimary : AppColors.textMuted,
                ),
              ),
            ),
            AppIcon(AppAssets.iconArrowRightSLine, size: 20.r, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

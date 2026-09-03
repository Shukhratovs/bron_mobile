import 'package:flutter/foundation.dart';

enum AppLanguage {
  uz('Oʻzbekcha', 'uz', '🇺🇿'),
  ru('Русский', 'ru', '🇷🇺'),
  en('English', 'en', '🇬🇧');

  final String title;
  final String code;
  final String flag;
  const AppLanguage(this.title, this.code, this.flag);
}

class AppStrings {
  AppStrings._();

  static final ValueNotifier<AppLanguage> currentLanguageNotifier =
      ValueNotifier<AppLanguage>(AppLanguage.uz);

  static AppLanguage get currentLanguage => currentLanguageNotifier.value;
  static set currentLanguage(AppLanguage language) {
    currentLanguageNotifier.value = language;
  }

  static const String appName = 'Bron';

  // ==========================================
  // ONBOARDING STRINGS (O'zbek tilida)
  // ==========================================
  static const String onboardingSkip = "O'tkazib yuborish";
  static const String onboardingNext = 'Keyingisi';
  static const String onboardingStart = 'Boshlash';

  // Onboarding Pages Content
  static const String onboardingTitle1 = 'Restoran, geym klub,\nsartaroshxona';
  static const String onboardingDesc1 =
      'Toshkentdagi barcha xizmatlarni\nbitta ilovada bron qiling.';

  static const String onboardingTitle2 = 'Yaqin atrofdagi\nxaritada ko\'ring';
  static const String onboardingDesc2 =
      'Qaysi joy yaqin va bo\'sh —\nbir qarashda bilinadi.';

  static const String onboardingTitle3 = 'Joy va vaqtni\nbelgilang';
  static const String onboardingDesc3 =
      'Boʻsh joylarni tanlang va oʻzingizga\nmos vaqtni band qiling.';

  static const String onboardingTitle4 = 'Mos parametrlar bilan\naniq bron';
  static const String onboardingDesc4 =
      'Mehmonlar soni va qulay vaqtni\nbir necha bosqichda kiriting.';

  static const String onboardingTitle5 = 'QR-kod orqali tezkor\ntasdiqlash';
  static const String onboardingDesc5 =
      'Kelganingizda QR-kodni koʻrsating\nva xizmatdan rohatlaning.';

  // ==========================================
  // MULTI-LANGUAGE APP STRINGS (UZ, RU, EN)
  // ==========================================
  static String tr(String key) {
    final lang = currentLanguage.code;
    return _translations[lang]?[key] ?? _translations['uz']?[key] ?? key;
  }

  // --- Quick Access Getters ---
  // Auth
  static String get login => tr('login');
  static String get register => tr('register');
  static String get loginOrRegister => tr('login_or_register');
  static String get phoneNumber => tr('phone_number');
  static String get enterPhoneNumber => tr('enter_phone_number');
  static String get password => tr('password');
  static String get enterPassword => tr('enter_password');
  static String get forgotPassword => tr('forgot_password');
  static String get verifyOtp => tr('verify_otp');
  static String get otpSentTo => tr('otp_sent_to');
  static String get resendOtp => tr('resend_otp');
  static String get logout => tr('logout');
  static String get deleteAccount => tr('delete_account');

  // Navigation
  static String get navHome => tr('nav_home');
  static String get navMap => tr('nav_map');
  static String get navSearch => tr('nav_search');
  static String get navBookings => tr('nav_bookings');
  static String get navFavorites => tr('nav_favorites');
  static String get navProfile => tr('nav_profile');

  // Profile Menu Items
  static String get profile => tr('profile');
  static String get editProfile => tr('edit_profile');
  static String get myCards => tr('my_cards');
  static String get myFavorites => tr('my_favorites');
  static String get myBookings => tr('my_bookings');
  static String get notifications => tr('notifications');
  static String get language => tr('language');
  static String get help => tr('help');
  static String get darkMode => tr('dark_mode');
  static String get becomePartner => tr('become_partner');
  static String get helpAndSupport => tr('help_and_support');
  static String get privacyPolicy => tr('privacy_policy');
  static String get termsOfService => tr('terms_of_service');
  static String get logoutAccount => tr('logout_account');

  // Bron Plus
  static String get bronPlus => tr('bron_plus');
  static String get bronPlusTitle => tr('bron_plus_title');
  static String get bronPlusDesc => tr('bron_plus_desc');

  // Edit Profile
  static String get firstName => tr('first_name');
  static String get lastName => tr('last_name');
  static String get birthDate => tr('birth_date');
  static String get gender => tr('gender');
  static String get genderMale => tr('gender_male');
  static String get genderFemale => tr('gender_female');
  static String get saveChanges => tr('save_changes');
  static String get changePhoto => tr('change_photo');
  static String get profileUpdatedSuccess => tr('profile_updated_success');

  // Bonus
  static String get bronBonus => tr('bron_bonus');
  static String get bonusCardDesc => tr('bonus_card_desc');
  static String get yourBonusBalance => tr('your_bonus_balance');
  static String get howItWorks => tr('how_it_works');
  static String get bonusStep1 => tr('bonus_step_1');
  static String get bonusStep2 => tr('bonus_step_2');
  static String get bonusStep3 => tr('bonus_step_3');
  static String get bonusStep4 => tr('bonus_step_4');
  static String get bonusHistory => tr('bonus_history');
  static String get bonusEarned => tr('bonus_earned');
  static String get bonusSpent => tr('bonus_spent');

  // Bron Plus screen
  static String get cancelSubscriptionTitle => tr('cancel_subscription_title');
  static String get cancelSubscriptionDesc => tr('cancel_subscription_desc');
  static String get cancelSubscriptionSavingsNote => tr('cancel_subscription_savings_note');
  static String get keepSubscriptionButton => tr('keep_subscription_button');
  static String get confirmCancelSubscription => tr('confirm_cancel_subscription');
  static String get bonusPlusHeaderTitle => tr('bonus_plus_header_title');
  static String get bonusPlusHeaderSubtitle => tr('bonus_plus_header_subtitle');
  static String get benefitPriorityTitle => tr('benefit_priority_title');
  static String get benefitPrioritySubtitle => tr('benefit_priority_subtitle');
  static String get benefitDiscountTitle => tr('benefit_discount_title');
  static String get benefitDiscountSubtitle => tr('benefit_discount_subtitle');
  static String get benefitNoDepositTitle => tr('benefit_no_deposit_title');
  static String get benefitNoDepositSubtitle => tr('benefit_no_deposit_subtitle');
  static String get benefitBirthdayTitle => tr('benefit_birthday_title');
  static String get benefitBirthdaySubtitle => tr('benefit_birthday_subtitle');
  static String get planMonthlyTitle => tr('plan_monthly_title');
  static String get planMonthlySubtitle => tr('plan_monthly_subtitle');
  static String get planYearlyTitle => tr('plan_yearly_title');
  static String get planYearlySubtitle => tr('plan_yearly_subtitle');
  static String get activatePlusMonthly => tr('activate_plus_monthly');
  static String get activatePlusYearly => tr('activate_plus_yearly');
  static String get cancelAnytimeNote => tr('cancel_anytime_note');
  static String get bronPlusActivatedSuccess => tr('bron_plus_activated_success');
  static String get subscriptionCancelledToast => tr('subscription_cancelled_toast');
  static String get subscriptionTitle => tr('subscription_title');
  static String get subscriptionActiveTitle => tr('subscription_active_title');
  static String get subscriptionActiveUntil => tr('subscription_active_until');
  static String get savingsWithPlusLabel => tr('savings_with_plus_label');
  static String get bookingsCountLabel => tr('bookings_count_label');
  static String get activeBenefitsHeader => tr('active_benefits_header');
  static String get cancelSubscriptionButton => tr('cancel_subscription_button');

  // Cards
  static String get bindCardTitle => tr('bind_card_title');
  static String get whyCardNeededTitle => tr('why_card_needed_title');
  static String get whyCardNeededDesc => tr('why_card_needed_desc');
  static String get cardHolderLabel => tr('card_holder_label');
  static String get cardHolderHint => tr('card_holder_hint');
  static String get cardNumberLabel => tr('card_number_label');
  static String get cardExpiryLabel => tr('card_expiry_label');
  static String get cardExpiryHint => tr('card_expiry_hint');
  static String get cardSecurityNote => tr('card_security_note');
  static String get bindCardButton => tr('bind_card_button');
  static String get fillAllFields => tr('fill_all_fields');
  static String get cardDefaultBadge => tr('card_default_badge');
  static String get addNewCard => tr('add_new_card');
  static String get cardFootnote => tr('card_footnote');
  static String get cardAddedSuccess => tr('card_added_success');
  static String get cardInUseError => tr('card_in_use_error');
  static String get deleteCardTitle => tr('delete_card_title');
  static String get deleteCardDesc => tr('delete_card_desc');
  static String get delete => tr('delete');

  // Partner
  static String get partnerTitle => tr('partner_title');
  static String get partnerDesc => tr('partner_desc');
  static String get businessName => tr('business_name');
  static String get businessCategory => tr('business_category');
  static String get contactPerson => tr('contact_person');
  static String get cityAddress => tr('city_address');
  static String get submitApplication => tr('submit_application');
  static String get applicationSuccess => tr('application_success');

  // Bookings
  static String get activeTab => tr('active_tab');
  static String get historyTab => tr('history_tab');
  static String get cancelledTab => tr('cancelled_tab');
  static String get showQrCode => tr('show_qr_code');
  static String get cancelBooking => tr('cancel_booking');
  static String get statusConfirmed => tr('status_confirmed');
  static String get statusPending => tr('status_pending');
  static String get statusCompleted => tr('status_completed');
  static String get statusCancelled => tr('status_cancelled');
  static String get noBookingsFound => tr('no_bookings_found');

  // Favorites
  static String get noFavoritesFound => tr('no_favorites_found');
  static String get bookNow => tr('book_now');

  // Notifications
  static String get noNotifications => tr('no_notifications');
  static String get markAllAsRead => tr('mark_all_as_read');

  // Help & FAQ
  static String get faqTitle => tr('faq_title');
  static String get contactSupport => tr('contact_support');
  static String get telegramBot => tr('telegram_bot');
  static String get callUs => tr('call_us');

  // Home & Search
  static String get cityTashkent => tr('city_tashkent');
  static String get searchPlaceholder => tr('search_placeholder');
  static String get today => tr('today');
  static String get tomorrow => tr('tomorrow');
  static String get personsCount => tr('persons_count');
  static String get nearMe => tr('near_me');
  static String get viewAll => tr('view_all');
  static String get popularPlaces => tr('popular_places');
  static String get recommended => tr('recommended');
  static String get availableToday => tr('available_today');
  static String get collections => tr('collections');
  static String get deposit => tr('deposit');

  // Categories
  static String get categoryRestoran => tr('category_restoran');
  static String get categoryGeymKlub => tr('category_geym_klub');
  static String get categorySartaroshxona => tr('category_sartaroshxona');
  static String get categoryGozallikSaloni => tr('category_gozallik_saloni');

  // Venue Detail
  static String get venueNotFound => tr('venue_not_found');
  static String get popularDishes => tr('popular_dishes');
  static String get fullMenu => tr('full_menu');
  static String get reviews => tr('reviews');
  static String get linkCopied => tr('link_copied');
  static String get perPerson => tr('per_person');

  // Time Selection (Vaqt tanlash)
  static String get selectTime => tr('select_time');
  static String get whichDay => tr('which_day');
  static String get calendar => tr('calendar');
  static String get whichZone => tr('which_zone');
  static String get anyZone => tr('any_zone');
  static String get guestCount => tr('guest_count');
  static String get freeSlots => tr('free_slots');
  static String get selectTimeSlot => tr('select_time_slot');
  static String get continueBooking => tr('continue_booking');
  static String get closedToday => tr('closed_today');
  static String get noFreeSlots => tr('no_free_slots');
  static String get maxTableSeats => tr('max_table_seats');
  static String get depositBlocked => tr('deposit_blocked');

  // Menu
  static String get menuAll => tr('menu_all');
  static String get menuNotFound => tr('menu_not_found');
  static String get menuEmptySection => tr('menu_empty_section');

  // Reviews
  static String get userReviews => tr('user_reviews');
  static String get noReviewsYet => tr('no_reviews_yet');
  static String get reviewCount => tr('review_count');
  static String get venueReply => tr('venue_reply');

  // Slot unavailable
  static String get slotTaken => tr('slot_taken');
  static String get joinWaitlist => tr('join_waitlist');
  static String get chooseAnotherTime => tr('choose_another_time');

  // Waitlist
  static String get waitlistTitle => tr('waitlist_title');
  static String get whatTimeSuits => tr('what_time_suits');
  static String get anyTime => tr('any_time');
  static String get waitlistNote => tr('waitlist_note');
  static String get waitlistSuccess => tr('waitlist_success');
  static String get alreadyInWaitlist => tr('already_in_waitlist');
  static String get partyTooLarge => tr('party_too_large');
  static String get persons => tr('persons');

  // Sheets / Confirmation
  static String get logoutConfirmTitle => tr('logout_confirm_title');
  static String get logoutConfirmDesc => tr('logout_confirm_desc');
  static String get deleteAccountConfirmTitle => tr('delete_account_confirm_title');
  static String get deleteAccountConfirmDesc => tr('delete_account_confirm_desc');
  static String get confirm => tr('confirm');
  static String get cancel => tr('cancel');
  static String get save => tr('save');
  static String get retry => tr('retry');
  static String get noData => tr('no_data');
  static String get version => tr('version');
  static String get selectLanguage => tr('select_language');
  static String get gotIt => tr('got_it');

  // Profile menu extras
  static String get staffModeTitle => tr('staff_mode_title');
  static String get staffModeSubtitle => tr('staff_mode_subtitle');
  static String get loggedOutToast => tr('logged_out_toast');

  // Relative time
  static String get timeNow => tr('time_now');
  static String get timeMinutesShort => tr('time_minutes_short');
  static String get timeHoursShort => tr('time_hours_short');
  static String get timeDaysShort => tr('time_days_short');

  // Favorites extras
  static String get favoritesEmptyHint => tr('favorites_empty_hint');
  static String savedPlacesCount(int count) => '$count ${tr('saved_places_suffix')}';

  // Photo picker sheet
  static String get choosePhotoTitle => tr('choose_photo_title');
  static String get takePhoto => tr('take_photo');
  static String get chooseFromGallery => tr('choose_from_gallery');
  static String get removePhoto => tr('remove_photo');
  static String get imagePickFailed => tr('image_pick_failed');

  // Edit profile extras
  static String get firstNameHint => tr('first_name_hint');
  static String get lastNameHint => tr('last_name_hint');
  static String get phoneChangeNote => tr('phone_change_note');
  static String get birthDatePlaceholder => tr('birth_date_placeholder');
  static String get birthDateBonusNote => tr('birth_date_bonus_note');

  // Become a Partner screen
  static String get partnerConnectTitle => tr('partner_connect_title');
  static String get partnerConnectSubtitle => tr('partner_connect_subtitle');
  static String get benefitFillSlotsTitle => tr('benefit_fill_slots_title');
  static String get benefitFillSlotsSubtitle => tr('benefit_fill_slots_subtitle');
  static String get benefitNoShowTitle => tr('benefit_no_show_title');
  static String get benefitNoShowSubtitle => tr('benefit_no_show_subtitle');
  static String get benefitPayOnResultTitle => tr('benefit_pay_on_result_title');
  static String get benefitPayOnResultSubtitle => tr('benefit_pay_on_result_subtitle');
  static String get applicationSectionHeader => tr('application_section_header');
  static String get yourNameLabel => tr('your_name_label');
  static String get yourNameHint => tr('your_name_hint');
  static String get businessNameHint => tr('business_name_hint');
  static String get categoryLabel => tr('category_label');
  static String get categoryOther => tr('category_other');
  static String get addressLabel => tr('address_label');
  static String get addressHint => tr('address_hint');
  static String get pickOnMapLabel => tr('pick_on_map_label');
  static String get mapPickerOpening => tr('map_picker_opening');
  static String get phoneLabel => tr('phone_label');
  static String get applicationAcceptedTitle => tr('application_accepted_title');
  static String get applicationAcceptedDesc => tr('application_accepted_desc');
  static String get managerContactNote => tr('manager_contact_note');
  static String get enterBusinessNameError => tr('enter_business_name_error');
  static String get enterFullPhoneError => tr('enter_full_phone_error');

  // Card SMS verification
  static String get smsVerifyTitle => tr('sms_verify_title');
  static String get enterSmsCode => tr('enter_sms_code');
  static String smsCodeSentTo(String maskedPan) => '$maskedPan ${tr('sms_code_sent_to_suffix')}';
  static String get smsCodeInvalid => tr('sms_code_invalid');

  // Card declined sheet
  static String get cardDeclinedTitle => tr('card_declined_title');
  static String get cardDeclinedDefaultMessage => tr('card_declined_default_message');
  static String get cardNeverStoredNote => tr('card_never_stored_note');
  static String get selectAnotherCard => tr('select_another_card');

  // Login
  static String get loginViaTelegram => tr('login_via_telegram');

  // Cards extras
  static String get noCardAdded => tr('no_card_added');
  static String get cardGenericLabel => tr('card_generic_label');

  // Filters sheet
  static String get filtersTitle => tr('filters_title');
  static String get clearFilters => tr('clear_filters');
  static String get filterSectionKind => tr('filter_section_kind');
  static String get filterSectionCheck => tr('filter_section_check');
  static String get filterSectionRating => tr('filter_section_rating');
  static String get filterSectionSort => tr('filter_section_sort');
  static String get checkUpTo50 => tr('check_up_to_50');
  static String get check50To150 => tr('check_50_to_150');
  static String get checkOver150 => tr('check_over_150');
  static String get sortByRating => tr('sort_by_rating');
  static String get sortByCheapest => tr('sort_by_cheapest');
  static String get sortByExpensive => tr('sort_by_expensive');
  static String get applyFilters => tr('apply_filters');
  static String applyFiltersWithCount(int count) => '${tr('apply_filters')} — $count ${tr('places_count_suffix')}';
  static String get filterAll => tr('filter_all');
  static String get dateSectionLabel => tr('date_section_label');
  static String get timeSectionLabel => tr('time_section_label');
  static String get guestsSectionLabel => tr('guests_section_label');
  static String get durationSectionLabel => tr('duration_section_label');
  static String get cuisineSectionLabel => tr('cuisine_section_label');
  static String get additionalSectionLabel => tr('additional_section_label');
  static String get guestBanquetOption => tr('guest_banquet_option');
  static String get duration1Hour => tr('duration_1_hour');
  static String get duration2Hours => tr('duration_2_hours');
  static String get duration3Hours => tr('duration_3_hours');
  static String get durationUntilClose => tr('duration_until_close');
  static String get sortByNearby => tr('sort_by_nearby');
  static String get cuisineNational => tr('cuisine_national');
  static String get cuisineEuropean => tr('cuisine_european');
  static String get cuisineAsian => tr('cuisine_asian');
  static String get cuisineFastFood => tr('cuisine_fast_food');
  static String get cuisineCoffee => tr('cuisine_coffee');
  static String get noDepositOption => tr('no_deposit_option');
  static String get hasAvailableTableOption => tr('has_available_table_option');
  static String get largeCompanyOption => tr('large_company_option');
  static String get mapLoadFailed => tr('map_load_failed');

  // Bookings screen extras
  static String get waitlistReadyBadge => tr('waitlist_ready_badge');
  static String get waitlistWaitingBadge => tr('waitlist_waiting_badge');
  static String get leaveQueueAction => tr('leave_queue_action');
  static String get peopleAheadLabel => tr('people_ahead_label');
  static String get estimatedWaitLabel => tr('estimated_wait_label');
  static String get waitMinutesSuffix => tr('wait_minutes_suffix');
  static String get confirmTimerRunningNote => tr('confirm_timer_running_note');
  static String get todaySectionLabel => tr('today_section_label');
  static String get upcomingSectionLabel => tr('upcoming_section_label');
  static String get nextDaysSectionLabel => tr('next_days_section_label');
  static String get pastBookingsSectionLabel => tr('past_bookings_section_label');
  static String get bookingBadgeConfirmed => tr('booking_badge_confirmed');
  static String get bookingBadgePending => tr('booking_badge_pending');
  static String get bookingBadgeArrived => tr('booking_badge_arrived');
  static String get bookingBadgeNoShow => tr('booking_badge_no_show');
  static String get bookingBadgeCancelled => tr('booking_badge_cancelled');
  static String get bookingBadgeCompleted => tr('booking_badge_completed');
  static String get genericVenueName => tr('generic_venue_name');

  // Shared state views (empty / no internet / error)
  static String get noInternetTitle => tr('no_internet_title');
  static String get noInternetDesc => tr('no_internet_desc');
  static String get somethingWentWrong => tr('something_went_wrong');

  // Help & FAQ screen
  static String get faqSectionHeader => tr('faq_section_header');
  static String get faqFooterNote => tr('faq_footer_note');
  static String get telegramSupportSubtitle => tr('telegram_support_subtitle');
  static String get callUsSubtitle => tr('call_us_subtitle');
  static String get telegramOpening => tr('telegram_opening');
  static String get callOpening => tr('call_opening');

  static List<(String question, String answer)> get faqItems => List.generate(
        6,
        (i) => (tr('faq_q${i + 1}'), tr('faq_a${i + 1}')),
      );

  // ==========================================
  // TRANSLATION DICTIONARY
  // ==========================================
  static final Map<String, Map<String, String>> _translations = {
    // --- O'ZBEKCHA ---
    'uz': {
      // Auth & Profile
      'login': 'Kirish',
      'register': "Ro'yxatdan o'tish",
      'login_or_register': "Tizimga kiring yoki ro'yxatdan o'ting",
      'phone_number': 'Telefon raqam',
      'enter_phone_number': 'Telefon raqamingizni kiriting',
      'password': 'Parol',
      'enter_password': 'Parolingizni kiriting',
      'forgot_password': 'Parolni unutdingizmi?',
      'verify_otp': 'Tasdiqlash kodi',
      'otp_sent_to': 'Tasdiqlash kodi raqamingizga yuborildi',
      'resend_otp': 'Kodni qayta yuborish',
      'logout': 'Tizimdan chiqish',
      'delete_account': "Akkauntni o'chirish",

      // Navigation
      'nav_home': 'Asosiy',
      'nav_map': 'Xarita',
      'nav_search': 'Qidiruv',
      'nav_bookings': 'Bronlarim',
      'nav_favorites': 'Sevimlilar',
      'nav_profile': 'Profil',

      // Profile Menu
      'profile': 'Profil',
      'edit_profile': 'Profilni tahrirlash',
      'my_cards': 'Kartalarim',
      'my_favorites': 'Sevimlilar',
      'my_bookings': 'Bronlarim',
      'notifications': 'Bildirishnomalar',
      'language': 'Til',
      'help': 'Yordam',
      'dark_mode': 'Tungi rejim',
      'become_partner': "Hamkor bo'lish",
      'help_and_support': 'Yordam va qo\'llab-quvvatlash',
      'privacy_policy': 'Maxfiylik siyosati',
      'terms_of_service': 'Foydalanish shartlari',
      'logout_account': 'Hisobdan chiqish',

      // Bron Plus
      'bron_plus': 'BRON PLUS',
      'bron_plus_title': 'Pik soatlarda joy kafolati',
      'bron_plus_desc': 'Va har bronda 10% chegirma',

      // Edit Profile
      'first_name': 'Ism',
      'last_name': 'Familiya',
      'birth_date': 'Tug\'ilgan sana',
      'gender': 'Jins',
      'gender_male': 'Erkak',
      'gender_female': 'Ayol',
      'save_changes': 'Saqlash',
      'change_photo': 'Rasmni o\'zgartirish',
      'profile_updated_success': 'Profil muvaffaqiyatli saqlandi',

      // Bonus
      'bron_bonus': 'Bron Bonusi',
      'bonus_card_desc': 'Har bir bron uchun keshbek oling va to\'lovlarda ishlating',
      'your_bonus_balance': 'Sizning balansingiz',
      'how_it_works': 'Qanday ishlaydi?',
      'bonus_step_1': 'Ilova orqali istalgan joyni bron qiling',
      'bonus_step_2': 'Tashrif buyuring va QR-kodni ko\'rsating',
      'bonus_step_3': 'Har bir to\'lovdan hisobingizga keshbek oling',
      'bonus_step_4': 'Keyingi bronlarda bonuslarni chegirma sifatida ishlating',
      'bonus_history': 'Bonuslar tarixi',
      'bonus_earned': 'Kirim',
      'bonus_spent': 'Chiqim',

      // Bron Plus screen
      'cancel_subscription_title': 'Obunani bekor qilasizmi?',
      'cancel_subscription_desc':
          'Plus 25-dekabr 2026 gacha ishlashda davom etadi. Shundan keyin imtiyozlar o\'chadi va avtomatik to\'lov to\'xtaydi.',
      'cancel_subscription_savings_note':
          'Shu yilda Plus bilan 480 000 so\'m tejadingiz — obuna narxidan 90 000 so\'m ko\'p.',
      'keep_subscription_button': 'Yo\'q, obunani qoldiraman',
      'confirm_cancel_subscription': 'Ha, bekor qilaman',
      'bonus_plus_header_title': 'Pik soatlarda ham\nbron kafolati',
      'bonus_plus_header_subtitle': 'Eng band kechalarda ham stol topasiz — va har bronda tejaysiz.',
      'benefit_priority_title': 'Prioritet bron',
      'benefit_priority_subtitle': 'Pik soatlarda joylar avval Plus a\'zolarga ochiladi',
      'benefit_discount_title': 'Har bronda 10% chegirma',
      'benefit_discount_subtitle': 'Hamkor joylarda avtomatik hisoblanadi',
      'benefit_no_deposit_title': 'Depozitsiz bron',
      'benefit_no_deposit_subtitle': 'Kartangizda pul bloklanmaydi',
      'benefit_birthday_title': 'Tug\'ilgan kun sovg\'asi',
      'benefit_birthday_subtitle': 'Hamkor joylardan shaxsiy taklif',
      'plan_monthly_title': '1 oy',
      'plan_monthly_subtitle': 'oyiga, istalgan payt bekor qilinadi',
      'plan_yearly_title': '12 oy',
      'plan_yearly_subtitle': 'oyiga · 390 000 so\'m bir marta',
      'activate_plus_monthly': 'Plus\'ni yoqish · 39 000 so\'m',
      'activate_plus_yearly': 'Plus\'ni yoqish · 390 000 so\'m',
      'cancel_anytime_note': 'Istalgan payt bekor qilasiz. Bekor qilinsa, muddat oxirigacha ishlaydi.',
      'bron_plus_activated_success': 'BRON PLUS muvaffaqiyatli faollashtirildi!',
      'subscription_cancelled_toast': 'Obuna bekor qilindi',
      'subscription_title': 'Obuna',
      'subscription_active_title': 'Obuna faol',
      'subscription_active_until': '25-dekabr 2026 gacha · avtomatik uzaytiriladi',
      'savings_with_plus_label': 'Plus bilan tejadingiz',
      'bookings_count_label': 'bron',
      'active_benefits_header': 'FAOL IMTIYOZLAR',
      'cancel_subscription_button': 'Obunani bekor qilish',

      // Cards
      'bind_card_title': 'Karta biriktirish',
      'why_card_needed_title': 'Nega karta kerak?',
      'why_card_needed_desc':
          'Pik vaqtidagi bronlarda depozit kartada bloklanadi. Hozir hech narsa yechilmaydi va bloklanmaydi — karta faqat saqlanadi.',
      'card_holder_label': 'Karta egasi',
      'card_holder_hint': 'IVANOV IVAN',
      'card_number_label': 'Karta raqami',
      'card_expiry_label': 'Amal muddati',
      'card_expiry_hint': 'OO/YY',
      'card_security_note': 'Karta raqami hech qachon saqlanmaydi. Ma\'lumotlar xavfsiz shifrlanadi. CVV kodi talab etilmaydi.',
      'bind_card_button': 'Kartani biriktirish',
      'fill_all_fields': 'Barcha maydonlarni to\'ldiring',
      'card_default_badge': 'ASOSIY',
      'add_new_card': 'Yangi karta qo\'shish',
      'card_footnote': 'Karta raqami hech qachon saqlanmaydi. Bosib ushlab turing — o\'chirish.',
      'card_added_success': 'Yangi karta muvaffaqiyatli qo\'shildi',
      'card_in_use_error': 'Bu karta faol bron uchun band — bron tugagach o\'chirish mumkin',
      'delete_card_title': 'Kartani o\'chirish',
      'delete_card_desc': 'Bu karta ro\'yxatdan butunlay o\'chiriladi. Buni ortga qaytarib bo\'lmaydi.',
      'delete': 'O\'chirish',

      // Partner
      'partner_title': 'Bizning hamkorimizga aylaning',
      'partner_desc': 'O\'z muassasangizni Bron platformasiga qo\'shing va mijozlar oqimini oshiring.',
      'business_name': 'Muassasa nomi',
      'business_category': 'Faoliyat turi (Kategoriya)',
      'contact_person': 'Mas\'ul shaxs ismi',
      'city_address': 'Shahar va to\'liq manzil',
      'submit_application': 'Ariza yuborish',
      'application_success': 'Arizangiz qabul qilindi! Tez orada mutaxassisimiz bog\'lanadi.',

      // Bookings
      'active_tab': 'Faol',
      'history_tab': 'Tarix',
      'cancelled_tab': 'Bekor qilingan',
      'show_qr_code': 'QR-kodni ko\'rsatish',
      'cancel_booking': 'Bronni bekor qilish',
      'status_confirmed': 'Tasdiqlangan',
      'status_pending': 'Kutilmoqda',
      'status_completed': 'Yakunlangan',
      'status_cancelled': 'Bekor qilingan',
      'no_bookings_found': 'Hozircha hech qanday bron mavjud emas',

      // Favorites
      'no_favorites_found': 'Sevimlilar ro\'yxati bo\'sh',
      'book_now': 'Bron qilish',

      // Notifications
      'no_notifications': 'Xabarnomalar mavjud emas',
      'mark_all_as_read': 'Barchasini o\'qilgan qilish',

      // Help & FAQ
      'faq_title': 'Ko\'p beriladigan savollar',
      'contact_support': 'Biz bilan bog\'lanish',
      'telegram_bot': 'Telegram orqali yozish',
      'call_us': 'Qo\'ng\'iroq qilish',

      // Sheets
      'logout_confirm_title': 'Tizimdan chiqish',
      'logout_confirm_desc': 'Haqiqatan ham hisobingizdan chiqmoqchimisiz?',
      'delete_account_confirm_title': 'Akkauntni o\'chirish',
      'delete_account_confirm_desc': 'Akkauntingiz va barcha ma\'lumotlaringiz butunlay o\'chiriladi. Ushbu amalni ortga qaytarib bo\'lmaydi.',
      'confirm': 'Tasdiqlash',
      'cancel': 'Bekor qilish',
      'save': 'Saqlash',
      'retry': 'Qayta urinish',
      'version': 'Versiya',
      'select_language': 'Tilni tanlash',
      'got_it': 'Tushunarli',

      // Profile menu extras
      'staff_mode_title': 'Xostes rejimi',
      'staff_mode_subtitle': 'xodimlar uchun (dev)',
      'logged_out_toast': 'Tizimdan chiqildi',

      // Relative time
      'time_now': 'Hozir',
      'time_minutes_short': 'min',
      'time_hours_short': 'soat',
      'time_days_short': 'kun',

      // Favorites extras
      'favorites_empty_hint': 'Yoqtirgan joylarni ♥ bosib saqlang',
      'saved_places_suffix': 'ta joy saqlangan',

      // Photo picker sheet
      'choose_photo_title': 'Profil rasmi',
      'take_photo': 'Kameradan olish',
      'choose_from_gallery': 'Galereyadan tanlash',
      'remove_photo': 'Rasmni olib tashlash',
      'image_pick_failed': 'Rasmni tanlab bo\'lmadi',

      // Edit profile extras
      'first_name_hint': 'Ismingizni kiriting',
      'last_name_hint': 'Familiyangizni kiriting',
      'phone_change_note': 'Raqamni o\'zgartirish uchun qo\'llab-quvvatlashga murojaat qiling',
      'birth_date_placeholder': 'KK/OO/YYYY',
      'birth_date_bonus_note': 'Tug\'ilgan kuningizda restoranlardan bonus olasiz',

      // Become a Partner screen
      'partner_connect_title': 'Biznesingizni Bron\'ga ulang',
      'partner_connect_subtitle': 'Mijozlar sizni bir tegishda band qiladi,\nqo\'ng\'iroqsiz, navbatsiz.',
      'benefit_fill_slots_title': 'Bo\'sh vaqtlarni to\'ldiring',
      'benefit_fill_slots_subtitle': 'Mijoz real bo\'sh slotni ko\'radi va darhol band qiladi',
      'benefit_no_show_title': 'No-show kamayadi',
      'benefit_no_show_subtitle': 'Depozit va eslatmalar kelmaslikni qisqartiradi',
      'benefit_pay_on_result_title': 'To\'lov faqat natijaga',
      'benefit_pay_on_result_subtitle': 'Mehmon kelgani uchun komissiya — oylik to\'lov yo\'q',
      'application_section_header': 'ARIZA',
      'your_name_label': 'Ismingiz',
      'your_name_hint': 'Masalan: Aziz Karimov',
      'business_name_hint': 'Masalan: Osteria Da Vinci',
      'category_label': 'Yo\'nalish',
      'category_other': 'Boshqa',
      'address_label': 'Manzil',
      'address_hint': 'Masalan: Bunyodkor ko\'chasi 12',
      'pick_on_map_label': 'Xaritada nuqta belgilash',
      'map_picker_opening': 'Xaritadan joy tanlash ochilmoqda...',
      'phone_label': 'Telefon',
      'application_accepted_title': 'Ariza qabul qilindi!',
      'application_accepted_desc': 'Menejerimiz tez orada siz bilan bog\'lanadi va tizimga ulanishda yordam beradi.',
      'manager_contact_note': 'Menejerimiz bir ish kuni ichida bog\'lanadi',
      'enter_business_name_error': 'Iltimos, biznes nomini kiriting',
      'enter_full_phone_error': 'Telefon raqamini to\'liq kiriting',

      // Card SMS verification
      'sms_verify_title': 'SMS tasdiqlash',
      'enter_sms_code': 'SMS kodni kiriting',
      'sms_code_sent_to_suffix': 'kartasiga bog\'liq raqamga 6 xonali kod yuborildi',
      'sms_code_invalid': 'SMS kod noto\'g\'ri. Qayta kiriting.',

      // Card declined sheet
      'card_declined_title': 'Karta rad etildi',
      'card_declined_default_message':
          'Blok summasi tasdiqlanmadi. Kartada yetarli mablag\' borligini tekshiring yoki boshqa karta tanlang.',
      'card_never_stored_note': 'Karta raqami hech qachon saqlanmaydi.',
      'select_another_card': 'Boshqa karta tanlash',

      // Login
      'login_via_telegram': 'Telegram orqali kirish',

      // Cards extras
      'no_card_added': 'Karta qo\'shilmagan',
      'card_generic_label': 'KARTA',

      // Filters sheet
      'filters_title': 'Filtrlar',
      'clear_filters': 'Tozalash',
      'filter_section_kind': 'YO\'NALISH',
      'filter_section_check': 'O\'rtacha chek',
      'filter_section_rating': 'Reyting',
      'filter_section_sort': 'Saralash',
      'check_up_to_50': '50 minggacha',
      'check_50_to_150': '50–150 ming',
      'check_over_150': '150 mingdan',
      'places_count_suffix': 'ta joy',
      'date_section_label': 'Sana',
      'time_section_label': 'Vaqt',
      'guests_section_label': 'Mehmonlar',
      'duration_section_label': 'Davomiylik',
      'cuisine_section_label': 'Oshxona',
      'additional_section_label': 'Qo\'shimcha',
      'guest_banquet_option': '12+ banket',
      'duration_1_hour': '1 soat',
      'duration_2_hours': '2 soat',
      'duration_3_hours': '3 soat',
      'duration_until_close': 'Kechgacha',
      'sort_by_nearby': 'Yaqin',
      'cuisine_national': 'Milliy',
      'cuisine_european': 'Yevropa',
      'cuisine_asian': 'Osiyo',
      'cuisine_fast_food': 'Fast food',
      'cuisine_coffee': 'Kofe',
      'no_deposit_option': 'Depozitsiz',
      'has_available_table_option': 'Bo\'sh stol bor',
      'large_company_option': 'Katta kompaniya',
      'sort_by_rating': 'Reyting bo\'yicha',
      'sort_by_cheapest': 'Arzonidan',
      'sort_by_expensive': 'Qimmatidan',
      'apply_filters': 'Filtrlarni qo\'llash',
      'filter_all': 'Barchasi',
      'map_load_failed': 'Xarita yuklanmadi',

      // Bookings screen extras
      'waitlist_ready_badge': 'STOL BO\'SHADI',
      'waitlist_waiting_badge': 'NAVBATDASIZ',
      'leave_queue_action': 'Chiqish',
      'people_ahead_label': 'Sizdan oldin',
      'estimated_wait_label': 'Taxminiy kutish',
      'wait_minutes_suffix': 'daqiqa',
      'confirm_timer_running_note': 'Tasdiqlash uchun taymer ishlamoqda — kartaga bosing',
      'today_section_label': 'BUGUN',
      'upcoming_section_label': 'YAQINDA',
      'next_days_section_label': 'KEYINGI KUNLAR',
      'past_bookings_section_label': 'AVVALGI BRONLAR',
      'booking_badge_confirmed': 'TASDIQLANDI',
      'booking_badge_pending': 'KUTILMOQDA',
      'booking_badge_arrived': 'KELDI',
      'booking_badge_no_show': 'KELMADI',
      'booking_badge_cancelled': 'BEKOR QILINGAN',
      'booking_badge_completed': 'YAKUNLANDI',
      'generic_venue_name': 'Muassasa',

      // Shared state views
      'no_internet_title': 'Internet aloqasi yo\'q',
      'no_internet_desc': 'Ulanishni tekshiring va qayta urinib ko\'ring.',
      'something_went_wrong': 'Nimadir xato ketdi',

      // Help & FAQ screen
      'faq_section_header': 'TEZ-TEZ BERILADIGAN SAVOLLAR',
      'faq_footer_note': 'Javob topa olmadingizmi — Telegramda yozing, menejerimiz yordam beradi.',
      'telegram_support_subtitle': '@bron_support · odatda 5 daqiqada javob',
      'call_us_subtitle': '+998 71 200-00-00 · 09:00–21:00',
      'telegram_opening': '@bron_support Telegram qo\'llab-quvvatlash ochilmoqda...',
      'call_opening': '+998 71 200-00-00 raqamiga ulanmoqda...',
      'faq_q1': 'Depozit nima va u qachon qaytariladi?',
      'faq_a1':
          'Depozit — bu gavjum va pik soatlarda stolni siz uchun kafolatli saqlab turish garovidir. Restoranga o\'z vaqtida tashrif buyurganingizda, depozit to\'liq hisobdan chiqariladi yoki umumiy chekingizdan chegirib beriladi.',
      'faq_q2': 'Bronni qanday bekor qilaman?',
      'faq_a2':
          'Bronlarim bo\'limiga o\'tib, kerakli bronni tanlang va "Bronni bekor qilish" tugmasini bosing. Tashrifdan 2 soat oldin bekor qilinsa, hech qanday jarima qo\'llanilmaydi.',
      'faq_q3': 'Kelmasam nima bo\'ladi?',
      'faq_a3':
          'Agar ogohlantirmasdan kelmasangiz (no-show), depozit qaytarilmasligi va profilingizning ishonchlilik reytingi pasayishi mumkin.',
      'faq_q4': 'Geym klubda soatlab bron qanday ishlaydi?',
      'faq_a4':
          'Geym klublarda aniq soatlar (masalan, 19:00 dan 22:00 gacha) va VIP xonalar to\'g\'ridan-to\'g\'ri tanlanadi va band qilinadi.',
      'faq_q5': 'Usta tanlamasam kim xizmat ko\'rsatadi?',
      'faq_a5': 'Agar usta tanlanmasa, tashrif vaqtidagi birinchi bo\'sh mutaxassis sizga xizmat ko\'rsatadi.',
      'faq_q6': 'BRON Plus obunasini qanday bekor qilaman?',
      'faq_a6':
          'Profil -> BRON PLUS bo\'limiga kirib, "Obunani bekor qilish" tugmasini bosish orqali istalgan payt bekor qilishingiz mumkin.',

      // Home
      'city_tashkent': 'Toshkent',
      'search_placeholder': 'Restoran, taom yoki joy',
      'today': 'Bugun',
      'tomorrow': 'Ertaga',
      'persons_count': 'Kishilar soni',
      'near_me': 'Yaqin atrofda',
      'view_all': 'Barchasi',
      'popular_places': 'Mashhur joylar',
      'recommended': 'Tavsiya etiladi',
      'no_data': 'Ma\'lumot topilmadi',
      'available_today': 'Bugun bo\'sh joylar',
      'collections': 'To\'plamlar',
      'deposit': 'Depozit',

      // Categories
      'category_restoran': 'Restoran',
      'category_geym_klub': 'Geym klub',
      'category_sartaroshxona': 'Sartaroshxona',
      'category_gozallik_saloni': 'Go\'zallik saloni',

      // Venue Detail
      'venue_not_found': 'Muassasa topilmadi',
      'popular_dishes': 'Mashhur taomlar',
      'full_menu': 'To\'liq menyu',
      'reviews': 'Sharhlar',
      'link_copied': 'Havola nusxalandi',
      'per_person': 'kishi',

      // Time Selection
      'select_time': 'Vaqt tanlang',
      'which_day': 'QAYSI KUN',
      'calendar': 'Taqvim',
      'which_zone': 'QAYSI JOYDA',
      'any_zone': 'Farqi yo\'q',
      'guest_count': 'MEHMONLAR SONI',
      'free_slots': 'BO\'SH VAQTLAR',
      'select_time_slot': 'Vaqtni tanlang',
      'continue_booking': 'davom etish',
      'closed_today': 'Bu kuni yopiq',
      'no_free_slots': 'Bo\'sh vaqt yo\'q',
      'max_table_seats': 'Eng katta stol',
      'deposit_blocked': 'Bu vaqtlarda depozit kartada bloklanadi',

      // Menu
      'menu_all': 'Hammasi',
      'menu_not_found': 'Menyu topilmadi',
      'menu_empty_section': 'Bu bo\'limda taom yo\'q',

      // Reviews
      'user_reviews': 'Foydalanuvchilar fikri',
      'no_reviews_yet': 'Hali sharhlar yo\'q',
      'review_count': 'sharh',
      'venue_reply': 'Muassasa javobi',

      // Slot unavailable
      'slot_taken': 'Bu vaqt band bo\'ldi',
      'join_waitlist': 'Navbatga yozilish',
      'choose_another_time': 'Boshqa vaqt tanlash',

      // Waitlist
      'waitlist_title': 'Navbatga yozilish',
      'what_time_suits': 'QANDAY VAQT MOS KELADI',
      'any_time': 'Istalgan vaqt',
      'waitlist_note': 'Istalgan payt navbatdan chiqishingiz mumkin.',
      'waitlist_success': 'Navbatga yozildingiz — stol bo\'shashi bilan xabar beramiz',
      'already_in_waitlist': 'Siz allaqachon shu joyning navbatidasiz',
      'party_too_large': 'Kompaniyangiz eng katta stoldan katta',
      'persons': 'kishi',
    },

    // --- РУССКИЙ ---
    'ru': {
      // Auth & Profile
      'login': 'Войти',
      'register': 'Регистрация',
      'login_or_register': 'Войдите или зарегистрируйтесь',
      'phone_number': 'Номер телефона',
      'enter_phone_number': 'Введите номер телефона',
      'password': 'Пароль',
      'enter_password': 'Введите пароль',
      'forgot_password': 'Забыли пароль?',
      'verify_otp': 'Код подтверждения',
      'otp_sent_to': 'Код подтверждения отправлен на номер',
      'resend_otp': 'Отправить код повторно',
      'logout': 'Выйти из аккаунта',
      'delete_account': 'Удалить аккаунт',

      // Navigation
      'nav_home': 'Главная',
      'nav_map': 'Карта',
      'nav_search': 'Поиск',
      'nav_bookings': 'Брони',
      'nav_favorites': 'Избранное',
      'nav_profile': 'Профиль',

      // Profile Menu
      'profile': 'Профиль',
      'edit_profile': 'Редактировать профиль',
      'my_cards': 'Мои карты',
      'my_favorites': 'Избранное',
      'my_bookings': 'Мои брони',
      'notifications': 'Уведомления',
      'language': 'Язык',
      'help': 'Помощь',
      'dark_mode': 'Темная тема',
      'become_partner': 'Стать партнером',
      'help_and_support': 'Помощь и поддержка',
      'privacy_policy': 'Политика конфиденциальности',
      'terms_of_service': 'Условия использования',
      'logout_account': 'Выйти из аккаунта',

      // Bron Plus
      'bron_plus': 'BRON PLUS',
      'bron_plus_title': 'Гарантия мест в пиковые часы',
      'bron_plus_desc': 'И 10% скидка на каждую бронь',

      // Edit Profile
      'first_name': 'Имя',
      'last_name': 'Фамилия',
      'birth_date': 'Дата рождения',
      'gender': 'Пол',
      'gender_male': 'Мужской',
      'gender_female': 'Женский',
      'save_changes': 'Сохранить',
      'change_photo': 'Изменить фото',
      'profile_updated_success': 'Профиль успешно обновлен',

      // Bonus
      'bron_bonus': 'Bron Бонус',
      'bonus_card_desc': 'Получайте кэшбэк за каждую бронь и используйте для оплаты',
      'your_bonus_balance': 'Ваш баланс',
      'how_it_works': 'Как это работает?',
      'bonus_step_1': 'Бронируйте заведения через приложение',
      'bonus_step_2': 'Посетите заведение и покажите QR-код',
      'bonus_step_3': 'Получайте кэшбэк за каждое посещение',
      'bonus_step_4': 'Используйте бонусы как скидку на следующие брони',
      'bonus_history': 'История бонусов',
      'bonus_earned': 'Начислено',
      'bonus_spent': 'Списано',

      // Bron Plus screen
      'cancel_subscription_title': 'Отменить подписку?',
      'cancel_subscription_desc':
          'Plus будет действовать до 25 декабря 2026 года. После этого привилегии отключатся, и автосписание остановится.',
      'cancel_subscription_savings_note':
          'В этом году вы сэкономили с Plus 480 000 сум — это на 90 000 сум больше стоимости подписки.',
      'keep_subscription_button': 'Нет, оставить подписку',
      'confirm_cancel_subscription': 'Да, отменить',
      'bonus_plus_header_title': 'Гарантия места\nдаже в пик часов',
      'bonus_plus_header_subtitle': 'Найдёте столик даже в самые загруженные вечера — и будете экономить на каждой брони.',
      'benefit_priority_title': 'Приоритетная бронь',
      'benefit_priority_subtitle': 'В пиковые часы места открываются сначала для участников Plus',
      'benefit_discount_title': 'Скидка 10% на каждую бронь',
      'benefit_discount_subtitle': 'Начисляется автоматически у партнёров',
      'benefit_no_deposit_title': 'Бронь без депозита',
      'benefit_no_deposit_subtitle': 'Деньги на карте не блокируются',
      'benefit_birthday_title': 'Подарок на день рождения',
      'benefit_birthday_subtitle': 'Персональное предложение от партнёров',
      'plan_monthly_title': '1 месяц',
      'plan_monthly_subtitle': 'в месяц, отмена в любое время',
      'plan_yearly_title': '12 месяцев',
      'plan_yearly_subtitle': 'в месяц · 390 000 сум единоразово',
      'activate_plus_monthly': 'Включить Plus · 39 000 сум',
      'activate_plus_yearly': 'Включить Plus · 390 000 сум',
      'cancel_anytime_note': 'Вы можете отменить в любое время. При отмене подписка работает до конца срока.',
      'bron_plus_activated_success': 'BRON PLUS успешно активирован!',
      'subscription_cancelled_toast': 'Подписка отменена',
      'subscription_title': 'Подписка',
      'subscription_active_title': 'Подписка активна',
      'subscription_active_until': 'До 25 декабря 2026 · автопродление',
      'savings_with_plus_label': 'Сэкономлено с Plus',
      'bookings_count_label': 'брони',
      'active_benefits_header': 'АКТИВНЫЕ ПРИВИЛЕГИИ',
      'cancel_subscription_button': 'Отменить подписку',

      // Cards
      'bind_card_title': 'Привязать карту',
      'why_card_needed_title': 'Зачем нужна карта?',
      'why_card_needed_desc':
          'При бронировании в пиковое время депозит блокируется на карте. Сейчас ничего не списывается и не блокируется — карта только сохраняется.',
      'card_holder_label': 'Владелец карты',
      'card_holder_hint': 'IVANOV IVAN',
      'card_number_label': 'Номер карты',
      'card_expiry_label': 'Срок действия',
      'card_expiry_hint': 'ММ/ГГ',
      'card_security_note': 'Номер карты никогда не сохраняется. Данные надёжно шифруются. CVV-код не требуется.',
      'bind_card_button': 'Привязать карту',
      'fill_all_fields': 'Заполните все поля',
      'card_default_badge': 'ОСНОВНАЯ',
      'add_new_card': 'Добавить новую карту',
      'card_footnote': 'Номер карты никогда не сохраняется. Нажмите и удерживайте — удаление.',
      'card_added_success': 'Новая карта успешно добавлена',
      'card_in_use_error': 'Эта карта используется в активной брони — удалить можно после её завершения',
      'delete_card_title': 'Удалить карту',
      'delete_card_desc': 'Эта карта будет безвозвратно удалена из списка.',
      'delete': 'Удалить',

      // Partner
      'partner_title': 'Станьте нашим партнером',
      'partner_desc': 'Добавьте свое заведение в Bron и привлекайте больше гостей.',
      'business_name': 'Название заведения',
      'business_category': 'Категория бизнеса',
      'contact_person': 'Контактное лицо',
      'city_address': 'Город и точный адрес',
      'submit_application': 'Отправить заявку',
      'application_success': 'Заявка принята! Скоро наш менеджер свяжется с вами.',

      // Bookings
      'active_tab': 'Активные',
      'history_tab': 'История',
      'cancelled_tab': 'Отмененные',
      'show_qr_code': 'Показать QR-код',
      'cancel_booking': 'Отменить бронь',
      'status_confirmed': 'Подтверждено',
      'status_pending': 'В ожидании',
      'status_completed': 'Завершено',
      'status_cancelled': 'Отменено',
      'no_bookings_found': 'Броней пока нет',

      // Favorites
      'no_favorites_found': 'Список избранного пуст',
      'book_now': 'Забронировать',

      // Notifications
      'no_notifications': 'Уведомлений нет',
      'mark_all_as_read': 'Прочитать все',

      // Help & FAQ
      'faq_title': 'Часто задаваемые вопросы',
      'contact_support': 'Связаться с нами',
      'telegram_bot': 'Написать в Telegram',
      'call_us': 'Позвонить нам',

      // Sheets
      'logout_confirm_title': 'Выход из аккаунта',
      'logout_confirm_desc': 'Вы действительно хотите выйти из своего аккаунта?',
      'delete_account_confirm_title': 'Удалить аккаунт',
      'delete_account_confirm_desc': 'Ваш аккаунт и все данные будут безвозвратно удалены.',
      'confirm': 'Подтвердить',
      'cancel': 'Отмена',
      'save': 'Сохранить',
      'retry': 'Повторить',
      'version': 'Версия',
      'select_language': 'Выбор языка',
      'got_it': 'Понятно',

      // Profile menu extras
      'staff_mode_title': 'Режим хостес',
      'staff_mode_subtitle': 'для персонала (dev)',
      'logged_out_toast': 'Вы вышли из аккаунта',

      // Relative time
      'time_now': 'Сейчас',
      'time_minutes_short': 'мин',
      'time_hours_short': 'ч',
      'time_days_short': 'дн',

      // Favorites extras
      'favorites_empty_hint': 'Сохраняйте любимые места, нажимая ♥',
      'saved_places_suffix': 'мест сохранено',

      // Photo picker sheet
      'choose_photo_title': 'Фото профиля',
      'take_photo': 'Снять на камеру',
      'choose_from_gallery': 'Выбрать из галереи',
      'remove_photo': 'Удалить фото',
      'image_pick_failed': 'Не удалось выбрать фото',

      // Edit profile extras
      'first_name_hint': 'Введите имя',
      'last_name_hint': 'Введите фамилию',
      'phone_change_note': 'Чтобы изменить номер, обратитесь в поддержку',
      'birth_date_placeholder': 'ДД/ММ/ГГГГ',
      'birth_date_bonus_note': 'В день рождения получите бонусы от ресторанов',

      // Become a Partner screen
      'partner_connect_title': 'Подключите свой бизнес к Bron',
      'partner_connect_subtitle': 'Клиенты забронируют у вас в одно касание,\nбез звонков и очередей.',
      'benefit_fill_slots_title': 'Заполняйте свободное время',
      'benefit_fill_slots_subtitle': 'Клиент видит реальный свободный слот и сразу бронирует',
      'benefit_no_show_title': 'Меньше неявок',
      'benefit_no_show_subtitle': 'Депозит и напоминания сокращают количество неявок',
      'benefit_pay_on_result_title': 'Оплата только за результат',
      'benefit_pay_on_result_subtitle': 'Комиссия за визит гостя — без ежемесячной платы',
      'application_section_header': 'ЗАЯВКА',
      'your_name_label': 'Ваше имя',
      'your_name_hint': 'Например: Азиз Каримов',
      'business_name_hint': 'Например: Osteria Da Vinci',
      'category_label': 'Направление',
      'category_other': 'Другое',
      'address_label': 'Адрес',
      'address_hint': 'Например: улица Бунёдкор 12',
      'pick_on_map_label': 'Отметить точку на карте',
      'map_picker_opening': 'Открывается выбор места на карте...',
      'phone_label': 'Телефон',
      'application_accepted_title': 'Заявка принята!',
      'application_accepted_desc': 'Наш менеджер скоро свяжется с вами и поможет подключиться к системе.',
      'manager_contact_note': 'Наш менеджер свяжется в течение одного рабочего дня',
      'enter_business_name_error': 'Пожалуйста, введите название бизнеса',
      'enter_full_phone_error': 'Введите номер телефона полностью',

      // Card SMS verification
      'sms_verify_title': 'Подтверждение SMS',
      'enter_sms_code': 'Введите код из SMS',
      'sms_code_sent_to_suffix': '— на номер, привязанный к карте, отправлен 6-значный код',
      'sms_code_invalid': 'Неверный код. Попробуйте снова.',

      // Card declined sheet
      'card_declined_title': 'Карта отклонена',
      'card_declined_default_message':
          'Сумма блокировки не подтверждена. Проверьте, достаточно ли средств на карте, или выберите другую карту.',
      'card_never_stored_note': 'Номер карты никогда не сохраняется.',
      'select_another_card': 'Выбрать другую карту',

      // Login
      'login_via_telegram': 'Войти через Telegram',

      // Cards extras
      'no_card_added': 'Карта не добавлена',
      'card_generic_label': 'КАРТА',

      // Filters sheet
      'filters_title': 'Фильтры',
      'clear_filters': 'Очистить',
      'filter_section_kind': 'НАПРАВЛЕНИЕ',
      'filter_section_check': 'Средний чек',
      'filter_section_rating': 'Рейтинг',
      'filter_section_sort': 'Сортировка',
      'check_up_to_50': 'До 50 тыс.',
      'check_50_to_150': '50–150 тыс.',
      'check_over_150': 'Свыше 150 тыс.',
      'places_count_suffix': 'мест',
      'date_section_label': 'Дата',
      'time_section_label': 'Время',
      'guests_section_label': 'Гости',
      'duration_section_label': 'Продолжительность',
      'cuisine_section_label': 'Кухня',
      'additional_section_label': 'Дополнительно',
      'guest_banquet_option': '12+ банкет',
      'duration_1_hour': '1 час',
      'duration_2_hours': '2 часа',
      'duration_3_hours': '3 часа',
      'duration_until_close': 'До закрытия',
      'sort_by_nearby': 'Рядом',
      'cuisine_national': 'Национальная',
      'cuisine_european': 'Европейская',
      'cuisine_asian': 'Азиатская',
      'cuisine_fast_food': 'Фастфуд',
      'cuisine_coffee': 'Кофе',
      'no_deposit_option': 'Без депозита',
      'has_available_table_option': 'Есть свободный стол',
      'large_company_option': 'Большая компания',
      'sort_by_rating': 'По рейтингу',
      'sort_by_cheapest': 'Сначала дешёвые',
      'sort_by_expensive': 'Сначала дорогие',
      'apply_filters': 'Применить фильтры',
      'filter_all': 'Все',
      'map_load_failed': 'Карта не загрузилась',

      // Bookings screen extras
      'waitlist_ready_badge': 'СТОЛИК ОСВОБОДИЛСЯ',
      'waitlist_waiting_badge': 'В ОЧЕРЕДИ',
      'leave_queue_action': 'Выйти',
      'people_ahead_label': 'Перед вами',
      'estimated_wait_label': 'Примерное ожидание',
      'wait_minutes_suffix': 'минут',
      'confirm_timer_running_note': 'Идёт таймер подтверждения — нажмите на карточку',
      'today_section_label': 'СЕГОДНЯ',
      'upcoming_section_label': 'СКОРО',
      'next_days_section_label': 'СЛЕДУЮЩИЕ ДНИ',
      'past_bookings_section_label': 'ПРОШЛЫЕ БРОНИ',
      'booking_badge_confirmed': 'ПОДТВЕРЖДЕНО',
      'booking_badge_pending': 'В ОЖИДАНИИ',
      'booking_badge_arrived': 'ПРИШЁЛ',
      'booking_badge_no_show': 'НЕ ПРИШЁЛ',
      'booking_badge_cancelled': 'ОТМЕНЕНО',
      'booking_badge_completed': 'ЗАВЕРШЕНО',
      'generic_venue_name': 'Заведение',

      // Shared state views
      'no_internet_title': 'Нет подключения к интернету',
      'no_internet_desc': 'Проверьте соединение и попробуйте снова.',
      'something_went_wrong': 'Что-то пошло не так',

      // Help & FAQ screen
      'faq_section_header': 'ЧАСТО ЗАДАВАЕМЫЕ ВОПРОСЫ',
      'faq_footer_note': 'Не нашли ответ — напишите в Telegram, наш менеджер поможет.',
      'telegram_support_subtitle': '@bron_support · обычно отвечаем за 5 минут',
      'call_us_subtitle': '+998 71 200-00-00 · 09:00–21:00',
      'telegram_opening': 'Открывается поддержка @bron_support в Telegram...',
      'call_opening': 'Звонок на номер +998 71 200-00-00...',
      'faq_q1': 'Что такое депозит и когда он возвращается?',
      'faq_a1':
          'Депозит — это гарантия того, что столик сохранится за вами в загруженные и пиковые часы. При своевременном визите депозит полностью списывается или вычитается из общего чека.',
      'faq_q2': 'Как отменить бронь?',
      'faq_a2':
          'Перейдите в раздел "Мои брони", выберите нужную бронь и нажмите «Отменить бронь». При отмене за 2 часа до визита штраф не применяется.',
      'faq_q3': 'Что будет, если я не приду?',
      'faq_a3':
          'Если вы не придёте без предупреждения (no-show), депозит может не вернуться, а рейтинг надёжности профиля — снизиться.',
      'faq_q4': 'Как работает почасовая бронь в гейм-клубе?',
      'faq_a4':
          'В гейм-клубах выбираются и бронируются конкретные часы (например, с 19:00 до 22:00) и VIP-комнаты напрямую.',
      'faq_q5': 'Кто обслужит, если я не выбрал мастера?',
      'faq_a5': 'Если мастер не выбран, вас обслужит первый свободный специалист на момент визита.',
      'faq_q6': 'Как отменить подписку BRON Plus?',
      'faq_a6':
          'Зайдите в Профиль -> раздел BRON PLUS и нажмите «Отменить подписку» — сделать это можно в любое время.',

      // Home
      'city_tashkent': 'Ташкент',
      'search_placeholder': 'Ресторан, блюдо или место',
      'today': 'Сегодня',
      'tomorrow': 'Завтра',
      'persons_count': 'Количество гостей',
      'near_me': 'Рядом',
      'view_all': 'Все',
      'popular_places': 'Популярные места',
      'recommended': 'Рекомендуем',
      'no_data': 'Данные не найдены',
      'available_today': 'Свободные места сегодня',
      'collections': 'Подборки',
      'deposit': 'Депозит',

      // Categories
      'category_restoran': 'Ресторан',
      'category_geym_klub': 'Гейм клуб',
      'category_sartaroshxona': 'Барбершоп',
      'category_gozallik_saloni': 'Салон красоты',

      // Venue Detail
      'venue_not_found': 'Заведение не найдено',
      'popular_dishes': 'Популярные блюда',
      'full_menu': 'Полное меню',
      'reviews': 'Отзывы',
      'link_copied': 'Ссылка скопирована',
      'per_person': 'чел.',

      // Time Selection
      'select_time': 'Выберите время',
      'which_day': 'КАКОЙ ДЕНЬ',
      'calendar': 'Календарь',
      'which_zone': 'КАКАЯ ЗОНА',
      'any_zone': 'Без разницы',
      'guest_count': 'КОЛИЧЕСТВО ГОСТЕЙ',
      'free_slots': 'СВОБОДНОЕ ВРЕМЯ',
      'select_time_slot': 'Выберите время',
      'continue_booking': 'продолжить',
      'closed_today': 'В этот день закрыто',
      'no_free_slots': 'Нет свободного времени',
      'max_table_seats': 'Самый большой стол',
      'deposit_blocked': 'В это время депозит блокируется на карте',

      // Menu
      'menu_all': 'Все',
      'menu_not_found': 'Меню не найдено',
      'menu_empty_section': 'В этом разделе нет блюд',

      // Reviews
      'user_reviews': 'Отзывы гостей',
      'no_reviews_yet': 'Отзывов пока нет',
      'review_count': 'отзыв',
      'venue_reply': 'Ответ заведения',

      // Slot unavailable
      'slot_taken': 'Это время уже занято',
      'join_waitlist': 'Встать в очередь',
      'choose_another_time': 'Выбрать другое время',

      // Waitlist
      'waitlist_title': 'Встать в очередь',
      'what_time_suits': 'КАКОЕ ВРЕМЯ ПОДХОДИТ',
      'any_time': 'Любое время',
      'waitlist_note': 'Вы можете покинуть очередь в любой момент.',
      'waitlist_success': 'Вы в очереди — уведомим, когда столик освободится',
      'already_in_waitlist': 'Вы уже в очереди этого заведения',
      'party_too_large': 'Ваша компания больше самого большого стола',
      'persons': 'чел.',
    },

    // --- ENGLISH ---
    'en': {
      // Auth & Profile
      'login': 'Log In',
      'register': 'Sign Up',
      'login_or_register': 'Log in or sign up',
      'phone_number': 'Phone Number',
      'enter_phone_number': 'Enter your phone number',
      'password': 'Password',
      'enter_password': 'Enter your password',
      'forgot_password': 'Forgot password?',
      'verify_otp': 'Verification Code',
      'otp_sent_to': 'Verification code sent to',
      'resend_otp': 'Resend Code',
      'logout': 'Log Out',
      'delete_account': 'Delete Account',

      // Navigation
      'nav_home': 'Home',
      'nav_map': 'Map',
      'nav_search': 'Search',
      'nav_bookings': 'Bookings',
      'nav_favorites': 'Favorites',
      'nav_profile': 'Profile',

      // Profile Menu
      'profile': 'Profile',
      'edit_profile': 'Edit Profile',
      'my_cards': 'My Cards',
      'my_favorites': 'Favorites',
      'my_bookings': 'My Bookings',
      'notifications': 'Notifications',
      'language': 'Language',
      'help': 'Help',
      'dark_mode': 'Dark Mode',
      'become_partner': 'Become a Partner',
      'help_and_support': 'Help & Support',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',
      'logout_account': 'Log Out',

      // Bron Plus
      'bron_plus': 'BRON PLUS',
      'bron_plus_title': 'Guaranteed seating during peak hours',
      'bron_plus_desc': 'And 10% discount on every booking',

      // Edit Profile
      'first_name': 'First Name',
      'last_name': 'Last Name',
      'birth_date': 'Date of Birth',
      'gender': 'Gender',
      'gender_male': 'Male',
      'gender_female': 'Female',
      'save_changes': 'Save Changes',
      'change_photo': 'Change Photo',
      'profile_updated_success': 'Profile updated successfully',

      // Bonus
      'bron_bonus': 'Bron Bonus',
      'bonus_card_desc': 'Earn cashback for every booking and use it for future payments',
      'your_bonus_balance': 'Your Balance',
      'how_it_works': 'How does it work?',
      'bonus_step_1': 'Book any venue through the app',
      'bonus_step_2': 'Visit and present your QR code',
      'bonus_step_3': 'Get cashback directly to your bonus balance',
      'bonus_step_4': 'Redeem bonuses as discounts on your next bookings',
      'bonus_history': 'Bonus History',
      'bonus_earned': 'Earned',
      'bonus_spent': 'Spent',

      // Bron Plus screen
      'cancel_subscription_title': 'Cancel your subscription?',
      'cancel_subscription_desc':
          'Plus will keep working until December 25, 2026. After that your perks will turn off and auto-renewal will stop.',
      'cancel_subscription_savings_note':
          'You\'ve saved 480,000 UZS with Plus this year — 90,000 UZS more than the subscription price.',
      'keep_subscription_button': 'No, keep my subscription',
      'confirm_cancel_subscription': 'Yes, cancel',
      'bonus_plus_header_title': 'Guaranteed seating\neven at peak hours',
      'bonus_plus_header_subtitle': 'Get a table even on the busiest nights — and save on every booking.',
      'benefit_priority_title': 'Priority booking',
      'benefit_priority_subtitle': 'Spots open to Plus members first during peak hours',
      'benefit_discount_title': '10% discount on every booking',
      'benefit_discount_subtitle': 'Applied automatically at partner venues',
      'benefit_no_deposit_title': 'No-deposit booking',
      'benefit_no_deposit_subtitle': 'No funds are held on your card',
      'benefit_birthday_title': 'Birthday gift',
      'benefit_birthday_subtitle': 'A personal offer from partner venues',
      'plan_monthly_title': '1 month',
      'plan_monthly_subtitle': 'per month, cancel anytime',
      'plan_yearly_title': '12 months',
      'plan_yearly_subtitle': 'per month · 390,000 UZS billed once',
      'activate_plus_monthly': 'Activate Plus · 39,000 UZS',
      'activate_plus_yearly': 'Activate Plus · 390,000 UZS',
      'cancel_anytime_note': 'Cancel anytime. If cancelled, it stays active until the end of the period.',
      'bron_plus_activated_success': 'BRON PLUS activated successfully!',
      'subscription_cancelled_toast': 'Subscription cancelled',
      'subscription_title': 'Subscription',
      'subscription_active_title': 'Subscription active',
      'subscription_active_until': 'Until Dec 25, 2026 · auto-renews',
      'savings_with_plus_label': 'Saved with Plus',
      'bookings_count_label': 'bookings',
      'active_benefits_header': 'ACTIVE PERKS',
      'cancel_subscription_button': 'Cancel subscription',

      // Cards
      'bind_card_title': 'Add Card',
      'why_card_needed_title': 'Why is a card needed?',
      'why_card_needed_desc':
          'For bookings at peak times, a deposit is held on your card. Right now nothing is charged or held — the card is only saved.',
      'card_holder_label': 'Cardholder',
      'card_holder_hint': 'JOHN SMITH',
      'card_number_label': 'Card Number',
      'card_expiry_label': 'Expiry Date',
      'card_expiry_hint': 'MM/YY',
      'card_security_note': 'Your card number is never stored. Data is securely encrypted. No CVV required.',
      'bind_card_button': 'Add Card',
      'fill_all_fields': 'Please fill in all fields',
      'card_default_badge': 'DEFAULT',
      'add_new_card': 'Add new card',
      'card_footnote': 'Your card number is never stored. Press and hold to delete.',
      'card_added_success': 'New card added successfully',
      'card_in_use_error': 'This card is in use for an active booking — you can delete it once the booking ends',
      'delete_card_title': 'Delete Card',
      'delete_card_desc': 'This card will be permanently removed from your list.',
      'delete': 'Delete',

      // Partner
      'partner_title': 'Become our partner',
      'partner_desc': 'List your venue on Bron platform and grow your customer base.',
      'business_name': 'Venue / Business Name',
      'business_category': 'Category',
      'contact_person': 'Contact Person',
      'city_address': 'City & Address',
      'submit_application': 'Submit Application',
      'application_success': 'Application submitted! Our manager will contact you soon.',

      // Bookings
      'active_tab': 'Active',
      'history_tab': 'History',
      'cancelled_tab': 'Cancelled',
      'show_qr_code': 'Show QR Code',
      'cancel_booking': 'Cancel Booking',
      'status_confirmed': 'Confirmed',
      'status_pending': 'Pending',
      'status_completed': 'Completed',
      'status_cancelled': 'Cancelled',
      'no_bookings_found': 'No bookings found yet',

      // Favorites
      'no_favorites_found': 'Your favorites list is empty',
      'book_now': 'Book Now',

      // Notifications
      'no_notifications': 'No notifications yet',
      'mark_all_as_read': 'Mark all as read',

      // Help & FAQ
      'faq_title': 'Frequently Asked Questions',
      'contact_support': 'Contact Support',
      'telegram_bot': 'Message via Telegram',
      'call_us': 'Call Us',

      // Sheets
      'logout_confirm_title': 'Log Out',
      'logout_confirm_desc': 'Are you sure you want to log out of your account?',
      'delete_account_confirm_title': 'Delete Account',
      'delete_account_confirm_desc': 'Your account and all associated data will be permanently deleted.',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'save': 'Save',
      'retry': 'Retry',
      'version': 'Version',
      'select_language': 'Select Language',
      'got_it': 'Got it',

      // Profile menu extras
      'staff_mode_title': 'Staff mode',
      'staff_mode_subtitle': 'for staff (dev)',
      'logged_out_toast': 'Logged out',

      // Relative time
      'time_now': 'Now',
      'time_minutes_short': 'min',
      'time_hours_short': 'h',
      'time_days_short': 'd',

      // Favorites extras
      'favorites_empty_hint': 'Save your favorite places by tapping ♥',
      'saved_places_suffix': 'places saved',

      // Photo picker sheet
      'choose_photo_title': 'Profile photo',
      'take_photo': 'Take a photo',
      'choose_from_gallery': 'Choose from gallery',
      'remove_photo': 'Remove photo',
      'image_pick_failed': 'Couldn\'t select the photo',

      // Edit profile extras
      'first_name_hint': 'Enter your first name',
      'last_name_hint': 'Enter your last name',
      'phone_change_note': 'Contact support to change your number',
      'birth_date_placeholder': 'DD/MM/YYYY',
      'birth_date_bonus_note': 'Get bonuses from restaurants on your birthday',

      // Become a Partner screen
      'partner_connect_title': 'Connect your business to Bron',
      'partner_connect_subtitle': 'Guests book you in one tap —\nno calls, no waiting.',
      'benefit_fill_slots_title': 'Fill your open slots',
      'benefit_fill_slots_subtitle': 'Guests see real availability and book instantly',
      'benefit_no_show_title': 'Fewer no-shows',
      'benefit_no_show_subtitle': 'Deposits and reminders reduce no-shows',
      'benefit_pay_on_result_title': 'Pay only for results',
      'benefit_pay_on_result_subtitle': 'A commission per visiting guest — no monthly fee',
      'application_section_header': 'APPLICATION',
      'your_name_label': 'Your Name',
      'your_name_hint': 'e.g. Aziz Karimov',
      'business_name_hint': 'e.g. Osteria Da Vinci',
      'category_label': 'Category',
      'category_other': 'Other',
      'address_label': 'Address',
      'address_hint': 'e.g. Bunyodkor street 12',
      'pick_on_map_label': 'Pin location on map',
      'map_picker_opening': 'Opening map location picker...',
      'phone_label': 'Phone',
      'application_accepted_title': 'Application accepted!',
      'application_accepted_desc': 'Our manager will contact you soon and help you get connected.',
      'manager_contact_note': 'Our manager will contact you within one business day',
      'enter_business_name_error': 'Please enter your business name',
      'enter_full_phone_error': 'Please enter your full phone number',

      // Card SMS verification
      'sms_verify_title': 'SMS Verification',
      'enter_sms_code': 'Enter the SMS code',
      'sms_code_sent_to_suffix': '— a 6-digit code was sent to the number linked to this card',
      'sms_code_invalid': 'Incorrect code. Please try again.',

      // Card declined sheet
      'card_declined_title': 'Card Declined',
      'card_declined_default_message':
          'The hold amount wasn\'t confirmed. Check that the card has enough funds, or choose another card.',
      'card_never_stored_note': 'Your card number is never stored.',
      'select_another_card': 'Choose another card',

      // Login
      'login_via_telegram': 'Log in via Telegram',

      // Cards extras
      'no_card_added': 'No card added',
      'card_generic_label': 'CARD',

      // Filters sheet
      'filters_title': 'Filters',
      'clear_filters': 'Clear',
      'filter_section_kind': 'CATEGORY',
      'filter_section_check': 'Average check',
      'filter_section_rating': 'Rating',
      'filter_section_sort': 'Sort by',
      'check_up_to_50': 'Up to 50K',
      'check_50_to_150': '50K–150K',
      'check_over_150': 'Over 150K',
      'places_count_suffix': 'places',
      'date_section_label': 'Date',
      'time_section_label': 'Time',
      'guests_section_label': 'Guests',
      'duration_section_label': 'Duration',
      'cuisine_section_label': 'Cuisine',
      'additional_section_label': 'Additional',
      'guest_banquet_option': '12+ banquet',
      'duration_1_hour': '1 hour',
      'duration_2_hours': '2 hours',
      'duration_3_hours': '3 hours',
      'duration_until_close': 'Until closing',
      'sort_by_nearby': 'Nearby',
      'cuisine_national': 'National',
      'cuisine_european': 'European',
      'cuisine_asian': 'Asian',
      'cuisine_fast_food': 'Fast food',
      'cuisine_coffee': 'Coffee',
      'no_deposit_option': 'No deposit',
      'has_available_table_option': 'Table available',
      'large_company_option': 'Large group',
      'sort_by_rating': 'By rating',
      'sort_by_cheapest': 'Cheapest first',
      'sort_by_expensive': 'Most expensive first',
      'apply_filters': 'Apply Filters',
      'filter_all': 'All',
      'map_load_failed': 'Map failed to load',

      // Bookings screen extras
      'waitlist_ready_badge': 'TABLE READY',
      'waitlist_waiting_badge': 'IN QUEUE',
      'leave_queue_action': 'Leave',
      'people_ahead_label': 'Ahead of you',
      'estimated_wait_label': 'Estimated wait',
      'wait_minutes_suffix': 'min',
      'confirm_timer_running_note': 'Confirmation timer is running — tap the card',
      'today_section_label': 'TODAY',
      'upcoming_section_label': 'UPCOMING',
      'next_days_section_label': 'NEXT DAYS',
      'past_bookings_section_label': 'PAST BOOKINGS',
      'booking_badge_confirmed': 'CONFIRMED',
      'booking_badge_pending': 'PENDING',
      'booking_badge_arrived': 'ARRIVED',
      'booking_badge_no_show': 'NO-SHOW',
      'booking_badge_cancelled': 'CANCELLED',
      'booking_badge_completed': 'COMPLETED',
      'generic_venue_name': 'Venue',

      // Shared state views
      'no_internet_title': 'No internet connection',
      'no_internet_desc': 'Check your connection and try again.',
      'something_went_wrong': 'Something went wrong',

      // Help & FAQ screen
      'faq_section_header': 'FREQUENTLY ASKED QUESTIONS',
      'faq_footer_note': 'Can\'t find an answer — message us on Telegram, our manager will help.',
      'telegram_support_subtitle': '@bron_support · usually replies within 5 minutes',
      'call_us_subtitle': '+998 71 200-00-00 · 09:00–21:00',
      'telegram_opening': 'Opening @bron_support on Telegram...',
      'call_opening': 'Calling +998 71 200-00-00...',
      'faq_q1': 'What is a deposit and when is it refunded?',
      'faq_a1':
          'A deposit guarantees your table is held for you during busy, peak hours. If you arrive on time, the deposit is fully charged as part of your bill or deducted from your total check.',
      'faq_q2': 'How do I cancel a booking?',
      'faq_a2':
          'Go to My Bookings, select the booking, and tap "Cancel Booking". Cancelling at least 2 hours before your visit incurs no penalty.',
      'faq_q3': 'What happens if I don\'t show up?',
      'faq_a3':
          'If you don\'t show up without notice (no-show), your deposit may not be refunded and your profile\'s reliability rating may drop.',
      'faq_q4': 'How does hourly booking work at a game club?',
      'faq_a4':
          'At game clubs, specific hours (e.g. 7 PM to 10 PM) and VIP rooms are selected and booked directly.',
      'faq_q5': 'Who serves me if I don\'t pick a specialist?',
      'faq_a5': 'If no specialist is selected, the first available one at the time of your visit will serve you.',
      'faq_q6': 'How do I cancel my BRON Plus subscription?',
      'faq_a6':
          'Go to Profile -> BRON PLUS and tap "Cancel subscription" — you can do this at any time.',

      // Home
      'city_tashkent': 'Tashkent',
      'search_placeholder': 'Restaurant, dish or place',
      'today': 'Today',
      'tomorrow': 'Tomorrow',
      'persons_count': 'Number of guests',
      'near_me': 'Nearby',
      'view_all': 'View all',
      'popular_places': 'Popular places',
      'recommended': 'Recommended',
      'no_data': 'No data found',
      'available_today': 'Available today',
      'collections': 'Collections',
      'deposit': 'Deposit',

      // Categories
      'category_restoran': 'Restaurant',
      'category_geym_klub': 'Game club',
      'category_sartaroshxona': 'Barbershop',
      'category_gozallik_saloni': 'Beauty salon',

      // Venue Detail
      'venue_not_found': 'Venue not found',
      'popular_dishes': 'Popular dishes',
      'full_menu': 'Full menu',
      'reviews': 'Reviews',
      'link_copied': 'Link copied',
      'per_person': 'person',

      // Time Selection
      'select_time': 'Select time',
      'which_day': 'WHICH DAY',
      'calendar': 'Calendar',
      'which_zone': 'WHICH ZONE',
      'any_zone': 'Any zone',
      'guest_count': 'NUMBER OF GUESTS',
      'free_slots': 'AVAILABLE SLOTS',
      'select_time_slot': 'Select a time',
      'continue_booking': 'continue',
      'closed_today': 'Closed on this day',
      'no_free_slots': 'No available slots',
      'max_table_seats': 'Largest table',
      'deposit_blocked': 'Deposit will be held on your card for this time',

      // Menu
      'menu_all': 'All',
      'menu_not_found': 'Menu not found',
      'menu_empty_section': 'No items in this section',

      // Reviews
      'user_reviews': 'Guest reviews',
      'no_reviews_yet': 'No reviews yet',
      'review_count': 'review',
      'venue_reply': 'Venue reply',

      // Slot unavailable
      'slot_taken': 'This time slot is taken',
      'join_waitlist': 'Join waitlist',
      'choose_another_time': 'Choose another time',

      // Waitlist
      'waitlist_title': 'Join waitlist',
      'what_time_suits': 'PREFERRED TIME',
      'any_time': 'Any time',
      'waitlist_note': 'You can leave the waitlist at any time.',
      'waitlist_success': 'You\'re on the waitlist — we\'ll notify you when a table opens up',
      'already_in_waitlist': 'You\'re already on this venue\'s waitlist',
      'party_too_large': 'Your party exceeds the largest table',
      'persons': 'guests',
    },
  };
}

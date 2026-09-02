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

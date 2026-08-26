import 'package:flutter/foundation.dart';

enum AppLanguage {
  uz('Oʻzbekcha', 'uz'),
  ru('Русский', 'ru'),
  en('English', 'en');

  final String title;
  final String code;
  const AppLanguage(this.title, this.code);
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
  static const String onboardingTitle1 = 'Restoran, geym klub,sartaroshxona';
  static const String onboardingDesc1 =
      'Toshkentdagi barcha xizmatlarni bitta ilovada bron qiling.';

  static const String onboardingTitle2 = 'Yaqin atrofdagi joylarni xaritada ko\'ring';
  static const String onboardingDesc2 =
      'Qaysi joy yaqin va bo\'sh — bir qarashda bilinadi.';

  static const String onboardingTitle3 = 'Bo\'sh vaqtlarnini darhol, oson ko\'rasiz';
  static const String onboardingDesc3 =
      'Qo\'ng\'iroq qilish shart emas — qaysi soat bo\'shligi ekranda turadi.';

  static const String onboardingTitle4 = 'Bron qilishni uch tegishda qiling';
  static const String onboardingDesc4 =
      'Vaqtni tanlang va tasdiqlang.Kelganingizda joy sizni kutib turadi.';

  static const String onboardingTitle5 = 'Hammasi tayyor. Boshlaymizmi?';
  static const String onboardingDesc5 =
      'Ro\'yxatdan o\'tish shart emas — avval ko\'ring, keyin bron qilasiz.';

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
  static String get phoneNumber => tr('phone_number');
  static String get enterPhoneNumber => tr('enter_phone_number');
  static String get password => tr('password');
  static String get enterPassword => tr('enter_password');
  static String get forgotPassword => tr('forgot_password');
  static String get verifyOtp => tr('verify_otp');
  static String get otpSentTo => tr('otp_sent_to');
  static String get resendOtp => tr('resend_otp');
  static String get logout => tr('logout');

  // Navigation
  static String get navHome => tr('nav_home');
  static String get navMap => tr('nav_map');
  static String get navSearch => tr('nav_search');
  static String get navBookings => tr('nav_bookings');
  static String get navFavorites => tr('nav_favorites');
  static String get navProfile => tr('nav_profile');

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

  // Categories
  static String get catRestaurant => tr('cat_restaurant');
  static String get catGameClub => tr('cat_game_club');
  static String get catBarber => tr('cat_barber');
  static String get catBeauty => tr('cat_beauty');
  static String get catSport => tr('cat_sport');
  static String get catCoworking => tr('cat_coworking');

  // Booking details
  static String get bookNow => tr('book_now');
  static String get selectDate => tr('select_date');
  static String get selectTime => tr('select_time');
  static String get guestCount => tr('guest_count');
  static String get confirmBooking => tr('confirm_booking');
  static String get bookingSuccess => tr('booking_success');
  static String get cancelBooking => tr('cancel_booking');
  static String get activeBookings => tr('active_bookings');
  static String get bookingHistory => tr('booking_history');

  // Profile & Settings
  static String get myProfile => tr('my_profile');
  static String get editProfile => tr('edit_profile');
  static String get notifications => tr('notifications');
  static String get selectLanguage => tr('select_language');
  static String get darkMode => tr('dark_mode');
  static String get helpCenter => tr('help_center');
  static String get termsOfService => tr('terms_of_service');
  static String get privacyPolicy => tr('privacy_policy');

  // Common & Errors
  static String get cancel => tr('cancel');
  static String get save => tr('save');
  static String get apply => tr('apply');
  static String get retry => tr('retry');
  static String get loading => tr('loading');
  static String get noData => tr('no_data');
  static String get networkError => tr('network_error');
  static String get serverError => tr('server_error');
  static String get unknownError => tr('unknown_error');

  // ==========================================
  // TRANSLATION DICTIONARY
  // ==========================================
  static final Map<String, Map<String, String>> _translations = {
    // --- O'ZBEKCHA ---
    'uz': {
      // Auth
      'login': 'Kirish',
      'register': "Ro'yxatdan o'tish",
      'phone_number': 'Telefon raqam',
      'enter_phone_number': 'Telefon raqamingizni kiriting',
      'password': 'Parol',
      'enter_password': 'Parolingizni kiriting',
      'forgot_password': 'Parolni unutdingizmi?',
      'verify_otp': 'Tasdiqlash kodi',
      'otp_sent_to': 'Tasdiqlash kodi raqamingizga yuborildi',
      'resend_otp': 'Kodni qayta yuborish',
      'logout': 'Chiqish',

      // Navigation
      'nav_home': 'Asosiy',
      'nav_map': 'Xarita',
      'nav_search': 'Qidiruv',
      'nav_bookings': 'Bronlarim',
      'nav_favorites': 'Sevimlilar',
      'nav_profile': 'Profil',

      // Home & Search
      'city_tashkent': 'Toshkent',
      'search_placeholder': 'Restoran, taom yoki joy...',
      'today': 'Bugun',
      'tomorrow': 'Ertaga',
      'persons_count': 'kishi',
      'near_me': 'Yaqin atrofda',
      'view_all': 'Barchasi',
      'popular_places': 'Mashhur joylar',
      'recommended': 'Tavsiya etilganlar',

      // Categories
      'cat_restaurant': 'Restoran',
      'cat_game_club': 'Geym klub',
      'cat_barber': 'Sartarosh',
      'cat_beauty': "Go'zallik",
      'cat_sport': 'Sport',
      'cat_coworking': 'Kovorking',

      // Booking
      'book_now': 'Bron qilish',
      'select_date': 'Sanani tanlang',
      'select_time': 'Vaqtni tanlang',
      'guest_count': 'Mehmonlar soni',
      'confirm_booking': 'Bronni tasdiqlash',
      'booking_success': 'Muvaffaqiyatli bron qilindi!',
      'cancel_booking': 'Bronni bekor qilish',
      'active_bookings': 'Faol bronlar',
      'booking_history': 'Bronlar tarixi',

      // Profile
      'my_profile': 'Mening profilim',
      'edit_profile': 'Profilni tahrirlash',
      'notifications': 'Xabarnomalar',
      'select_language': 'Tilni tanlash',
      'dark_mode': 'Tungi rejim',
      'help_center': 'Yordam markazi',
      'terms_of_service': 'Foydalanish shartlari',
      'privacy_policy': 'Maxfiylik siyosati',

      // Common
      'cancel': 'Bekor qilish',
      'save': 'Saqlash',
      'apply': 'Qoʻllash',
      'retry': 'Qayta urinish',
      'loading': 'Yuklanmoqda...',
      'no_data': "Ma'lumot topilmadi",
      'network_error': 'Internet aloqasi mavjud emas',
      'server_error': 'Serverda xatolik yuz berdi',
      'unknown_error': 'Nomaʼlum xatolik yuz berdi',
    },

    // --- РУССКИЙ ---
    'ru': {
      // Auth
      'login': 'Войти',
      'register': 'Регистрация',
      'phone_number': 'Номер телефона',
      'enter_phone_number': 'Введите номер телефона',
      'password': 'Пароль',
      'enter_password': 'Введите пароль',
      'forgot_password': 'Забыли пароль?',
      'verify_otp': 'Код подтверждения',
      'otp_sent_to': 'Код подтверждения отправлен на номер',
      'resend_otp': 'Отправить код повторно',
      'logout': 'Выйти',

      // Navigation
      'nav_home': 'Главная',
      'nav_map': 'Карта',
      'nav_search': 'Поиск',
      'nav_bookings': 'Мои брони',
      'nav_favorites': 'Избранное',
      'nav_profile': 'Профиль',

      // Home & Search
      'city_tashkent': 'Ташкент',
      'search_placeholder': 'Ресторан, блюдо или заведение...',
      'today': 'Сегодня',
      'tomorrow': 'Завтра',
      'persons_count': 'чел.',
      'near_me': 'Рядом со мной',
      'view_all': 'Все',
      'popular_places': 'Популярные места',
      'recommended': 'Рекомендуемые',

      // Categories
      'cat_restaurant': 'Ресторан',
      'cat_game_club': 'Гейм клуб',
      'cat_barber': 'Барбершоп',
      'cat_beauty': 'Красота',
      'cat_sport': 'Спорт',
      'cat_coworking': 'Коворкинг',

      // Booking
      'book_now': 'Забронировать',
      'select_date': 'Выберите дату',
      'select_time': 'Выберите время',
      'guest_count': 'Количество гостей',
      'confirm_booking': 'Подтвердить бронь',
      'booking_success': 'Успешно забронировано!',
      'cancel_booking': 'Отменить бронь',
      'active_bookings': 'Активные брони',
      'booking_history': 'История броней',

      // Profile
      'my_profile': 'Мой профиль',
      'edit_profile': 'Редактировать профиль',
      'notifications': 'Уведомления',
      'select_language': 'Выбрать язык',
      'dark_mode': 'Темная тема',
      'help_center': 'Центр поддержки',
      'terms_of_service': 'Условия использования',
      'privacy_policy': 'Политика конфиденциальности',

      // Common
      'cancel': 'Отмена',
      'save': 'Сохранить',
      'apply': 'Применить',
      'retry': 'Повторить',
      'loading': 'Загрузка...',
      'no_data': 'Данные не найдены',
      'network_error': 'Нет подключения к интернету',
      'server_error': 'Ошибка сервера',
      'unknown_error': 'Произошла неизвестная ошибка',
    },

    // --- ENGLISH ---
    'en': {
      // Auth
      'login': 'Log In',
      'register': 'Sign Up',
      'phone_number': 'Phone Number',
      'enter_phone_number': 'Enter your phone number',
      'password': 'Password',
      'enter_password': 'Enter your password',
      'forgot_password': 'Forgot password?',
      'verify_otp': 'Verification Code',
      'otp_sent_to': 'Verification code sent to',
      'resend_otp': 'Resend Code',
      'logout': 'Log Out',

      // Navigation
      'nav_home': 'Home',
      'nav_map': 'Map',
      'nav_search': 'Search',
      'nav_bookings': 'Bookings',
      'nav_favorites': 'Favorites',
      'nav_profile': 'Profile',

      // Home & Search
      'city_tashkent': 'Tashkent',
      'search_placeholder': 'Restaurant, food or venue...',
      'today': 'Today',
      'tomorrow': 'Tomorrow',
      'persons_count': 'guests',
      'near_me': 'Nearby',
      'view_all': 'View All',
      'popular_places': 'Popular Places',
      'recommended': 'Recommended',

      // Categories
      'cat_restaurant': 'Restaurant',
      'cat_game_club': 'Game Club',
      'cat_barber': 'Barbershop',
      'cat_beauty': 'Beauty',
      'cat_sport': 'Sport',
      'cat_coworking': 'Coworking',

      // Booking
      'book_now': 'Book Now',
      'select_date': 'Select Date',
      'select_time': 'Select Time',
      'guest_count': 'Number of Guests',
      'confirm_booking': 'Confirm Booking',
      'booking_success': 'Booking Confirmed!',
      'cancel_booking': 'Cancel Booking',
      'active_bookings': 'Active Bookings',
      'booking_history': 'Booking History',

      // Profile
      'my_profile': 'My Profile',
      'edit_profile': 'Edit Profile',
      'notifications': 'Notifications',
      'select_language': 'Choose Language',
      'dark_mode': 'Dark Mode',
      'help_center': 'Help & Support',
      'terms_of_service': 'Terms of Service',
      'privacy_policy': 'Privacy Policy',

      // Common
      'cancel': 'Cancel',
      'save': 'Save',
      'apply': 'Apply',
      'retry': 'Retry',
      'loading': 'Loading...',
      'no_data': 'No data found',
      'network_error': 'No internet connection',
      'server_error': 'Server error occurred',
      'unknown_error': 'An unexpected error occurred',
    },
  };
}

import 'auth_token_entity.dart';

/// `POST /auth/telegram/start` javobi — mijoz/00-kirish-va-profil.md §2.1.
class TelegramLoginStart {
  final String nonce;
  final String deepLink;
  final int expiresIn;
  final int pollAfterSeconds;

  const TelegramLoginStart({
    required this.nonce,
    required this.deepLink,
    required this.expiresIn,
    required this.pollAfterSeconds,
  });

  factory TelegramLoginStart.fromJson(Map<String, dynamic> json) {
    return TelegramLoginStart(
      nonce: json['nonce']?.toString() ?? '',
      deepLink: json['deep_link']?.toString() ?? '',
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 300,
      pollAfterSeconds: (json['poll_after_seconds'] as num?)?.toInt() ?? 2,
    );
  }
}

/// `GET /auth/telegram/status/{nonce}` natijasi — §2.2, §2.4.
/// `expired` — 404 (`nonce` eskirgan yoki token allaqachon olingan).
enum TelegramLoginPollStatus { pending, success, expired }

class TelegramLoginPollResult {
  final TelegramLoginPollStatus status;
  final AuthTokenEntity? token;

  const TelegramLoginPollResult({required this.status, this.token});
}

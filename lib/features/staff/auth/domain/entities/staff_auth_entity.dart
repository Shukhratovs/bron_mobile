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

enum TelegramLoginPollStatus { pending, success, staffNotFound, loginExpired }

class TelegramLoginPollResult {
  final TelegramLoginPollStatus status;
  final StaffTokenOut? token;

  const TelegramLoginPollResult({required this.status, this.token});
}

class StaffTokenOut {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String role;
  final String organizationId;
  final String? venueId;

  const StaffTokenOut({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.role,
    required this.organizationId,
    this.venueId,
  });

  factory StaffTokenOut.fromJson(Map<String, dynamic> json) {
    return StaffTokenOut(
      accessToken: json['access_token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? 'bearer',
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 86400,
      role: json['role']?.toString() ?? '',
      organizationId: json['organization_id']?.toString() ?? '',
      venueId: json['venue_id'] as String?,
    );
  }
}

class StaffVenueEntity {
  final String id;
  final String name;
  final String kind;
  final String? district;
  final String status;
  final bool isPrimary;

  const StaffVenueEntity({
    required this.id,
    required this.name,
    required this.kind,
    this.district,
    required this.status,
    this.isPrimary = false,
  });

  factory StaffVenueEntity.fromJson(Map<String, dynamic> json) {
    return StaffVenueEntity(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      kind: json['kind']?.toString() ?? '',
      district: json['district'] as String?,
      status: json['status']?.toString() ?? 'faol',
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }
}

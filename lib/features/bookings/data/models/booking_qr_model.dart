class BookingQrModel {
  final String code;
  final String token;
  final int expiresIn;

  const BookingQrModel({
    required this.code,
    required this.token,
    required this.expiresIn,
  });

  factory BookingQrModel.fromJson(Map<String, dynamic> json) {
    return BookingQrModel(
      code: json['code']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 30,
    );
  }
}

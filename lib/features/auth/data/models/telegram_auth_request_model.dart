class TelegramAuthRequestModel {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? photoUrl;
  final int? authDate;
  final String? hash;
  final String? phone;

  const TelegramAuthRequestModel({
    required this.id,
    this.firstName,
    this.lastName,
    this.username,
    this.photoUrl,
    this.authDate,
    this.hash,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
    };
    if (firstName != null) map['first_name'] = firstName;
    if (lastName != null) map['last_name'] = lastName;
    if (username != null) map['username'] = username;
    if (photoUrl != null) map['photo_url'] = photoUrl;
    if (authDate != null) map['auth_date'] = authDate;
    if (hash != null) map['hash'] = hash;
    if (phone != null) map['phone'] = phone;
    return map;
  }
}

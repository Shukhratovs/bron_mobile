enum WaitlistStatus {
  kutmoqda,
  chaqirilgan,
  joylashtirildi,
  otkazibYuborildi,
  chiqarildi,
  unknown,
}

class WaitlistEntity {
  final String id;
  final String kind; // jonli | buyurtma
  final WaitlistStatus status;
  final String? guestName;
  final String? guestPhone;
  final int guests;
  final DateTime? desiredFrom;
  final DateTime? desiredTo;
  final int position;
  final int waitingMinutes;
  final int estimatedWaitMinutes;
  final DateTime? expiresAt;
  final String? offeredTable;
  final String? bookingId;
  final DateTime? createdAt;

  const WaitlistEntity({
    required this.id,
    required this.kind,
    required this.status,
    this.guestName,
    this.guestPhone,
    required this.guests,
    this.desiredFrom,
    this.desiredTo,
    this.position = 0,
    this.waitingMinutes = 0,
    this.estimatedWaitMinutes = 0,
    this.expiresAt,
    this.offeredTable,
    this.bookingId,
    this.createdAt,
  });

  static WaitlistStatus parseStatus(String? value) {
    switch (value) {
      case 'kutmoqda':
        return WaitlistStatus.kutmoqda;
      case 'chaqirilgan':
        return WaitlistStatus.chaqirilgan;
      case 'joylashtirildi':
        return WaitlistStatus.joylashtirildi;
      case 'otkazib_yuborildi':
        return WaitlistStatus.otkazibYuborildi;
      case 'chiqarildi':
        return WaitlistStatus.chiqarildi;
      default:
        return WaitlistStatus.unknown;
    }
  }
}

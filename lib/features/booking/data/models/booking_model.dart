class BookingModel {
  final String bookingId;
  final String venueName;
  final String address;
  final String date;
  final String time;
  final int guestCount;
  final String tableZone;
  final String depositAmount;
  final String cardNumber;
  final String qrCodeData;

  const BookingModel({
    required this.bookingId,
    required this.venueName,
    required this.address,
    required this.date,
    required this.time,
    required this.guestCount,
    required this.tableZone,
    required this.depositAmount,
    required this.cardNumber,
    required this.qrCodeData,
  });

  static BookingModel get mockBooking => const BookingModel(
        bookingId: 'BRN-4831',
        venueName: 'Osteria Da Vinci',
        address: 'Mustaqillik ko\'chasi 12',
        date: '27-iyul, yakshanba',
        time: '19:00',
        guestCount: 4,
        tableZone: '12 - deraza yonida',
        depositAmount: '150 000 so\'m',
        cardNumber: 'UZCARD •••• 4821',
        qrCodeData: 'https://bron.uz/booking/BRN-4831',
      );
}

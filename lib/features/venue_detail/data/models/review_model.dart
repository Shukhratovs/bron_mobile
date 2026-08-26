class ReviewModel {
  final String id;
  final String authorName;
  final String? avatarUrl;
  final double rating;
  final String date;
  final String comment;

  const ReviewModel({
    required this.id,
    required this.authorName,
    this.avatarUrl,
    required this.rating,
    required this.date,
    required this.comment,
  });

  static List<ReviewModel> get mockReviews => const [
        ReviewModel(
          id: '1',
          authorName: 'Aziz Karimov',
          rating: 5.0,
          date: '2 kun oldin',
          comment:
              'Ajoyib restoran! Ovqatlar juda mazali, xizmat ko\'rsatish yuqori darajada. Bron qilish juda oson bo\'ldi.',
        ),
        ReviewModel(
          id: '2',
          authorName: 'Madina U.',
          rating: 4.8,
          date: '1 hafta oldin',
          comment:
              'Muhit yoqimli, pasta va tiramisu ajoyib. Joyimiz vaqtida tayyor bo\'lib turgan edi.',
        ),
        ReviewModel(
          id: '3',
          authorName: 'Jasur Bek',
          rating: 5.0,
          date: '2 hafta oldin',
          comment:
              'Toshkentdagi eng sevimli joyimiz. Tavsiya qilaman!',
        ),
      ];
}

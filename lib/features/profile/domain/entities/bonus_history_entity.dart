enum BonusTransactionType {
  earned,
  spent,
}

class BonusHistoryEntity {
  final String id;
  final String title;
  final String date;
  final int amount;
  final BonusTransactionType type;

  const BonusHistoryEntity({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
  });
}

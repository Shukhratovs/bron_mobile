import '../../domain/entities/bonus_history_entity.dart';

class BonusHistoryModel extends BonusHistoryEntity {
  const BonusHistoryModel({
    required super.id,
    required super.title,
    required super.date,
    required super.amount,
    required super.type,
  });

  factory BonusHistoryModel.fromJson(Map<String, dynamic> json) {
    return BonusHistoryModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      date: json['date'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      type: json['type'] == 'spent'
          ? BonusTransactionType.spent
          : BonusTransactionType.earned,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'amount': amount,
      'type': type.name,
    };
  }
}

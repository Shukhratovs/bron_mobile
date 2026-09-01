import '../../domain/entities/card_entity.dart';

class CardModel extends CardEntity {
  const CardModel({
    required super.id,
    required super.provider,
    required super.cardType,
    required super.maskedPan,
    required super.isDefault,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id']?.toString() ?? '',
      provider: json['provider']?.toString() ?? '',
      cardType: json['card_type']?.toString() ?? '',
      maskedPan: json['masked_pan']?.toString() ?? '',
      isDefault: json['is_default'] as bool? ?? false,
    );
  }
}

sealed class BindCardResult {
  const BindCardResult();
}

class BindCardSuccess extends BindCardResult {
  final CardModel card;
  const BindCardSuccess(this.card);
}

class BindCardSmsRequired extends BindCardResult {
  final String bindingId;
  final String maskedPan;
  const BindCardSmsRequired({required this.bindingId, required this.maskedPan});
}

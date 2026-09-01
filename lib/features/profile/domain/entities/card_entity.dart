class CardEntity {
  final String id;
  final String provider;
  final String cardType;
  final String maskedPan;
  final bool isDefault;

  const CardEntity({
    required this.id,
    required this.provider,
    required this.cardType,
    required this.maskedPan,
    required this.isDefault,
  });
}

class CardBindingRequired {
  final String bindingId;
  final String maskedPan;

  const CardBindingRequired({required this.bindingId, required this.maskedPan});
}

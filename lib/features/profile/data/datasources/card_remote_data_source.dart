import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/card_model.dart';

abstract class CardRemoteDataSource {
  Future<List<CardModel>> getCards();
  Future<BindCardResult> addCard({
    required String pan,
    required String expiry,
    required String holder,
    bool isDefault = false,
  });
  Future<CardModel> confirmCard({
    required String bindingId,
    required String code,
    bool isDefault = false,
  });
  Future<void> setDefaultCard(String cardId);
  Future<void> deleteCard(String cardId);
}

class CardRemoteDataSourceImpl implements CardRemoteDataSource {
  final ApiClient apiClient;

  CardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CardModel>> getCards() async {
    final response = await apiClient.get(ApiEndpoints.cards);
    if (response is List) {
      return response
          .map((e) => CardModel.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }

  @override
  Future<BindCardResult> addCard({
    required String pan,
    required String expiry,
    required String holder,
    bool isDefault = false,
  }) async {
    final response = await apiClient.post(ApiEndpoints.cards, body: {
      'pan': pan,
      'expiry': expiry,
      'holder': holder,
      'is_default': isDefault,
    });
    final map = (response as Map).cast<String, dynamic>();
    if (map['status'] == 'sms_kerak') {
      return BindCardSmsRequired(
        bindingId: map['binding_id']?.toString() ?? '',
        maskedPan: map['masked_pan']?.toString() ?? '',
      );
    }
    return BindCardSuccess(CardModel.fromJson(map));
  }

  @override
  Future<CardModel> confirmCard({
    required String bindingId,
    required String code,
    bool isDefault = false,
  }) async {
    final response = await apiClient.post(ApiEndpoints.cardsConfirm, body: {
      'binding_id': bindingId,
      'code': code,
      'is_default': isDefault,
    });
    return CardModel.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<void> setDefaultCard(String cardId) async {
    await apiClient.patch(ApiEndpoints.cardById(cardId), body: {'is_default': true});
  }

  @override
  Future<void> deleteCard(String cardId) async {
    await apiClient.delete(ApiEndpoints.cardById(cardId));
  }
}

import '../../../../core/network/api_result.dart';
import '../../data/models/card_model.dart';
import '../entities/card_entity.dart';

abstract class CardRepository {
  Future<ApiResult<List<CardEntity>>> getCards();
  Future<ApiResult<BindCardResult>> addCard({
    required String pan,
    required String expiry,
    required String holder,
    bool isDefault = false,
  });
  Future<ApiResult<CardEntity>> confirmCard({
    required String bindingId,
    required String code,
    bool isDefault = false,
  });
  Future<ApiResult<bool>> setDefaultCard(String cardId);
  Future<ApiResult<bool>> deleteCard(String cardId);
}

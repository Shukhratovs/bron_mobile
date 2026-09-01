import '../../../../core/network/api_result.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/card_remote_data_source.dart';
import '../models/card_model.dart';

class CardRepositoryImpl implements CardRepository {
  final CardRemoteDataSource remoteDataSource;

  CardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<List<CardEntity>>> getCards() async {
    try {
      final cards = await remoteDataSource.getCards();
      return ApiResult.success(cards);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<BindCardResult>> addCard({
    required String pan,
    required String expiry,
    required String holder,
    bool isDefault = false,
  }) async {
    try {
      final result = await remoteDataSource.addCard(
        pan: pan,
        expiry: expiry,
        holder: holder,
        isDefault: isDefault,
      );
      return ApiResult.success(result);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<CardEntity>> confirmCard({
    required String bindingId,
    required String code,
    bool isDefault = false,
  }) async {
    try {
      final card = await remoteDataSource.confirmCard(
        bindingId: bindingId,
        code: code,
        isDefault: isDefault,
      );
      return ApiResult.success(card);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<bool>> setDefaultCard(String cardId) async {
    try {
      await remoteDataSource.setDefaultCard(cardId);
      return ApiResult.success(true);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<bool>> deleteCard(String cardId) async {
    try {
      await remoteDataSource.deleteCard(cardId);
      return ApiResult.success(true);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }
}

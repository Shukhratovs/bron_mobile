import '../../../../core/network/api_result.dart';
import '../../../../core/network/network_exceptions.dart';
import '../datasources/review_remote_data_source.dart';
import '../models/review_model.dart';

abstract class ReviewRepository {
  Future<ApiResult<ReviewPage>> getVenueReviews(String venueId, {int limit = 20, int offset = 0});
  Future<ApiResult<ReviewModel>> createReview(String bookingId, {required int rating, String? text});
  Future<ApiResult<ReviewModel>> updateReview(String bookingId, {int? rating, String? text});
}

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<ReviewPage>> getVenueReviews(String venueId, {int limit = 20, int offset = 0}) async {
    try {
      final page = await remoteDataSource.getVenueReviews(venueId, limit: limit, offset: offset);
      return ApiResult.success(page);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<ReviewModel>> createReview(String bookingId, {required int rating, String? text}) async {
    try {
      final review = await remoteDataSource.createReview(bookingId, rating: rating, text: text);
      return ApiResult.success(review);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<ReviewModel>> updateReview(String bookingId, {int? rating, String? text}) async {
    try {
      final review = await remoteDataSource.updateReview(bookingId, rating: rating, text: text);
      return ApiResult.success(review);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }
}

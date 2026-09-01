import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/review_model.dart';

class ReviewPage {
  final List<ReviewModel> items;
  final int total;

  const ReviewPage({required this.items, required this.total});
}

abstract class ReviewRemoteDataSource {
  Future<ReviewPage> getVenueReviews(String venueId, {int limit = 20, int offset = 0});
  Future<ReviewModel> createReview(String bookingId, {required int rating, String? text});
  Future<ReviewModel> updateReview(String bookingId, {int? rating, String? text});
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final ApiClient apiClient;

  ReviewRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ReviewPage> getVenueReviews(String venueId, {int limit = 20, int offset = 0}) async {
    final response = await apiClient.get('${ApiEndpoints.venueReviews(venueId)}?limit=$limit&offset=$offset');
    final map = (response as Map).cast<String, dynamic>();
    final items = (map['items'] as List?)
            ?.map((e) => ReviewModel.fromJson((e as Map).cast<String, dynamic>()))
            .toList() ??
        const <ReviewModel>[];
    return ReviewPage(items: items, total: (map['total'] as num?)?.toInt() ?? items.length);
  }

  @override
  Future<ReviewModel> createReview(String bookingId, {required int rating, String? text}) async {
    final response = await apiClient.post(
      ApiEndpoints.bookingReview(bookingId),
      body: {
        'rating': rating,
        if (text != null && text.isNotEmpty) 'text': text,
      },
    );
    return ReviewModel.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<ReviewModel> updateReview(String bookingId, {int? rating, String? text}) async {
    final response = await apiClient.patch(
      ApiEndpoints.bookingReview(bookingId),
      body: {
        if (rating != null) 'rating': rating,
        if (text != null) 'text': text,
      },
    );
    return ReviewModel.fromJson((response as Map).cast<String, dynamic>());
  }
}

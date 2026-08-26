import '../../../../core/network/api_result.dart';
import '../entities/onboarding_entity.dart';

abstract class OnboardingRepository {
  Future<ApiResult<List<OnboardingEntity>>> getOnboardingItems();
}

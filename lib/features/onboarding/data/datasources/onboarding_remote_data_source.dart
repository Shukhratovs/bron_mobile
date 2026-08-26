import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_client.dart';
import '../models/onboarding_model.dart';

abstract class OnboardingRemoteDataSource {
  Future<List<OnboardingModel>> getOnboardingItems();
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final ApiClient apiClient;

  OnboardingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<OnboardingModel>> getOnboardingItems() async {
    try {
      // Kelajakda API orqali olish mumkin:
      // final response = await apiClient.get(ApiEndpoints.onboarding);
      // return (response['data'] as List).map((e) => OnboardingModel.fromJson(e)).toList();

      // Namuna ma'lumotlar (Assets bilan to'liq bog'langan):
      return const [
        OnboardingModel(
          id: 1,
          title: AppStrings.onboardingTitle1,
          description: AppStrings.onboardingDesc1,
          imagePath: 'assets/images/onboarding_first.png',
        ),
        OnboardingModel(
          id: 2,
          title: AppStrings.onboardingTitle2,
          description: AppStrings.onboardingDesc2,
          imagePath: 'assets/images/onboarding_second.png',
        ),
        OnboardingModel(
          id: 3,
          title: AppStrings.onboardingTitle3,
          description: AppStrings.onboardingDesc3,
          imagePath: 'assets/images/onboarding_third.png',
        ),
        OnboardingModel(
          id: 4,
          title: AppStrings.onboardingTitle4,
          description: AppStrings.onboardingDesc4,
          imagePath: 'assets/images/onboarding_fourth.png',
        ),
        OnboardingModel(
          id: 5,
          title: AppStrings.onboardingTitle5,
          description: AppStrings.onboardingDesc5,
          imagePath: 'assets/images/onboarding_fifth.png',
        ),
      ];
    } catch (e) {
      rethrow;
    }
  }
}

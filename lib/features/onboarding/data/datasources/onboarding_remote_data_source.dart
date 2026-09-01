import '../../../../core/constants/app_assets.dart';
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
      return const [
        OnboardingModel(
          id: 1,
          title: AppStrings.onboardingTitle1,
          description: AppStrings.onboardingDesc1,
          imagePath: AppAssets.onboardingFirst,
        ),
        OnboardingModel(
          id: 2,
          title: AppStrings.onboardingTitle2,
          description: AppStrings.onboardingDesc2,
          imagePath: AppAssets.onboardingSecond,
        ),
        OnboardingModel(
          id: 3,
          title: AppStrings.onboardingTitle3,
          description: AppStrings.onboardingDesc3,
          imagePath: AppAssets.onboardingThird,
        ),
        OnboardingModel(
          id: 4,
          title: AppStrings.onboardingTitle4,
          description: AppStrings.onboardingDesc4,
          imagePath: AppAssets.onboardingFourth,
        ),
        OnboardingModel(
          id: 5,
          title: AppStrings.onboardingTitle5,
          description: AppStrings.onboardingDesc5,
          imagePath: AppAssets.onboardingFifth,
        ),
      ];
    } catch (e) {
      rethrow;
    }
  }
}

import '../../core/constants/app_strings.dart';

/// `kind` — backend enum: `restoran · geym_klub · sartaroshxona · gozallik_saloni`.
String venueKindLabel(String kind) {
  switch (kind) {
    case 'restoran':
      return AppStrings.categoryRestoran;
    case 'geym_klub':
      return AppStrings.categoryGeymKlub;
    case 'sartaroshxona':
      return AppStrings.categorySartaroshxona;
    case 'gozallik_saloni':
      return AppStrings.categoryGozallikSaloni;
    default:
      return kind;
  }
}

List<(String, String)> get venueKindOptions => [
  ('restoran', AppStrings.categoryRestoran),
  ('geym_klub', AppStrings.categoryGeymKlub),
  ('sartaroshxona', AppStrings.categorySartaroshxona),
  ('gozallik_saloni', AppStrings.categoryGozallikSaloni),
];

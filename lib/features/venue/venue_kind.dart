/// `kind` — backend enum: `restoran · geym_klub · sartaroshxona · gozallik_saloni`.
/// Faqat `restoran` to'liq ishlaydi (`00-boshlash.md` §4) — qolganlari
/// vertikal chiplarida ko'rinadi, lekin natija bermaydi.
String venueKindLabel(String kind) {
  switch (kind) {
    case 'restoran':
      return 'Restoran';
    case 'geym_klub':
      return 'Geym klub';
    case 'sartaroshxona':
      return 'Sartaroshxona';
    case 'gozallik_saloni':
      return 'Go\'zallik saloni';
    default:
      return kind;
  }
}

const List<(String, String)> venueKindOptions = [
  ('restoran', 'Restoran'),
  ('geym_klub', 'Geym klub'),
  ('sartaroshxona', 'Sartaroshxona'),
  ('gozallik_saloni', 'Go\'zallik saloni'),
];

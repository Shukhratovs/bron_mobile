import 'dart:io';
import 'package:flutter/material.dart';

/// Android'da pastki tizim navigatsiyasi klassik "3 tugmali" rejimda
/// ekanini aniqlaydi.
///
/// Imo-ishora (gesture) navigatsiyada orqaga qaytish imo-ishorasi uchun
/// pastki hudud `padding.bottom`dan kengroq bo'ladi (`systemGestureInsets`
/// katta), 3 tugmali panelda esa ikkalasi teng bo'ladi — butun balandlikni
/// statik tugmalar egallaydi va qo'shimcha imo-ishora zonasi yo'q.
///
/// iOS'da har doim `false` — u yerda bunday rejimlar farqi yo'q va
/// mavjud "home indicator" bilan bog'liq bo'shliq allaqachon to'g'ri
/// ishlaydi.
bool isThreeButtonAndroidNav(BuildContext context) {
  if (!Platform.isAndroid) return false;
  final mq = MediaQuery.of(context);
  if (mq.padding.bottom <= 0) return false;
  return mq.systemGestureInsets.bottom <= mq.padding.bottom;
}

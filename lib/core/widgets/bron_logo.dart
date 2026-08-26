import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BronLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final bool isDarkText;

  const BronLogo({
    super.key,
    this.width,
    this.height,
    this.isDarkText = false,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      isDarkText ? 'assets/icons/logo_dark.svg' : 'assets/icons/logo.svg',
      width: width ?? 86.w,
      height: height ?? 32.h,
      fit: BoxFit.contain,
    );
  }
}

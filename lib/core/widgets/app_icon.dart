import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// `Icon(IconData)`ning SVG ekvivalenti — bir xil `size`/`color` API bilan,
/// lekin Material glif o'rniga `assets/icons/`dagi Figma dizayn tizimidan
/// (Remix Icon) olingan haqiqiy SVG'ni chizadi.
class AppIcon extends StatelessWidget {
  final String asset;
  final double? size;
  final Color? color;

  const AppIcon(this.asset, {super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final resolvedSize = size ?? iconTheme.size ?? 24;
    final resolvedColor = color ?? iconTheme.color;
    return SvgPicture.asset(
      asset,
      width: resolvedSize,
      height: resolvedSize,
      colorFilter: resolvedColor != null ? ColorFilter.mode(resolvedColor, BlendMode.srcIn) : null,
    );
  }
}

import 'package:flutter/material.dart';

import '../../colors/app_colors.dart';
import '../../dimens/dimens.dart';

class CurvedHeader extends StatelessWidget {
  static const _padding = EdgeInsets.only(top: kToolbarHeight);

  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Widget? child;
  final Alignment? alignment;

  const CurvedHeader({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.gradient,
    this.child,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final flavorsGradient = AppColors.backgroundGradient;
    return Container(
      width: width ?? double.infinity,
      height: height ?? MediaQuery.of(context).size.height * .3,
      margin: EdgeInsets.zero,
      alignment: alignment,
      padding: padding ?? _padding,
      decoration: BoxDecoration(
        gradient: gradient ?? flavorsGradient,
        borderRadius: borderRadius ??
            BorderRadius.only(
              bottomLeft: Radius.circular(Dimens.curvedHeaderRadius),
            ),
      ),
      child: child,
    );
  }
}

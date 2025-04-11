import 'dart:ui';

import 'package:flutter/material.dart';

import '../../colors/app_colors.dart';
import '../../dimens/dimens.dart';

class BlurContainer extends StatelessWidget {
  static final _borderRadius = BorderRadius.circular(20);
  static final _border = Border.all(color: Colors.white, width: 2);
  static final _imageFilter = ImageFilter.blur(sigmaX: 15, sigmaY: 15);
  static final _boxShadow = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 20.0,
      spreadRadius: 2.0,
    ),
  ];
  static final _padding = EdgeInsets.fromLTRB(
      Dimens.mediumVerticalMargin,
      Dimens.mediumHorizontalMargin,
      Dimens.mediumVerticalMargin,
      Dimens.buttonHeight);
  static final _margin = EdgeInsets.fromLTRB(
      Dimens.smallHorizontalMargin,
      Dimens.smallVerticalMargin,
      Dimens.smallHorizontalMargin,
      Dimens.buttonHeight);

  final double? width;
  final double? height;
  final BoxConstraints? boxConstraints;
  final Color background;
  final Border? border;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final ImageFilter? imageFilter;
  final List<BoxShadow>? boxShadow;
  final Widget? child;

  const BlurContainer({
    super.key,
    this.width,
    this.height,
    this.boxConstraints,
    this.background = Colors.white60,
    this.border,
    this.padding,
    this.margin,
    this.borderRadius,
    this.imageFilter,
    this.boxShadow,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin ?? _margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? _borderRadius,
        boxShadow: boxShadow ?? _boxShadow,
      ),
      constraints: boxConstraints,
      child: ClipRRect(
        borderRadius: borderRadius ?? _borderRadius,
        child: BackdropFilter(
          filter: imageFilter ?? _imageFilter,
          child: Container(
            decoration: BoxDecoration(
              color: background,
              borderRadius: borderRadius ?? _borderRadius,
              border: border ?? _border,
            ),
            padding: padding ?? _padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

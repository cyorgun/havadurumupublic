import 'package:flutter/material.dart';

import '../../colors/app_colors.dart';
import '../../dimens/dimens.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final bool isDisabled;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? Dimens.buttonHeight,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(Dimens.buttonHeight / 2),
          boxShadow: [
            BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 5.0,
                spreadRadius: 2.0,
                offset: const Offset(0, 2))
          ]),
      child: Container(
        color: isDisabled ? Colors.white38 : Colors.transparent,
        child: TextButton(
          onPressed: isDisabled ? null : onPressed,
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.textColor,
              letterSpacing: 1.4,
              fontWeight: FontWeight.bold,
              fontSize: Dimens.mediumFontSize,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

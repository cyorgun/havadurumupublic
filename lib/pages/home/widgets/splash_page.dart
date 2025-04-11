import 'package:flutter/material.dart';

import '../../../colors/app_colors.dart';
import '../../../dimens/dimens.dart';
import '../../../shared/custom_widgets/circular_image.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: Center(
            child: CircularImage(
          imageAddress: 'assets/images/icon.png',
          height: Dimens.splashLogoSize,
          width: Dimens.splashLogoSize,
        )),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CircularImage extends StatelessWidget {
  final String imageAddress;
  final BoxFit fit;
  final Color? splashColor;
  final bool isClickable;
  final double height;
  final double width;

  const CircularImage({
    super.key,
    required this.imageAddress,
    this.fit = BoxFit.fitHeight,
    this.splashColor,
    this.isClickable = false,
    this.height = 50.0,
    this.width = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: InkWell(
        splashColor: splashColor,
        onTap: isClickable ? () {} : null,
        child: Ink.image(
          image: AssetImage(
            imageAddress,
          ),
          fit: fit,
          height: height,
          width: width,
        ),
      ),
    );
  }
}

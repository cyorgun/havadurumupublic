import 'package:flutter/material.dart';

class AppColors {
  static LinearGradient get splashGradient => LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          mainColor,
          mainColor2,
        ],
      );

  static LinearGradient get backgroundGradient => LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        stops: const [0, 0.5],
        colors: [
          mainColor,
          mainColor2,
        ],
      );

  static LinearGradient get buttonGradient => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: [0, 1],
        colors: [Color(0xf4083d56), Color(0xda375881)],
      );

  static Color get mainColor => const Color(0xf4083d56);

  static Color get mainColor2 => const Color(0xda375881);

  static Color get rainColor => const Color(0xffb3c7d0);

  static Color get darkBackground => const Color(0xff313131);

  static Color get textButtonColor => mainColor;

  static Color shadowColor = const Color(0xff000000).withOpacity(.1);

  static Color textColor = Colors.white;

  static Color background = Colors.white;

  static Color backgroundLayer = const Color(0x14000000);

  static Color temporaryForecastBackground = const Color(0xff76abcb);

  static LinearGradient get temporaryForecastBackgroundGradient =>
      const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        stops: [0, 0.5],
        colors: [Color(0xff659abb), Color(0xff9eb6cb)],
      );

  static LinearGradient get maxMinBarColor => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0, 1],
        colors: [Colors.red, Colors.blue],
      );

  static Color dividerColor = Color(0xff0a6b79);

  static Color iconColor = Colors.white;

  static Color iconColor2 = const Color(0xffcbcbcb);

  static Color activeIconColor = const Color(0xff31d0b8);

  static Color inputIconColor = const Color(0xffC3CFDA);

  static Color textFieldColor = const Color(0xff4B4B4B);
}

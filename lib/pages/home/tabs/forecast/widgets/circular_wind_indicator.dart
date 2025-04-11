import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../../colors/app_colors.dart';
import '../../../../../dimens/dimens.dart';

class CircularWindIndicator extends StatelessWidget {
  final double angle; // Derece cinsinden açı bilgisi
  final String text; // Çemberin içine yazılacak metin

  const CircularWindIndicator(
      {super.key, required this.angle, required this.text});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(30, 30), // Çember boyutu
      painter: CircularPainter(angle, text),
    );
  }
}

class CircularPainter extends CustomPainter {
  final double angle; // Derece cinsinden açı bilgisi
  final String text;

  CircularPainter(this.angle, this.text);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint circlePaint = Paint()
      ..color = AppColors.iconColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final Paint indicatorPaint = Paint()
      ..color = AppColors.iconColor
      ..style = PaintingStyle.fill;

    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Çemberi çiz
    canvas.drawCircle(center, radius, circlePaint);

    // Açıya göre üçgen koordinatlarını hesapla
    final adjustedAngle = 360 - angle;
    double radians = adjustedAngle * pi / 180;
    double x = center.dx + radius * cos(radians);
    double y = center.dy + radius * sin(radians);

    // Üçgenin kenarlarını hesaplamak için ilk kenarı çiz
    double modifiedX = center.dx + radius * 2 / 3 * cos(radians);
    double modifiedY = center.dy + radius * 2 / 3 * sin(radians);

    double shortEdgeLength = 12.0; // Kenarın uzunluğu (8 birim)
    double largeEdgeLength = 18.0; // Kenarın uzunluğu (16 birim)

    // İlk kenar: angle yönünde 8 birim ilerle
    double x1 = modifiedX + largeEdgeLength * cos(radians);
    double y1 = modifiedY + largeEdgeLength * sin(radians);

    // İkinci kenar: 8 birim sola kay
    double x2 =
        modifiedX + shortEdgeLength * cos(radians - pi / 6); // -30 derece
    double y2 = modifiedY + shortEdgeLength * sin(radians - pi / 6);

    // Üçüncü kenar: 8 birim sağa kay
    double x3 =
        modifiedX + shortEdgeLength * cos(radians + pi / 6); // +30 derece
    double y3 = modifiedY + shortEdgeLength * sin(radians + pi / 6);

    // Üçgeni çizmek için Path oluşturuyoruz
    Path path = Path();
    path.moveTo(x1, y1); // İlk nokta (üst)
    path.lineTo(x2, y2); // İkinci nokta (sol alt)
    path.lineTo(x3, y3); // Üçüncü nokta (sağ alt)
    path.close(); // Üçgenin son noktasını ilk nokta ile kapat

    // Üçgeni çiziyoruz
    canvas.drawPath(path, indicatorPaint);

    // Çemberin ortasına metin yerleştirme
    TextSpan textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: AppColors.textColor,
        fontSize: Dimens.mediumFontSize,
        fontWeight: FontWeight.bold,
      ),
    );

    TextPainter textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    Offset textPosition = Offset(
        center.dx - textPainter.width / 2, center.dy - textPainter.height / 2);
    textPainter.paint(canvas, textPosition);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  double calculateBuffer(double value) {
    const double buffer = 0.0;
    const double neutralValue = 24.999999999999996;
    if (value < neutralValue) {
      return -buffer;
    } else if (value > neutralValue) {
      return buffer;
    } else {
      return 0.0;
    }
  }
}

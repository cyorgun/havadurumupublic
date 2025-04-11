import 'package:flutter/material.dart';

import '../../../../../colors/app_colors.dart';

class TemperatureBar extends StatelessWidget {
  final int? maxTemp;
  final int? minTemp;
  final int referenceMaxTemp;
  final int referenceMinTemp;
  final int height;

  const TemperatureBar({
    super.key,
    required this.maxTemp,
    required this.minTemp,
    required this.referenceMaxTemp,
    required this.referenceMinTemp,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (maxTemp == null || minTemp == null) {
      return Container();
    }
    final referenceTotalTemp = referenceMaxTemp.abs() + referenceMinTemp.abs();

    // Max ve min sıcaklık farkı
    double tempDifference = (maxTemp! - minTemp!).abs().toDouble();

    // Referansa göre üst boşluğu ayarla
    var oneDegreeHeight = height / referenceTotalTemp;
    double topPadding =
        (referenceMaxTemp - maxTemp!).toDouble() * oneDegreeHeight;

    // Çubuğun toplam yüksekliği, sıcaklık farkı kadar olacak
    double barHeight = tempDifference * oneDegreeHeight;

    return Column(
      children: [
        SizedBox(height: topPadding), // Referansa göre hizalama
        Text(
          "$maxTemp°",
          style: TextStyle(color: AppColors.textColor),
        ),
        const SizedBox(height: 6), // Referansa göre hizalama
        Container(
          width: 15, // İnce çubuk
          height: barHeight, // Çubuğun yüksekliği
          decoration: BoxDecoration(
            gradient: AppColors.maxMinBarColor,
            borderRadius: BorderRadius.circular(10), // Yuvarlatılmış köşeler
            color: Colors.white, // Beyaz renk
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "$minTemp°",
          style: TextStyle(color: Colors.grey.shade400),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InfoTooltip extends StatelessWidget {
  final String tooltipText = "farmerInfoButton".tr;

  InfoTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltipText,
      // Tooltip mesajını buraya ekliyoruz
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 10),
      // Tooltip tıklama ile tetiklenecek
      decoration: BoxDecoration(
        color: Colors.black87, // Tooltip arka plan rengi
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: Colors.white, // Tooltip metin rengi
        fontSize: 14,
      ),
      preferBelow: false,
      // Tooltip balonu yukarıda gözüksün
      verticalOffset: 20,
      // Tooltip'in konumunu biraz aşağıya kaydırıyoruz
      child: const Icon(
        Icons.info_outline, // İkon
        color: Colors.black, // İkonun rengi beyaz
      ),
    );
  }
}

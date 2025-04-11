import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:havadurumu/pages/home/tabs/forecast/controllers/forecast_controller.dart';

import '../../../../../colors/app_colors.dart';

class AnimatedFloatingPanel extends StatefulWidget {
  @override
  _AnimatedFloatingPanelState createState() => _AnimatedFloatingPanelState();
}

class _AnimatedFloatingPanelState extends State<AnimatedFloatingPanel>
    with SingleTickerProviderStateMixin {
  bool _isPanelVisible = false; // Panelin açık/kapalı durumu
  late AnimationController _controller; // Dönen animasyon için controller
  final ForecastController forecastController = Get.find<ForecastController>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() {
      _isPanelVisible = !_isPanelVisible;

      // Butonun dönme animasyonu
      if (_isPanelVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomRight,
          child: AnimatedOpacity(
            opacity: _isPanelVisible ? 1.0 : 0.0, // Şeffaflık animasyonu
            duration: Duration(milliseconds: 300),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.55,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundLayer, // Hafif şeffaf siyah
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12), // Sol üst köşe
                  topRight: Radius.circular(12), // Sağ üst köşe
                  bottomLeft: Radius.circular(12), // Sol alt köşe
                  bottomRight:
                      Radius.circular(32), // Sağ alt köşe (Daha büyük)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${"humidity".tr}: ${forecastController.newHourData.value?.humidity ?? forecastController.homeController.weatherData.value.current.humidity}",
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    "${"epaIndex".tr}: ${forecastController.homeController.weatherData.value.current.airQuality.usEpaIndex ?? ""}",
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    "${"uvIndex".tr}: ${forecastController.newHourData.value?.uv ?? forecastController.homeController.weatherData.value.current.uv}",
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    "${"precipitation".tr}: ${forecastController.newHourData.value?.precipMm ?? forecastController.homeController.weatherData.value.current.precipMm}",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 4 * pi, // 360 derece döndürme
                child: FloatingActionButton.small(
                  heroTag: "detailsButtonTag",
                  onPressed: _togglePanel,
                  shape: CircleBorder(),
                  backgroundColor: Colors.blue.shade200,
                  child: Icon(
                    _isPanelVisible ? Icons.close : Icons.more_horiz,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

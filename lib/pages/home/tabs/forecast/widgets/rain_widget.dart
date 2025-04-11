import 'package:flutter/material.dart';
import 'dart:math';

import '../../../../../colors/app_colors.dart';

class RainWidget extends StatefulWidget {
  final int intensity;

  const RainWidget({super.key, required this.intensity});

  @override
  _RainWidgetState createState() => _RainWidgetState();
}

class _RainWidgetState extends State<RainWidget>
    with SingleTickerProviderStateMixin {
  late List<RainDrop> rainDrops;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    rainDrops = []; // RainDrop nesneleri `MediaQuery` verisiyle oluşturulacak
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    // MediaQuery erişimi için bu metodu kullanıyoruz
    super.didChangeDependencies();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    rainDrops = List.generate(
      widget.intensity,
      (_) => RainDrop(
          intensity: widget.intensity,
          screenWidth: screenWidth,
          screenHeight: screenHeight),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: rainDrops.map((drop) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            drop.updatePosition();
            return Positioned(
              top: drop.top,
              left: drop.left,
              child: Transform.rotate(
                angle: pi / 8, // Hafif eğim
                child: Container(
                  width: drop.width,
                  height: drop.height,
                  decoration: BoxDecoration(
                    color: AppColors.rainColor,
                    borderRadius: BorderRadius.circular(10), // Oval şekil
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class RainDrop {
  final double screenWidth;
  final double screenHeight;
  final int intensity;

  double left;
  double top;
  double width = 3;
  double height = 9;
  double xVelocity;
  double yVelocity;

  RainDrop(
      {required this.intensity,
      required this.screenWidth,
      required this.screenHeight})
      : left = Random().nextDouble() * 1.4 * screenWidth,
        // Sağ kenardan başlayacak
        top = Random().nextDouble() * screenHeight,
        xVelocity = intensity * -4 / 25,
        // Sola doğru hız
        yVelocity = intensity * 4 / 11; // Aşağı doğru hız

  void updatePosition() {
    top += yVelocity; // Aşağı doğru hareket
    left += xVelocity; // Sola doğru hareket

    // Ekran dışına çıkarsa, yeniden başlat
    if (top > screenHeight || left < 0) {
      left = Random().nextBool()
          ? Random().nextDouble() * 1.4 * screenWidth // Üstten yeniden başlar
          : Random().nextDouble() *
              1.4 *
              screenWidth; // Sağ kenardan yeniden başlar
      top = Random().nextBool() ? 0 : Random().nextDouble() * screenHeight;
    }
  }
}

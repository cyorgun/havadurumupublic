import 'dart:math';
import 'package:flutter/material.dart';
import 'package:particles_flutter/component/particle/particle.dart';
import 'package:particles_flutter/particles_engine.dart';

class SnowWidget extends StatelessWidget {
  final int intensity;

  const SnowWidget({super.key, required this.intensity});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Particles(
          awayRadius: 150,
          particles: createSnowParticles(),
          height: screenHeight,
          width: screenWidth,
          onTapAnimation: false,
          awayAnimationDuration: const Duration(milliseconds: 100),
          awayAnimationCurve: Curves.linear,
          enableHover: true,
          hoverRadius: 90,
          connectDots: false,
        ),
      ],
    );
  }

  List<Particle> createSnowParticles() {
    var rng = Random();
    List<Particle> particles = [];

    for (int i = 0; i < intensity; i++) {
      double speedY = rng.nextDouble() * intensity * 4 + 200; // Y düşme hızı
      double speedX = (rng.nextDouble() - 0.5) *
          50; // Rastgele yana kayma (-25 ile 25 arası)

      particles.add(Particle(
        color: Colors.white.withOpacity(0.8),
        size: 4 + rng.nextDouble(), // Kar tanelerinin boyutları
        velocity: Offset(speedX, speedY), // Hem yatay hem dikey hareket
      ));
    }

    return particles;
  }
}

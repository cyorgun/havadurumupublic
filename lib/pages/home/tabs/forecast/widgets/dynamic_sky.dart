import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:havadurumu/local_packages/weatherapi/lib/weatherapi.dart';
import 'package:havadurumu/pages/home/tabs/forecast/widgets/rain_widget.dart';
import 'package:havadurumu/pages/home/tabs/forecast/widgets/snow_widget.dart';

import '../../../../../dimens/dimens.dart';
import '../../../controllers/home_controller.dart';

class DynamicSky extends StatefulWidget {
  final ForecastWeather weatherData;
  final Function(int?) onValueChanged; // Callback fonksiyon

  const DynamicSky({
    super.key,
    required this.weatherData,
    required this.onValueChanged,
  });

  @override
  _DynamicSkyState createState() => _DynamicSkyState();
}

class _DynamicSkyState extends State<DynamicSky> with TickerProviderStateMixin {
  late final List<Star> stars;
  final starNumber = 0;
  double scrollOffset = 1200.0; // Başlangıç öğlen: 1200 px
  double currentHour = 12.0; // Başlangıç saati: Öğlen
  ui.Image? sunImage;
  final Map<String, ui.Image> _cachedImages = {}; // Bulut görselleri için cache
  Map<int, List<Cloud>> cloudsByHour = {};
  List<int?> cloudDensityListPerHour = [];
  AnimationController? _animationController;
  Animation<double>? _inertiaAnimation;

  void _onScroll(DragUpdateDetails details) {
    _animationController?.stop(); // Inertial hareketi durdur
    setState(() {
      // Kaydırmayı 0 ile 2399 arasında sınırla
      scrollOffset = (scrollOffset - details.primaryDelta!).clamp(0.0, 2399.0);
      currentHour = (scrollOffset / 100) % 24; // Saati değiştir
    });

    widget.onValueChanged(currentHour.toInt()); // Parent'a bildir
  }

  void _onScrollEnd(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dx.abs() > 0) {
      double velocity = details.velocity.pixelsPerSecond.dx / 2;
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      );
      _inertiaAnimation = Tween<double>(
        begin: scrollOffset,
        end: (scrollOffset - velocity * 0.5).clamp(0.0, 2399.0),
      ).animate(
        CurvedAnimation(
          parent: _animationController!,
          curve: Curves.decelerate,
        ),
      )..addListener(() {
          setState(() {
            scrollOffset = _inertiaAnimation!.value;
            currentHour = (scrollOffset / 100) % 24;
          });
          widget.onValueChanged(currentHour.toInt());
        });
      _animationController?.forward();
    }
  }

  // Bulut görsellerini yükleme fonksiyonu
  Future<ui.Image> _loadCloudImage(String imagePath) async {
    if (_cachedImages.containsKey(imagePath)) {
      // Eğer görsel zaten yüklendiyse cache'ten al
      return _cachedImages[imagePath]!;
    }

    // Görseli yükle ve cache'e ekle
    final ByteData data = await rootBundle.load(imagePath);
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Image image = await decodeImageFromList(bytes);

    _cachedImages[imagePath] = image;
    return image;
  }

  int getHour(String? localtime) {
    if (localtime == null) {
      return 0;
    }
    DateTime dateTime = DateTime.parse(localtime);

    //TODO: hour ve minute'ı double şeklinde versin
    return dateTime.hour;
  }

  void initializeVariables(ForecastWeather? weatherData) {
    setState(() {
      if (weatherData == null) {
        // Başlangıç saatine göre offseti hesapla
        currentHour = getHour(widget.weatherData.location.localtime).toDouble();
        scrollOffset = currentHour * 100;
        cloudDensityListPerHour.clear();
        cloudDensityListPerHour = widget.weatherData.forecast[0].hour
            .map((it) => it.cloud != null ? (it.cloud! / 30).round() : 0)
            .toList();
      } else {
        // Başlangıç saatine göre offseti hesapla
        currentHour = getHour(weatherData.location.localtime).toDouble();
        scrollOffset = currentHour * 100;
        cloudDensityListPerHour.clear();
        cloudDensityListPerHour = weatherData.forecast[0].hour
            .map((it) => it.cloud != null ? (it.cloud! / 30).round() : 0)
            .toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final HomeController controller = Get.find<HomeController>();

    initializeVariables(null);
    _generateClouds();

    ever(controller.weatherData, (value) {
      initializeVariables(value);
      widget.onValueChanged(null);
      _generateClouds();
    });

    // Yıldızları yalnızca bir kez üret
    final Random random = Random();
    stars = List.generate(starNumber, (_) {
      return Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: random.nextDouble() * 2 + 1,
      );
    });

    // Güneş görselini yükle
    _loadSunImage();
    // Bulutları oluştur ve yükle
    _generateClouds();
  }

  // Bulutları oluştur ve yükle
  void _generateClouds() async {
    final Random random = Random();
    Map<int, List<Cloud>> tempCloudsByHour = {};

    // 24 saat için bulut kümelerini oluştur
    for (int hour = 0; hour < 24; hour++) {
      //TODO: siyah bulut ekleme var bir de sonradan eklenebilir.
      int cloudCount = cloudDensityListPerHour[hour] ?? 0;
      List<Cloud> hourClouds = [];
      //TODO: kasıp kasmamaya göre buradaki 20yi 100e kadar çıkarabilirsin
      for (int i = 0; i < cloudCount; i++) {
        String imagePath = 'assets/images/${random.nextInt(20) + 1}.png';
        double x = 0;
        double y = 0;
        double scale = random.nextDouble() * 0.5 + 0.75;

        // Görseli yükle ve saatin bulutlar listesine ekle
        ui.Image cloudImage = await _loadCloudImage(imagePath);
        hourClouds.add(Cloud(image: cloudImage, x: x, y: y, scale: scale));
      }
      tempCloudsByHour[hour] = hourClouds;
    }
    setState(() {
      cloudsByHour = tempCloudsByHour;
    });
  }

  Future<void> _loadSunImage() async {
    final ByteData data = await rootBundle.load('assets/images/sun.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Image image = await decodeImageFromList(bytes);
    setState(() {
      sunImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onPanDown: (details) {
              _animationController?.stop(); // Inertial hareketi durdur
            },
            onHorizontalDragUpdate: _onScroll,
            onHorizontalDragEnd: _onScrollEnd,
            child: Stack(
              children: [
                CustomPaint(
                  painter: SkyPainter(
                      hour: currentHour,
                      stars: stars,
                      sunImage: sunImage,
                      cloudsByHour: cloudsByHour),
                  size: const Size(double.infinity, double.infinity),
                ),
                getWeatherTypeWidget(),
              ],
            ),
          ),
          Positioned(
            bottom: Dimens.forecastTabMargin, // Sol alt köşe konumu
            left: Dimens.forecastTabMargin,
            child: SizedBox(
              width: 60,
              height: 30,
              child: FloatingActionButton(
                heroTag: 'nowButtonTag',
                onPressed: () {
                  // widget.weatherData.location.localtime'dan currentHour'u hesapla
                  int localTime =
                      getHour(widget.weatherData.location.localtime);

                  // Ekranı kaydır ve state'i güncelle
                  setState(() {
                    currentHour = localTime.toDouble();
                    scrollOffset = currentHour * 100;
                  });

                  // Parent'a değişikliği bildir
                  widget.onValueChanged(null);
                },
                child: Text(
                  "now".tr,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getWeatherTypeWidget() {
    HourData? hourData;
    try {
      hourData = widget.weatherData.forecast[0].hour
          .firstWhere((it) => getHour(it.time) == currentHour.floor());
    } catch (e) {
      return Container();
    }
    var weather = weatherMap[hourData.condition.code];
    if (weather == null) {
      return Container();
    }
    if (weather.weatherType == WeatherType.Rain ||
        weather.weatherType == WeatherType.Ice ||
        weather.weatherType == WeatherType.Thunder) {
      return RainWidget(intensity: weather.intensity * 10);
    } else if (weather.weatherType == WeatherType.Snow) {
      return SnowWidget(intensity: weather.intensity * 10);
    } else {
      return Container();
    }
  }
}

class SkyPainter extends CustomPainter {
  final double hour;
  final List<Star> stars;
  final ui.Image? sunImage;
  final Map<int, List<Cloud>> cloudsByHour;

  SkyPainter(
      {required this.hour,
      required this.stars,
      required this.sunImage,
      required this.cloudsByHour});

  // Saat bazlı bulutları çizer
  void _drawClouds(Canvas canvas, Size size) {
    if (cloudsByHour.isEmpty) return;

    int currentHour = hour.floor(); // Mevcut saat (tam kısmı)
    double hourTransition = hour - currentHour; // Geçiş yüzdesi (0-1 arası)

    // Geçiş ivmesini artırmak için easing fonksiyonu kullanalım
    double easingFactor = hourTransition *
        hourTransition *
        (3 - 2 * hourTransition); // Ease-in-out

    // Mevcut saat dilimi ve bir sonraki saat dilimi için bulutları çiz
    for (int hourToDraw = currentHour;
        hourToDraw <= currentHour + 1;
        hourToDraw++) {
      int actualHour = hourToDraw % 24; // Saat döngüsünü 24'e sınırla
      if (!cloudsByHour.containsKey(actualHour)) continue;

      double alphaFactor = 0.0;

      if (actualHour == 23) {
        alphaFactor = 1.0;
      } else if (hourToDraw == currentHour) {
        // Mevcut saat dilimi için alpha azalacak, ivme artacak
        alphaFactor = 1.0 -
            easingFactor; // Geçişin başında hızla azalacak, sonunda yavaşça 0 olacak
      } else {
        // Bir sonraki saat dilimi için alpha artacak, ivme artacak
        alphaFactor =
            easingFactor; // Geçişin başında yavaşça 0 olacak, sonunda hızla 1 olacak
      }

      for (Cloud cloud in cloudsByHour[actualHour]!) {
        double baseX = (actualHour + cloud.x - hour) * size.width;
        if (baseX > size.width || baseX < -size.width)
          continue; // Ekran dışıysa atla

        double cloudWidth = cloud.image.width * cloud.scale;
        double cloudHeight = cloud.image.height * cloud.scale;

        // Alpha değeri ile boyama
        Paint paint = Paint()..color = Colors.white.withOpacity(alphaFactor);

        canvas.drawImageRect(
          cloud.image,
          Rect.fromLTWH(0, 0, cloud.image.width.toDouble(),
              cloud.image.height.toDouble()),
          Rect.fromLTWH(baseX, cloud.y * size.height, cloudWidth, cloudHeight),
          paint,
        );
      }
    }
  }

  void _drawStars(Canvas canvas, Size size) {
    final Paint starPaint = Paint();

    for (Star star in stars) {
      double alpha = _calculateStarAlpha(hour);
      starPaint.color = Colors.white.withOpacity(alpha / 2);

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.radius,
        starPaint,
      );
    }
  }

  double _calculateStarAlpha(double hour) {
    if (hour < 6 || hour > 18) {
      double normalizedHour = hour <= 6 ? hour + 24 : hour.toDouble();
      double transition = sin((normalizedHour - 18) / 12 * pi).abs();
      return transition.clamp(0.0, 1.0);
    }
    return 0.0;
  }

  Color darkenColor(Color color, int intensity) {
    // intensity 0 ile 100 arasında bir değer almalı
    double factor = 1 - (intensity / 100);
    int r = (color.red * factor).toInt();
    int g = (color.green * factor).toInt();
    int b = (color.blue * factor).toInt();

    return Color.fromRGBO(r, g, b, 1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Map<int, List<Color>> skyGradients = {
      0: [
        darkenColor(Color(0xFF343442),
            cloudsByHour[0] == null ? 1 : cloudsByHour[0]!.length * 10),
        darkenColor(Color(0xFF383F48),
            cloudsByHour[0] == null ? 1 : cloudsByHour[0]!.length * 10)
      ],
      6: [
        darkenColor(Color(0xFF6B8D8B),
            cloudsByHour[6] == null ? 1 : cloudsByHour[6]!.length * 10),
        darkenColor(Color(0xFF89AFB2),
            cloudsByHour[6] == null ? 1 : cloudsByHour[6]!.length * 10)
      ],
      12: [
        darkenColor(Color(0xFF00BFFF),
            cloudsByHour[12] == null ? 1 : cloudsByHour[12]!.length * 10),
        darkenColor(Color(0xFFB1DBEC),
            cloudsByHour[12] == null ? 1 : cloudsByHour[12]!.length * 10)
      ],
      18: [
        darkenColor(Color(0xFF6B8D8B),
            cloudsByHour[18] == null ? 1 : cloudsByHour[18]!.length * 10),
        darkenColor(Color(0xFF89AFB2),
            cloudsByHour[18] == null ? 1 : cloudsByHour[18]!.length * 10)
      ],
      24: [
        darkenColor(Color(0xFF353541),
            cloudsByHour[24] == null ? 1 : cloudsByHour[24]!.length * 10),
        darkenColor(Color(0xFF363B46),
            cloudsByHour[24] == null ? 1 : cloudsByHour[24]!.length * 10)
      ],
    };

    //sky color start
    int startHour = (hour ~/ 6) * 6;
    int endHour = startHour + 6;

    List<Color> startColors = skyGradients[startHour]!;
    List<Color> endColors = skyGradients[endHour]!;

    double t = (hour % 6) / 6;

    Color interpolatedTopColor = Color.lerp(startColors[0], endColors[0], t)!;
    Color interpolatedBottomColor =
        Color.lerp(startColors[1], endColors[1], t)!;

    final Paint skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [interpolatedTopColor, interpolatedBottomColor],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);
    //sky color end

    //stars
    _drawStars(canvas, size);

    //start of sun/moon
    final double celestialBodyPosition =
        size.height / 2 + sin((hour / 24) * 2 * pi) * (size.height / 2);

    if (hour < 6 || hour > 18) {
      final Paint moonPaint = Paint()..color = Colors.grey.shade300;
      canvas.drawCircle(
        Offset(size.width / 2, size.height * 1 - celestialBodyPosition),
        25,
        moonPaint,
      );

      final Paint moonGlowPaint = Paint()
        ..color = Colors.grey.shade300.withOpacity(0.1);
      canvas.drawCircle(
        Offset(size.width / 2, size.height * 1 - celestialBodyPosition),
        50,
        moonGlowPaint,
      );
    } else {
      if (sunImage != null) {
        var angle = hour * 15;
        const double sunSize = 200.0;

        canvas.save(); // Canvas'ın mevcut durumunu kaydeder
        canvas.translate(
            size.width / 2,
            size.height * 1 -
                celestialBodyPosition); // Döndürme merkezini ayarlamak için taşıma işlemi
        canvas.rotate(angle *
            3.141592653589793 /
            180); // 20 dereceyi radyana çevirerek döndürme işlemi
        canvas.translate(
            -size.width / 2,
            -(size.height * 1 -
                celestialBodyPosition)); // Taşınan canvas'ı geri alır

        canvas.drawImageRect(
          sunImage!,
          Rect.fromLTWH(
              0, 0, sunImage!.width.toDouble(), sunImage!.height.toDouble()),
          Rect.fromCenter(
            center:
                Offset(size.width / 2, size.height * 1 - celestialBodyPosition),
            width: sunSize,
            height: sunSize,
          ),
          Paint(),
        );
        canvas.restore(); // Canvas'ı önceki kaydedilmiş duruma döndürür
      }
    }
    //end of sun/moon

    //clouds
    _drawClouds(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Star {
  final double x;
  final double y;
  final double radius;

  Star({required this.x, required this.y, required this.radius});
}

class Cloud {
  final ui.Image image;
  final double x;
  final double y;
  final double scale;

  Cloud({
    required this.image,
    required this.x,
    required this.y,
    required this.scale,
  });
}

Map<int, Weather> weatherMap = {
  1000: Weather(weatherType: WeatherType.Sun, intensity: 5),
  1003: Weather(weatherType: WeatherType.Clear, intensity: 5),
  1006: Weather(weatherType: WeatherType.Cloud, intensity: 5),
  1009: Weather(weatherType: WeatherType.Cloud, intensity: 5),
  1030: Weather(weatherType: WeatherType.Fog, intensity: 5),
  1063: Weather(weatherType: WeatherType.Rain, intensity: 4),
  1066: Weather(weatherType: WeatherType.Snow, intensity: 4),
  1069: Weather(weatherType: WeatherType.Ice, intensity: 4),
  1072: Weather(weatherType: WeatherType.Ice, intensity: 4),
  1087: Weather(weatherType: WeatherType.Thunder, intensity: 5),
  1114: Weather(weatherType: WeatherType.Snow, intensity: 5),
  1117: Weather(weatherType: WeatherType.Snow, intensity: 10),
  1135: Weather(weatherType: WeatherType.Fog, intensity: 5),
  1147: Weather(weatherType: WeatherType.Fog, intensity: 5),
  1150: Weather(weatherType: WeatherType.Rain, intensity: 4),
  1153: Weather(weatherType: WeatherType.Rain, intensity: 4),
  1168: Weather(weatherType: WeatherType.Ice, intensity: 5),
  1171: Weather(weatherType: WeatherType.Ice, intensity: 10),
  1180: Weather(weatherType: WeatherType.Rain, intensity: 4),
  1183: Weather(weatherType: WeatherType.Rain, intensity: 4),
  1186: Weather(weatherType: WeatherType.Rain, intensity: 7),
  1189: Weather(weatherType: WeatherType.Rain, intensity: 7),
  1192: Weather(weatherType: WeatherType.Rain, intensity: 10),
  1195: Weather(weatherType: WeatherType.Rain, intensity: 10),
  1198: Weather(weatherType: WeatherType.Ice, intensity: 4),
  1201: Weather(weatherType: WeatherType.Ice, intensity: 7),
  1204: Weather(weatherType: WeatherType.Snow, intensity: 4),
  1207: Weather(weatherType: WeatherType.Snow, intensity: 7),
  1210: Weather(weatherType: WeatherType.Snow, intensity: 2),
  1213: Weather(weatherType: WeatherType.Snow, intensity: 3),
  1216: Weather(weatherType: WeatherType.Snow, intensity: 4),
  1219: Weather(weatherType: WeatherType.Snow, intensity: 5),
  1222: Weather(weatherType: WeatherType.Snow, intensity: 7),
  1225: Weather(weatherType: WeatherType.Snow, intensity: 10),
  1237: Weather(weatherType: WeatherType.Ice, intensity: 4),
  1240: Weather(weatherType: WeatherType.Rain, intensity: 3),
  1243: Weather(weatherType: WeatherType.Rain, intensity: 6),
  1246: Weather(weatherType: WeatherType.Rain, intensity: 10),
  1249: Weather(weatherType: WeatherType.Snow, intensity: 2),
  1252: Weather(weatherType: WeatherType.Snow, intensity: 5),
  1255: Weather(weatherType: WeatherType.Snow, intensity: 3),
  1258: Weather(weatherType: WeatherType.Snow, intensity: 8),
  1261: Weather(weatherType: WeatherType.Ice, intensity: 4),
  1264: Weather(weatherType: WeatherType.Ice, intensity: 7),
  1273: Weather(weatherType: WeatherType.Thunder, intensity: 4),
  1276: Weather(weatherType: WeatherType.Thunder, intensity: 7),
  1279: Weather(weatherType: WeatherType.Thunder, intensity: 4),
  1282: Weather(weatherType: WeatherType.Thunder, intensity: 7),
};

class Weather {
  final WeatherType weatherType;
  final int intensity;

  Weather({required this.weatherType, required this.intensity});
}

enum WeatherType {
  Rain,
  Snow,
  Fog,
  Ice,
  Thunder,
  Cloud,
  Sun,
  Clear,
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:havadurumu/pages/home/controllers/hourly_weekly_controller.dart';

import '../../../../../colors/app_colors.dart';
import '../widgets/temperature_bar_widget.dart';

class WeeklyView extends StatelessWidget {
  const WeeklyView({super.key});

  @override
  Widget build(BuildContext context) {
    final HourlyWeeklyController controller = Get.put(HourlyWeeklyController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Text(
                controller
                    .getMonthAndDay(controller
                        .homeController.weatherData.value.location.localtime)
                    .tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            // Ay adı
            // Switch butonunun yeni tasarımı
            Obx(() => GestureDetector(
                  onTap: () {
                    // Butona tıklayınca "Gün" ve "45gün" arasında geçiş yap
                    controller.isGunSelected.value =
                        !controller.isGunSelected.value;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 120,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Stack(
                      children: [
                        AnimatedAlign(
                          alignment: controller.isGunSelected.value
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Container(
                            width: 60,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.blueAccent, // Highlight rengi
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  "day".tr,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: controller.isGunSelected.value
                                        ? Colors.white
                                        : Colors.white30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "45days".tr,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: controller.isGunSelected.value
                                        ? Colors.white30
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            // Kaydırılabilir elementler veya boş içerik
            Expanded(
              child: Obx(() {
                if (controller.isGunSelected.value) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller
                        .homeController.weatherData.value.forecast.length,
                    itemBuilder: (context, index) {
                      final dayData = controller
                          .homeController.weatherData.value.forecast[index];
                      return Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 5,
                                color: Colors.black.withOpacity(0.3))
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                    controller
                                        .getWeekDayName(dayData.date)
                                        .tr[0],
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textColor)),
                                const SizedBox(height: 5),
                                Text(controller.getDayOfMonth(dayData.date),
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: AppColors.textColor)),
                                const SizedBox(height: 10),
                                Image.network(
                                  "https:${dayData.day.condition.icon!}",
                                  // URL'den gelen ikon
                                  width: 50.0, // İkonun genişliği
                                  height: 50.0, // İkonun yüksekliği
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.error,
                                    // Yüklenemezse gösterilecek bir yedek ikon
                                    color: Colors.red,
                                  ),
                                ),
                                //TODO: buranın ne kadar alan kaplayacağı hesaplanıp da height bilgisi gönderilmeli. bunu yaptıktan sonra extensive test lazım.
                                SizedBox(
                                  height: 410,
                                  width: 60,
                                  child: TemperatureBar(
                                    maxTemp: dayData.day.maxtempC?.toInt(),
                                    minTemp: dayData.day.mintempC?.toInt(),
                                    referenceMaxTemp:
                                        controller.getMaxTempInWeeks(),
                                    referenceMinTemp:
                                        controller.getMinTempInWeeks(),
                                    height: 350,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  width: 40,
                                  child: Divider(
                                    thickness: 1,
                                    color: AppColors.dividerColor,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.water_drop,
                                        color: Colors.blue, size: 20),
                                    const SizedBox(width: 5),
                                    Text(
                                        "${max(dayData.day.dailyChanceOfRain ?? 0, dayData.day.dailyChanceOfSnow ?? 0)}%",
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  final forecast =
                      controller.homeController.weatherData.value.forecast;
                  List<String> weekDays = ["M", "T", "W", "T", "F", "S", "S"];

                  // İlk günün haftanın hangi gününe denk geldiğini bul
                  DateTime firstDay = DateTime.parse(forecast.first.date ?? "");
                  int startDayIndex =
                      firstDay.weekday % 7; // 0 = Pazar, 6 = Cumartesi

                  return Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      // Haftanın gün başlıkları
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: weekDays
                            .map((day) => Expanded(
                                  child: Center(
                                    child: Text(
                                      day,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      // 45 Günlük hava durumu tablosu
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            childAspectRatio: 0.7, //problem olursa burayı değiş
                          ),
                          itemCount: forecast.length + startDayIndex,
                          itemBuilder: (context, index) {
                            if (index < startDayIndex) {
                              return const SizedBox(); // Boş hücreler
                            }
                            final dayData = forecast[index - startDayIndex];
                            return Card(
                              color: Colors.grey.shade900,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      controller.getDayOfMonth(dayData.date),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textColor),
                                    ),
                                    Image.network(
                                      "https:${dayData.day.condition.icon!}",
                                      width: 30,
                                      height: 30,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.error,
                                                  color: Colors.red),
                                    ),
                                    Text(
                                      "${dayData.day.maxtempC?.toInt()}°/${dayData.day.mintempC?.toInt()}°",
                                      style: TextStyle(
                                          fontSize: 9, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}

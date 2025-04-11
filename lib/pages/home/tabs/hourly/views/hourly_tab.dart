import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:havadurumu/pages/home/controllers/hourly_weekly_controller.dart';

import 'package:havadurumu/local_packages/weatherapi/lib/weatherapi.dart';

import '../../../../../colors/app_colors.dart';

class HourlyView extends StatelessWidget {
  HourlyView({super.key});

  final HourlyWeeklyController controller = Get.put(HourlyWeeklyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Obx(
        () => SingleChildScrollView(
          child: Column(
            children: List.generate(
              controller.homeController.weatherData.value.forecast.isEmpty
                  ? 0
                  : (controller.homeController.weatherData.value.forecast
                              .length <
                          4
                      ? controller
                          .homeController.weatherData.value.forecast.length
                      : 4),
              (index) {
                final item =
                    controller.homeController.weatherData.value.forecast[index];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 6.0, horizontal: 8.0),
                      child: Text(
                        controller.getWeekDayName(item.date).tr,
                        style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: item.hour.length,
                      itemBuilder: (context, index) {
                        return _buildWeatherItem(item.hour[index],
                            item.astro.sunrise, item.astro.sunset);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherItem(HourData item, String? sunrise, String? sunset) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: AppColors.temporaryForecastBackground,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    controller.getHourAndMinutes(item.time),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  item.condition.icon == null
                      ? const Icon(
                          Icons
                              .error, // Yüklenemezse gösterilecek bir yedek ikon
                          color: Colors.red,
                        )
                      : Image.network(
                          "https:${item.condition.icon!}", // URL'den gelen ikon
                          width: 50.0, // İkonun genişliği
                          height: 50.0, // İkonun yüksekliği
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons
                                .error, // Yüklenemezse gösterilecek bir yedek ikon
                            color: Colors.red,
                          ),
                        ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    '${item.tempC?.round()}°',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    '${"realFeel".tr} ${item.feelslikeC?.round()}°',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.water_drop_outlined,
                    size: 16,
                  ),
                  Text(
                    '${max(item.chanceOfRain ?? 0, item.chanceOfSnow ?? 0)}%',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildSunsetSunRiseWidget(item.time, sunrise, sunset),
      ],
    );
  }

  Widget _buildSunsetSunRiseWidget(
      String? time, String? sunriseString, String? sunsetString) {
    if (sunriseString == null || sunsetString == null) {
      return Container();
    }
    int? hour = controller.getHour(time);
    int? sunrise = controller.getHourForAMPM(sunriseString);
    int? sunset = controller.getHourForAMPM(sunsetString);

    if (hour == null || sunrise == null || sunset == null) {
      return Container();
    }

    var text = "";
    if (hour == sunrise) {
      text =
          "${"sunrise".tr}: ${controller.getHourAndMinutesForAMPM(sunriseString)}";
    } else if (hour == sunset) {
      text =
          "${"sunset".tr}: ${controller.getHourAndMinutesForAMPM(sunsetString)}";
    } else {
      return Container();
    }
    if (text.isEmpty) {
      return Container();
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.sunny,
            color: AppColors.iconColor,
          ),
          const SizedBox(
            width: 6,
          ),
          Text(
            text,
            style: TextStyle(
                color: AppColors.textColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

import 'package:get/get.dart';

import 'package:havadurumu/local_packages/weatherapi/lib/weatherapi.dart';

import '../../../controllers/home_controller.dart';
import '../helpers/forecast_summary_generator.dart';

class ForecastController extends GetxController {
  RxDouble columnHeight = 0.0.obs;
  final Rxn<HourData> newHourData = Rxn<HourData>();
  final HomeController homeController = Get.find<HomeController>();

  String getHourAndMinutes() {
    var localtime = newHourData.value != null
        ? newHourData.value!.time
        : homeController.weatherData.value.location.localtime;
    if (localtime == null) {
      return "";
    }
    DateTime dateTime = DateTime.parse(localtime);

    String hourMinute =
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    return hourMinute;
  }

  String getForecastSummary() {
    if (newHourData.value != null) {
      return "";
    }
    var generator = ForecastSummaryGenerator(homeController.weatherData.value,
        isDataFetched: homeController.isDataFetched.value);
    return generator.getFullConditionText();
  }

  String getMaxMinTempC(bool isMax) {
    if (newHourData.value != null) {
      return "";
    }
    var data = "";
    if (homeController.isDataFetched.value) {
      try {
        if (isMax) {
          data =
              "${homeController.weatherData.value.forecast[0].day.maxtempC?.round().toString()}°";
        } else {
          data =
              "${homeController.weatherData.value.forecast[0].day.mintempC?.round().toString()}°";
        }
      } catch (e) {}
      ;
    }
    return data;
  }

  String getWindText() {
    var data = "";
    if (homeController.isDataFetched.value) {
      try {
        var windSpeed = newHourData.value != null
            ? newHourData.value!.windKph?.round()
            : homeController.weatherData.value.current.windKph?.round();
        if (windSpeed == null) {
          return "";
        }
        if (windSpeed < 1) {
          data = "windSpeed1";
        } else if (windSpeed >= 1 && windSpeed < 6) {
          data = "windSpeed2";
        } else if (windSpeed >= 6 && windSpeed < 12) {
          data = "windSpeed3";
        } else if (windSpeed >= 12 && windSpeed < 20) {
          data = "windSpeed4";
        } else if (windSpeed >= 20 && windSpeed < 29) {
          data = "windSpeed5";
        } else if (windSpeed >= 29 && windSpeed < 39) {
          data = "windSpeed6";
        } else if (windSpeed >= 39 && windSpeed < 50) {
          data = "windSpeed7";
        } else if (windSpeed >= 50 && windSpeed < 62) {
          data = "windSpeed8";
        } else if (windSpeed >= 62 && windSpeed < 75) {
          data = "windSpeed9";
        } else if (windSpeed >= 75 && windSpeed < 89) {
          data = "windSpeed10";
        } else if (windSpeed >= 89 && windSpeed < 103) {
          data = "windSpeed11";
        } else if (windSpeed >= 103 && windSpeed < 118) {
          data = "windSpeed12";
        } else if (windSpeed >= 118) {
          data = "windSpeed13";
        }
        data = data.tr +
            " | " +
            convert16To8PointCompass(
                    homeController.weatherData.value.current.windDir)
                .tr +
            "    (kph)";
      } catch (e) {}
    }
    return data;
  }

  String convert16To8PointCompass(String? direction16) {
    if (direction16 == null) {
      return "";
    }
    Map<String, String> conversionMap = {
      "N": "north".tr,
      "NNE": "north".tr,
      "NE": "north-east".tr,
      "ENE": "north-east".tr,
      "E": "east".tr,
      "ESE": "east".tr,
      "SE": "south-east".tr,
      "SSE": "south-east".tr,
      "S": "south".tr,
      "SSW": "south".tr,
      "SW": "south-west".tr,
      "WSW": "south-west".tr,
      "W": "west".tr,
      "WNW": "west".tr,
      "NW": "north-west".tr,
      "NNW": "north-west".tr
    };

    return conversionMap[direction16] ?? "";
  }

  String getWindSpeed() {
    if (homeController.isDataFetched.value) {
      var windSpeed = newHourData.value != null
          ? newHourData.value!.windKph?.round().toString()
          : homeController.weatherData.value.current.windKph
              ?.round()
              .toString();
      if (windSpeed == null) {
        return "";
      } else {
        return windSpeed;
      }
    } else {
      return "";
    }
  }

  String getFeelsLike() {
    var feelsLike = newHourData.value != null
        ? newHourData.value!.feelslikeC?.roundToDouble().toInt().toString()
        : homeController.weatherData.value.current.feelslikeC
            ?.roundToDouble()
            .toInt()
            .toString();
    if (feelsLike == null) {
      return "";
    }
    return feelsLike;
  }

  double getPrecipitation() {
    var feelsLike = newHourData.value != null
        ? newHourData.value!.precipMm
        : homeController.weatherData.value.current.precipMm;
    if (feelsLike == null) {
      return 0.0;
    }
    return feelsLike;
  }

  double getWindAngle() {
    var windAngle = newHourData.value != null
        ? newHourData.value!.windDegree?.toDouble()
        : homeController.weatherData.value.current.windDegree
            ?.toDouble()
            .toDouble();
    if (windAngle == null) {
      return 0;
    }
    return windAngle;
  }

  String getCurrentDegree() {
    var degree = newHourData.value != null
        ? newHourData.value!.tempC?.toInt().toString()
        : homeController.weatherData.value.current.tempC?.toInt().toString();
    if (degree == null) {
      return "";
    }
    return degree;
  }

  int getHour(String? localtime) {
    if (localtime == null) {
      return 0;
    }
    DateTime dateTime = DateTime.parse(localtime);

    return dateTime.hour;
  }

  void updateNewHourData(int? newHour) {
    if (newHour == null ||
        newHour ==
            getHour(homeController.weatherData.value.location.localtime)) {
      newHourData.value = null;
    } else {
      newHourData.value = homeController.weatherData.value.forecast[0].hour
          .firstWhere((it) => getHour(it.time) == newHour);
    }
  }
}

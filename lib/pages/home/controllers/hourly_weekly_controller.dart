import 'dart:math';

import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'home_controller.dart';

class HourlyWeeklyController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();
  RxBool isGunSelected = true.obs;

  String getHourAndMinutes(String? localtime) {
    if (localtime == null) {
      return "";
    }
    DateTime dateTime = DateTime.parse(localtime);

    String hourMinute =
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    return hourMinute;
  }

  String getHourAndMinutesForAMPM(String? localtime) {
    if (localtime == null || localtime.isEmpty) {
      return "";
    }

    try {
      // AM/PM formatını çözümlemek için bir DateFormat tanımlıyoruz
      DateFormat format = DateFormat("hh:mm a");
      DateTime dateTime = format.parse(localtime);

      // Saat ve dakika değerlerini döndür
      String hourMinute =
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
      return hourMinute;
    } catch (e) {
      return "";
    }
  }

  int? getHour(String? localtime) {
    if (localtime == null || localtime.isEmpty) {
      return null;
    }
    DateTime dateTime = DateTime.parse(localtime);

    return dateTime.hour;
  }

  int? getHourForAMPM(String? localtime) {
    if (localtime == null || localtime.isEmpty) {
      return null;
    }

    try {
      // AM/PM formatını çözümlemek için bir DateFormat tanımlıyoruz
      DateFormat format = DateFormat("hh:mm a");
      DateTime dateTime = format.parse(localtime);

      // Saat değerini döndür
      return dateTime.hour;
    } catch (e) {
      // Hatalı format durumunda null döndür
      print("Hata: $e");
      return null;
    }
  }

  String getMonthAndDay(String? timeString) {
    // Convert the timeString to DateTime
    DateTime dateTime;
    try {
      dateTime = DateTime.parse(timeString!);
    } catch (e) {
      return "";
    }

    List<String> months = [
      "january",
      "february",
      "march",
      "april",
      "may",
      "june",
      "july",
      "august",
      "september",
      "october",
      "november",
      "december"
    ];

    // Return the month name and day as a string
    return "${months[dateTime.month - 1].tr} ${dateTime.day}";
  }

  String getWeekDayName(String? timeString) {
    if (timeString == null) {
      return "";
    }

    List<String> days = [
      "monday".tr,
      "tuesday".tr,
      "wednesday".tr,
      "thursday".tr,
      "friday".tr,
      "saturday".tr,
      "sunday".tr
    ];

    try {
      DateTime time = DateTime.parse(timeString);
      return days[time.weekday - 1];
    } catch (e) {
      return "";
    }
  }

  String getDayOfMonth(String? date) {
    if (date == null) {
      return "";
    }
    try {
      // Tarihi DateTime formatına dönüştür
      DateTime parsedDate = DateTime.parse(date);

      // Gün değerini döndür
      return (parsedDate.day).toString();
    } catch (e) {
      // Hatalı bir tarih formatı girildiyse
      throw FormatException(
          "Geçersiz tarih formatı: $date. Doğru format: 'yyyy-MM-dd'");
    }
  }

  int getMaxTempInWeeks() {
    try {
      return homeController.weatherData.value.forecast
          .map((it) => it.day.maxtempC!.toInt())
          .toList()
          .reduce(max);
    } catch (e) {
      return 40;
    }
  }

  int getMinTempInWeeks() {
    try {
      return homeController.weatherData.value.forecast
          .map((it) => it.day.mintempC!.toInt())
          .toList()
          .reduce(min);
    } catch (e) {
      return -40;
    }
  }
}

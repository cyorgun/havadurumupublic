import 'package:get/get.dart';
import 'package:havadurumu/local_packages/weatherapi/lib/weatherapi.dart';

class ForecastSummaryGenerator {
  final ForecastWeather fw;
  final bool isDataFetched;

  ForecastSummaryGenerator(this.fw, {this.isDataFetched = false});

  String getFullConditionText() {
    if (!isDataFetched) {
      return "";
    }

    String firstSection;
    String secondSection;

    var asd = _returnNextTwoDayPhaseAsList();
    var asd2 = asd[0];
    var asd3 = asd[1];

    var fullConditionText = "";

    try {
      var frequencyMap1 = _createFrequencyMap(fw, asd2);
      var frequencyMap2 = _createFrequencyMap(fw, asd3);

      firstSection = _findMostFrequentElementInMap(frequencyMap1);
      secondSection = _findMostFrequentElementInMap(frequencyMap2);
      secondSection = secondSection.toLowerCase();

      if (firstSection[firstSection.length - 1] != " ") {
        firstSection += " ";
      }
      if (secondSection[secondSection.length - 1] != " ") {
        secondSection += " ";
      }

      fullConditionText =
          "$firstSection${"this".tr} ${asd2.tr} ${"and".tr} $secondSection${"this".tr} ${asd3.tr}.";
    } catch (exception) {}

    return fullConditionText;
  }

  int? _getHour(String? localtime) {
    if (localtime == null) {
      return null;
    }
    DateTime dateTime = DateTime.parse(localtime);

    return dateTime.hour;
  }

  int _getAmountOfDuplicateEntries(List items, String item) {
    return items.where((it) => item == it).toList().length;
  }

  String _findMostFrequentElementInMap(Map<String, int> frequencyMap) {
    var frequencyMapValues = frequencyMap.values.toList();
    frequencyMapValues.sort();
    return frequencyMap.keys
        .firstWhere((k) => frequencyMap[k] == frequencyMapValues.last);
  }

  Map<String, int> _createFrequencyMap(ForecastWeather fw, String timeZone) {
    List<HourData> temp = fw.forecast[0].hour
        .where((it) =>
            _getHour(it.time)! < dayPhasesMaxNumber[timeZone]! &&
            dayPhasesMaxNumber[timeZone]! - 6 <= _getHour(it.time)!)
        .toList();
    List<String?> conditionTextList =
        temp.map((it) => it.condition.text).toList();

    List<String?> conditionTextListWithoutDuplicates =
        conditionTextList.toSet().toList();
    Map<String, int> frequencyMap = {};
    if (conditionTextListWithoutDuplicates.isNotEmpty) {}
    for (int i = 0; i < conditionTextList.toSet().length; i++) {
      frequencyMap[conditionTextListWithoutDuplicates[i]!] =
          _getAmountOfDuplicateEntries(
              conditionTextList, conditionTextListWithoutDuplicates[i]!);
    }
    return frequencyMap;
  }

  List<String> _returnNextTwoDayPhaseAsList() {
    var list = <String>[];
    var hour = _getHour(fw.location.localtime);
    if (hour == null) {
      List.empty();
    } else {
      if (hour < dayPhasesMaxNumber["night"]!) {
        list.add("night");
        list.add("morning");
      } else if (hour < dayPhasesMaxNumber["morning"]!) {
        list.add("morning");
        list.add("afternoon");
      } else if (hour < dayPhasesMaxNumber["afternoon"]!) {
        list.add("afternoon");
        list.add("evening");
      } else if (hour < dayPhasesMaxNumber["evening"]!) {
        list.add("evening");
        list.add("night");
      }
    }
    return list;
  }

  String _returnDayPhaseFromTime(int? hour) {
    if (hour == null) {
      return "";
    } else {
      if (hour < dayPhasesMaxNumber["night"]!) {
        return "night".tr;
      } else if (hour < dayPhasesMaxNumber["morning"]!) {
        return "morning".tr;
      } else if (hour < dayPhasesMaxNumber["afternoon"]!) {
        return "afternoon".tr;
      } else if (hour < dayPhasesMaxNumber["evening"]!) {
        return "evening".tr;
      } else {
        return "";
      }
    }
  }
}

const Map<String, int> dayPhasesMaxNumber = {
  'night': 6,
  'morning': 12,
  'afternoon': 18,
  'evening': 24,
};

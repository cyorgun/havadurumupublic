import 'package:shared_preferences/shared_preferences.dart';

import '../models/CityModel.dart';

class SharedPrefsHelper {
  static late SharedPreferences _prefs;

  // SharedPreferences'ı başlatma
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  //TODO sharedprefe yeni bir şey eklerse burası sıkıntı. çünkü main keyi dışında diğer her şeyi city idsi olarak bekliyoruz
  // get all ids
  static List<String>? getKeys() {
    return _prefs.getKeys().toList().take(10).toList();
  }

  // Veri kaydetme (String)
  static Future<void> saveCity({required CityModel cityModel}) async {
    await _prefs.setStringList(cityModel.id, cityModel.getListFromCityModel());
  }

  // Veri çekme (String)
  static CityModel? getCity({required String cityModelId}) {
    var list = _prefs.getStringList(cityModelId) ?? [];
    return _getCityModelFromList(list);
  }

  // save first displayed city
  static Future<void> setMainCity({required CityModel cityModel}) async {
    await _prefs.setStringList("main", cityModel.getListFromCityModel());
  }

  // get first displayed city
  static CityModel? getMainCity() {
    var list = _prefs.getStringList("main") ?? [];
    return _getCityModelFromList(list);
  }

  // helper private function
  static CityModel? _getCityModelFromList(List<String> list) {
    CityModel? cityModel;
    if (list.isNotEmpty) {
      cityModel = CityModel(
          id: list[0],
          name: list[1],
          coordinates:
              LatLng(lat: double.parse(list[2]), lng: double.parse(list[3])),
          isFavorite: list[4] == "true" ? true : false,
          country: list[5]);
    }
    return cityModel;
  }
}

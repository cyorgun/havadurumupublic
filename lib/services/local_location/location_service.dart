import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

import '../../models/CityModel.dart';

class LocationService extends GetxController {
  Map<String, dynamic> ilceMap = {}; // İlçe bilgileri için hızlı erişim
  RxList<CityModel> combinedData = <CityModel>[].obs;

  @override
  void onInit() async {
    super.onInit();

    // JSON dosyalarını paralel olarak yükle
    final jsonFiles = await Future.wait([
      rootBundle.loadString("assets/json/cities500.json"),
      rootBundle.loadString("assets/json/il.json"),
      rootBundle.loadString("assets/json/ilce.json"),
      rootBundle.loadString("assets/json/koy.json"),
      rootBundle.loadString("assets/json/mahalle.json"),
    ]);

    // JSON dosyalarını parse et ve sadece data kısmını al
    final jsonData = jsonDecode(jsonFiles[0]);
    final jsonData2 = jsonDecode(jsonFiles[1])[2]["data"];
    final jsonData3 = jsonDecode(jsonFiles[2])[2]["data"];
    final jsonData4 = jsonDecode(jsonFiles[3])[2]["data"];
    final jsonData5 = jsonDecode(jsonFiles[4])[2]["data"];

    // İlçe verilerini bir Map olarak sakla (id'ye göre hızlı erişim için)
    ilceMap = {
      for (var entry in jsonData3) entry['id']: entry,
    };

    // Şehir verilerini oluştur
    List<CityModel> locations = (jsonData as List<dynamic>)
        .map((item) => CityModel.fromJson(item))
        .toList();
    List<CityModel> locations2 = createTRCityModels(jsonData2, CityType.IL);
    List<CityModel> locations3 = createTRCityModels(jsonData3, CityType.ILCE);
    List<CityModel> locations4 = createTRCityModels(jsonData4, CityType.KOY);
    List<CityModel> locations5 =
        createTRCityModels(jsonData5, CityType.MAHALLE);

    // Tüm listeleri birleştir
    combinedData.value = [
      ...locations,
      ...locations2,
      ...locations3,
      ...locations4,
      ...locations5,
    ];
  }

  List<CityModel> createTRCityModels(
      List<dynamic> jsonData, CityType cityType) {
    return jsonData.map((item) {
      var country = "";
      if (cityType == CityType.KOY || cityType == CityType.MAHALLE) {
        country = getCountry(item);
      }
      var loc = getLocation(item, cityType);
      return CityModel.fromTRJson(item, loc, country);
    }).toList();
  }

  String getCountry(Map<String, dynamic> json) {
    var ilceId = json["country"];
    var result = ilceMap[ilceId];
    if (result != null && result.containsKey('country')) {
      return result["name"] + " / " + result["country"];
    } else {
      return "";
    }
  }

  LatLng getLocation(Map<String, dynamic> json, CityType cityType) {
    // Şehir türüne göre lokasyon bilgisi döndür
    if (cityType == CityType.IL) {
      return LatLng(lat: 0, lng: 0); // İl için lat/lng yok
    } else if (cityType == CityType.ILCE) {
      if (json.containsKey('coordinates')) {
        List<String> coordinates = json['coordinates']!.split(',');
        double latitude = double.parse(coordinates[0].trim());
        double longitude = double.parse(coordinates[1].trim());
        return LatLng(lat: latitude, lng: longitude);
      }
    } else if (cityType == CityType.MAHALLE || cityType == CityType.KOY) {
      var ilceId = json["country"];
      var result = ilceMap[ilceId];
      if (result != null && result.containsKey('coordinates')) {
        List<String> coordinates = result['coordinates']!.split(',');
        double latitude = double.parse(coordinates[0].trim());
        double longitude = double.parse(coordinates[1].trim());
        return LatLng(lat: latitude, lng: longitude);
      }
    }
    return LatLng(lat: 0, lng: 0); // Varsayılan değer
  }
}

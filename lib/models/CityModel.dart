// LatLng sınıfı
class LatLng {
  final double lat;
  final double lng;

  LatLng({required this.lat, required this.lng});
}

// JSON verisinin modelini tanımlıyoruz
class CityModel {
  final String id;
  final String name;
  final String country; // veya ilçeyse il, mahalle/köyse ilçe. bir üstü yani
  final String admin1;
  final LatLng coordinates;
  bool isFavorite;

  CityModel({
    required this.id,
    required this.name,
    this.country = "",
    this.admin1 = "",
    required this.coordinates,
    this.isFavorite = false,
  });

  // JSON verisini Location objesine dönüştüren factory method
  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      country: json['country'] ?? "",
      admin1: json['admin1'] ?? "",
      coordinates: LatLng(
        lat: double.parse(json['lat'] ?? "0"),
        lng: double.parse(json['lon'] ?? "0"),
      ),
      isFavorite: false,
    );
  }

  factory CityModel.fromTRJson(
      Map<String, dynamic> json, LatLng latlng, String country) {
    return CityModel(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      country: country.isEmpty ? (json["country"] ?? "TR") : country,
      admin1: json['admin1'] ?? "",
      coordinates: latlng,
      isFavorite: false,
    );
  }

  List<String> getListFromCityModel() {
    List<String> list = [
      id,
      name,
      coordinates.lat.toString(),
      coordinates.lng.toString(),
      isFavorite ? "true" : "false",
      country
    ];
    return list;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "country": country,
      "coordinates": {
        "lat": coordinates.lat,
        "lng": coordinates.lng,
      },
    };
  }
}

enum CityType { IL, ILCE, KOY, MAHALLE }

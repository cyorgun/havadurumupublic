import 'package:get/get.dart';
import 'package:havadurumu/models/CityModel.dart';

import '../../../services/local_location/location_service.dart';

class SearchController extends GetxController {
  RxList<CityModel> cities = <CityModel>[].obs;
  Rx<bool> isSearchActive = false.obs;
  final LocationService locationService = Get.put(LocationService());

  void search(String searchTerm) {
    // Boş veri durumunda aramayı atla
    if (locationService.combinedData.isEmpty || searchTerm.isEmpty) {
      return;
    }

    // Arama terimini normalize et
    String normalizedTerm = searchTerm.toLowerCase();

    // Arama yap ve ilk 100 sonucu al
    List<CityModel> matchingLocations = locationService.combinedData
        .where(
            (location) => location.name.toLowerCase().contains(normalizedTerm))
        .take(100)
        .toList();

    // Sonuçları güncelle
    cities.assignAll(matchingLocations);
  }
}

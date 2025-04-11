import 'package:get/get.dart';
import 'package:havadurumu/models/CityModel.dart';
import 'package:havadurumu/shared/helper_methods.dart';
import 'package:havadurumu/shared/shared_prefs_helper.dart';

import '../../../pages/home/controllers/home_controller.dart';
import '../../../services/auth/auth_service.dart';

class CustomAppBarController extends GetxController {
  late Rx<CityModel> selectedCityModel;
  final AuthService authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    selectedCityModel = Get.find<HomeController>().selectedCityModel;
    loadFavoriteStatus();
  }

  void loadFavoriteStatus() async {
    var fav = await authService.checkFavoriteStatus(selectedCityModel.value.id);
    selectedCityModel.update((city) {
      if (city != null) {
        city.isFavorite = fav;
      }
    });
  }

  void toggleFavoriteStatus() async {
    if (!(await HelperMethods.checkInternet())) {
      return;
    }
    try {
      if (selectedCityModel.value.isFavorite) {
        authService.removeFavoriteCity(selectedCityModel.value.id);
        selectedCityModel.update((city) {
          if (city != null) {
            city.isFavorite = false;
          }
        });
      } else {
        authService.addFavoriteCity(
            lat: selectedCityModel.value.coordinates.lat,
            lon: selectedCityModel.value.coordinates.lng,
            cityName: selectedCityModel.value.name,
            cityId: selectedCityModel.value.id);
        selectedCityModel.update((city) {
          if (city != null) {
            city.isFavorite = true;
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void updateCity(CityModel newCity) {
    selectedCityModel.update((city) {
      if (city != null) {
        city = newCity;
      }
    });
    loadFavoriteStatus();

    SharedPrefsHelper.saveCity(cityModel: newCity);

    SharedPrefsHelper.setMainCity(cityModel: newCity);
  }
}

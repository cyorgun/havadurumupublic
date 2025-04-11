import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:havadurumu/models/CityModel.dart';
import 'package:havadurumu/local_packages/weatherapi/lib/weatherapi.dart';
import 'package:havadurumu/services/auth/auth_service.dart';
import 'package:havadurumu/shared/helper_methods.dart';
import 'package:havadurumu/shared/shared_prefs_helper.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../lang/translation_service.dart';

const API_KEY = '';

class HomeController extends GetxController {
  //final RxList<ExampleModel> itemList = <ExampleModel>[].obs;
  final Rx<bool> shouldSplashShow = true.obs;
  final Rx<CityModel> selectedCityModel =
      CityModel(id: "?", name: "", coordinates: LatLng(lat: 0, lng: 0)).obs;
  final RxInt selectedBottomBarItemIndex = 0.obs;
  final Rx<ForecastWeather> weatherData = ForecastWeather({}).obs;
  RxList<CityModel> lastSearchedCityModels = <CityModel>[].obs;
  final AuthService authService = Get.find<AuthService>();
  final RxBool isLoadingVisible = true.obs;

  final RxBool isDataFetched = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    getCity();
    getLastSearched();
    Future.delayed(const Duration(milliseconds: 1500), () {
      shouldSplashShow.value = false;
    });
  }

  void getCity() async {
    // first check if we can get user's location immediately
    var isGpsEnabled =
        await Geolocator.isLocationServiceEnabled(); // gps açık mı
    PermissionStatus permission =
        await Permission.location.request(); // permission verilmiş mi
    if (permission.isGranted && isGpsEnabled) {
      try {
        await getPositionAndUpdateCity();
        return;
      } catch (e) {}
    }

    // secondly check sharedpref
    var mainCity = await SharedPrefsHelper.getMainCity();
    if (mainCity != null) {
      selectedCityModel.value = mainCity;
      loadFavoriteStatus();
      fetchForecast();
    } else {
      //thirdly show default location
      selectedCityModel.value = CityModel(
          id: "?",
          name: "Istanbul",
          coordinates: LatLng(lat: 41.0186, lng: 28.9647));
      fetchForecast(); // fetch default value
    }
  }

  Future<void> getPositionAndUpdateCity() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);

    try {
      await fetchForecastByUserCoordinates(
          position.latitude, position.longitude);
    } catch (e) {
      rethrow;
    }

    var name = weatherData.value.location.name ?? "";
    if (name == "MERKEZ") {
      name = weatherData.value.location.country ?? "";
    }

    selectedCityModel.value = CityModel(
        id: "?",
        name: name,
        coordinates: LatLng(
            lat: position.latitude, lng: position.longitude)); // don't save
    update();
  }

  void loadFavoriteStatus() async {
    var fav = await authService.checkFavoriteStatus(selectedCityModel.value.id);
    selectedCityModel.update((city) {
      if (city != null) {
        city.isFavorite = fav;
      }
    });
  }

  void getLastSearched() {
    var lastSearchedCityIds = SharedPrefsHelper.getKeys() ?? [];
    if (lastSearchedCityIds.isEmpty) {
      return;
    }
    if (lastSearchedCityIds.remove("main")) ;
    if (lastSearchedCityIds.remove("first_time")) ;
    //TODO: sharedprefe bir şey eklenirse burda çıkarılmalı
    for (String cityId in lastSearchedCityIds) {
      var model = SharedPrefsHelper.getCity(cityModelId: cityId);
      if (model != null) {
        lastSearchedCityModels.add(model);
      }
    }
  }

  void initSplash() {}

  void fetchForecastByName() async {
    WeatherRequest wr = WeatherRequest(API_KEY);

    ForecastWeather fw = await wr.getForecastWeatherByCityName(
        //TODO: tr magic string
        // sadece il.json buraya geliyor
        selectedCityModel.value.country == "TR"
            ? selectedCityModel.value.name
            : selectedCityModel.value.country,
        airQualityIndex: true,
        alerts: true,
        forecastDays: 14,
        lang: Messages.getLanguageCodeForWeatherParameter());
    weatherData.value = fw;
    isDataFetched.value = true;
    isLoadingVisible.value = false;
  }

  void fetchForecast() async {
    // prioritize search with cityModel's coordinates
    if (!(await HelperMethods.checkInternet())) {
      isLoadingVisible.value = false;
      return;
    }
    try {
      if (selectedCityModel.value.coordinates.lat == 0 &&
          selectedCityModel.value.coordinates.lng == 0) {
        //önce search api yapıp da ondan gelen değer fetchForecasyByName'e sokulabilir
        fetchForecastByName();
      } else {
        fetchForecastByUserCoordinates(selectedCityModel.value.coordinates.lat,
            selectedCityModel.value.coordinates.lng);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchForecastByUserCoordinates(double lat, double lng) async {
    if (!(await HelperMethods.checkInternet())) {
      isLoadingVisible.value = false;
      return;
    }
    try {
      WeatherRequest wr = WeatherRequest(API_KEY);

      ForecastWeather fw = await wr.getForecastWeatherByLocation(lat, lng,
          airQualityIndex: true,
          alerts: true,
          forecastDays: 14,
          lang: Messages.getLanguageCodeForWeatherParameter());

      weatherData.value = fw;
      isDataFetched.value = true;
      isLoadingVisible.value = false;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}

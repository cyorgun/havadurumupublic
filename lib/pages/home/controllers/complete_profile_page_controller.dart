import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:havadurumu/models/FarmerDataModel.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:csv/csv.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../../../models/CityModel.dart';
import '../../../services/auth/auth_service.dart';
import '../../../services/local_location/location_service.dart';
import '../../../shared/shared_prefs_helper.dart';

const DEFAULT_TEXT = "Seçiniz";

class CompleteProfilePageController extends GetxController {
  final _authService = Get.find<AuthService>();
  final Rx<FarmerDataModel> farmerDataModel =
      FarmerDataModel(products: [], locations: []).obs;
  RxList<CityModel> cities = <CityModel>[].obs;
  final LocationService locationService = Get.put(LocationService());

  final formGroup = FormGroup({
    'products':
        FormControl<List<String>>(value: [], validators: [Validators.required]),
    'tonnage': FormControl<int>(
        value: 0, validators: [Validators.required, Validators.number()]),
    'locations': FormControl<List<CityModel>>(
        value: [], validators: [Validators.required]),
  });

  final List<String> products = [];
  final RxList<MultiSelectItem<CityModel>> allLocations =
      <MultiSelectItem<CityModel>>[].obs;
  final RxString searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _readCsv();
  }

  Future<void> _readCsv() async {
    products.clear();
    final input = await rootBundle.loadString('assets/csv/products.csv');
    List<List<dynamic>> csvData = const CsvToListConverter().convert(input);
    List<String> itemList = csvData.map((row) => row[0].toString()).toList();
    products.addAll(itemList);
    update();
  }

  void done() {
    if (formGroup.control('products').value == null ||
        (formGroup.control('products').value as List).isEmpty ||
        formGroup.control('tonnage').value == 0) {
      Get.snackbar(
        'error'.tr,
        'missingFieldsError'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (formGroup.control('locations').value == null ||
        (formGroup.control('locations').value as List).isEmpty) {
      Get.snackbar(
        'error'.tr,
        'missingLocationError'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (formGroup.valid) {
      try {
        farmerDataModel.value = FarmerDataModel(
          products: (formGroup.control('products').value as List<String>)
              .map((p) => ProductModel(
                  product: p, tonnage: formGroup.control('tonnage').value))
              .toList(),
          locations: formGroup.control('locations').value as List<CityModel>,
        );
        update();
        _authService.saveMissingFields(farmerDataModel: farmerDataModel.value);
        if (farmerDataModel.value.locations.isNotEmpty) {
          // boş olamaz zate ama ne olur ne olmaz
          farmerDataModel.value.locations.forEach((location) {
            _authService.addFavoriteCity(
                cityId: location.id,
                cityName: location.name,
                lat: location.coordinates.lat,
                lon: location.coordinates.lng);
            SharedPrefsHelper.saveCity(cityModel: location);
          });
          SharedPrefsHelper.setMainCity(
              cityModel: farmerDataModel.value.locations[0]);
        }
      } catch (e) {
        Get.snackbar(
          'error'.tr,
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    }
  }
}

class LocationSelector extends StatelessWidget {
  final CompleteProfilePageController controller;

  const LocationSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => MultiSelectDialogField<CityModel>(
          buttonText: Text("select".tr),
          searchable: true,
          searchHint: 'Type to search...'.tr,
          title: Text('selectLocation'.tr),
          initialValue: controller.formGroup.control('locations').value,
          items: controller.locationService.combinedData
              .map((city) => MultiSelectItem<CityModel>(
                  city, city.name + " / " + city.country))
              .toList(),
          onConfirm: (values) {
            controller.formGroup.control('locations').value = values;
          },
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ));
  }
}

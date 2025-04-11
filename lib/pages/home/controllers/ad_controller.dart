import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AdController extends GetxController {
  final RxMap<String, dynamic> adData = <String, dynamic>{}.obs;
  final RxBool isAdVisible = true.obs; // Reklamın gösterilip gösterilmeyeceğini takip eder
  final GetStorage storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadAdVisibility();
    _listenToAdvertisement();
  }

  void _listenToAdvertisement() {
    FirebaseFirestore.instance
        .collection("advertisements")
        .doc("active")
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        adData.value = snapshot.data() ?? {};
        isAdVisible.value = true; // Yeni reklam geldiğinde göster
      } else {
        adData.clear();
        isAdVisible.value = false;
      }
    });
  }

  void closeAd() {
    isAdVisible.value = false;
    storage.write("ad_closed", true); // Reklam kapatıldığında sakla
  }

  void _loadAdVisibility() {
    if (storage.hasData("ad_closed")) {
      isAdVisible.value = false;
    }
  }
}

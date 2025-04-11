import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:havadurumu/models/FarmerDataModel.dart';

import '../../pages/notifications/controllers/notifications_controller.dart';
import '../../routes/app_routes.dart';

class AuthService extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  var user = Rx<User?>(null); // Kullanıcı bilgisi
  var userData = Rx<Map<String, dynamic>?>(null); // Kullanıcı datası
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  StreamSubscription? _subscription;
  Completer<void> _userDocumentLoaded = Completer<void>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void onInit() {
    super.onInit();
    // alttaki şekilde başka bir classtan buradaki user değerini dinleyebilir ve fonksiyon tetikleyebilirsin
    /* final GetxController xController = Get.find<GetxController>();*/
    /* _authController.count.listen((value) {
    print("XController count değişti: $value");
    onXValueChanged(value);
    });*/
    userStateChanges.listen((User? user) async {
      this.user.value = user; // Kullanıcı oturum durumu değişirse güncelle
      // if (user != null) Eğer kullanıcı giriş yaptıysa
      // if (user == null) Eğer kullanıcı çıkış yaptıysa
      if (user != null) {
        await listenToUserDocument();
        updateFcmToken();
        _subscribeToTopic();
      }
    });
  }

  void _subscribeToTopic() {
    if (userData.value == null) {
      return;
    }
    if (userData.value!['isFarmer'] == true) {
      _firebaseMessaging.subscribeToTopic('farmers');
      _firebaseMessaging.subscribeToTopic('general');
    } else {
      _firebaseMessaging.subscribeToTopic('general');
    }
  }

  // Kullanıcı oturum durumunu dinle
  Stream<User?> get userStateChanges {
    return _auth
        .authStateChanges(); // Kullanıcı oturum durumu değiştiğinde tetiklenir
  }

  void updateFcmToken() async {
    String? token = await messaging.getToken();
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.value!.uid)
        .update({'fcmToken': token});
  }

  Future<void> listenToUserDocument() async {
    try {
      _userDocumentLoaded = Completer<void>(); // Burada sıfırlıyoruz

      await _subscription?.cancel(); // Önceki dinleyiciyi iptal et
      _subscription = FirebaseFirestore.instance
          .collection("users")
          .doc(user.value?.uid)
          .snapshots()
          .listen((DocumentSnapshot snapshot) {
        if (snapshot.exists) {
          userData.value = snapshot.data() as Map<String, dynamic>;
          print("Belge Güncellendi: ${snapshot.data()}");

          // Kullanıcı verisi güncellendi, artık NotificationsController çağrılabilir
          if (!_userDocumentLoaded.isCompleted) {
            _userDocumentLoaded.complete();
          }
        } else {
          print("Belge bulunamadı!");
        }
      });

      await _userDocumentLoaded
          .future; // Kullanıcı verisi yüklenene kadar bekle
    } catch (e) {
      print(e);
    }
  }

  Future<Map<String, dynamic>?>? _getUserData() async {
    try {
      // Firestore referansını al
      var userDoc = await FirebaseFirestore.instance
          .collection('users') // Kullanıcı belgelerinin olduğu koleksiyon
          .doc(user.value!.uid) // Kullanıcının UID'sine göre belgeyi al
          .get();

      if (userDoc.exists) {
        return userDoc.data();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> checkUserVerification() async {
    User? user = _auth.currentUser;
    if (user == null) {
      return; // Kullanıcı oturum açmamış, hiçbir şey yapma
    }
    await user.reload(); // Kullanıcı bilgisini güncelle

    // Eğer kullanıcı Google ile giriş yaptıysa, doğrulamaya gerek yok
    for (var provider in user.providerData) {
      if (provider.providerId == 'google.com') {
        return;
      }
    }

    if (user.email != null && !user.emailVerified) {
      Get.toNamed(Routes.EMAILVERIFICATION, arguments: {'email': user.email});
    }
  }

  // Kullanıcı kaydı
  Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required bool isFarmer,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        // Kullanıcı Firestore'a eklenecek
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'email': email,
          'createdAt': Timestamp.now(),
          'isFarmer': isFarmer,
          'messageQuota': isFarmer ? 10 : 3,
          'isProfileComplete': !isFarmer,
          'fcmToken': await messaging.getToken(),
        }, SetOptions(merge: true));
      }
      return userCredential.user;
    } catch (e) {
      throw FirebaseAuthException(
        code: (e as FirebaseAuthException).code,
        message: e.message,
      );
    }
  }

  Future<void> saveUserToFirestoreWithPhoneNumber(
      User user, String phoneNumber, bool isFarmer) async {
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      await _firestore.collection('users').doc(user.uid).set({
        'email': phoneNumber,
        'createdAt': Timestamp.now(),
        'isFarmer': isFarmer,
        'messageQuota': isFarmer ? 10 : 3,
        'isProfileComplete': !isFarmer,
        'fcmToken': await messaging.getToken(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> signInWithPhoneNumber({required String phoneNumber}) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          var userCredential = await _auth.signInWithCredential(credential);
          Get.offAllNamed(Routes.HOME); // Başarılı girişten sonra yönlendirme
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.snackbar(
            'Login Error',
            e.message ?? 'An unexpected error occurred.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          Get.toNamed(Routes.OTPVERIFICATION, arguments: {
            'phoneNumber': phoneNumber,
            'verificationId': verificationId, // <-- OTP ekranına gönderilecek!
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      Get.snackbar(
        'Login Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> registerWithPhoneNumber({
    required String phoneNumber,
    required bool isFarmer,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          var userCredential = await _auth.signInWithCredential(credential);
          Get.offAllNamed(Routes.HOME);
          if (userCredential.user != null) {
            // Kullanıcı Firestore'a eklenecek
            await saveUserToFirestoreWithPhoneNumber(
                userCredential.user!, phoneNumber, isFarmer);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.snackbar('Verification Failed', e.message ?? 'Unknown error',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white);
        },
        codeSent: (String verificationId, int? resendToken) {
          Get.toNamed(Routes.OTPVERIFICATION, arguments: {
            'phoneNumber': phoneNumber,
            'verificationId': verificationId, // <-- OTP ekranına gönderilecek!
            'isFarmer': isFarmer,
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      throw FirebaseAuthException(
        code: (e as FirebaseAuthException).code,
        message: e.message,
      );
    }
  }

  Future<void> saveMissingFields(
      {required FarmerDataModel farmerDataModel}) async {
    try {
      String? userId = user.value?.uid;
      if (userId == null) {
        throw Exception("authError".tr);
      }

      await _firestore.collection('users').doc(userId).set({
        'isProfileComplete': true,
      }, SetOptions(merge: true));

      var docRef = FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("farmerData")
          .doc("profile");

      await docRef.set(farmerDataModel.toMap(), SetOptions(merge: true));

      print("Veri başarıyla kaydedildi: ${docRef.id}");
    } catch (e) {
      print("Hata oluştu: $e");
      rethrow;
    }
  }

  Future<bool> askUserIfFarmer() async {
    bool isFarmer = false; // Varsayılan olarak müşteri kabul edelim

    await Get.defaultDialog(
      title: "Hesap Türü",
      middleText: "Çiftçi misiniz?",
      textConfirm: "Evet, çiftçiyim",
      textCancel: "Hayır, müşteri",
      onConfirm: () {
        isFarmer = true;
        Get.back();
      },
      onCancel: () {
        Get.back(); // Eğer iptal edilirse müşteri olarak devam eder
      },
    );

    return isFarmer;
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Kullanıcı giriş yapmadı

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // Kullanıcıya "Çiftçi misiniz?" sorusunu soralım, cevap vermezse müşteri kabul edelim
          bool isFarmer = await askUserIfFarmer();

          // Kullanıcıyı Firestore'a kaydet
          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email ?? "",
            'createdAt': Timestamp.now(),
            'isFarmer': isFarmer,
            'messageQuota': isFarmer ? 10 : 3,
            'isProfileComplete': !isFarmer,
            'fcmToken': await messaging.getToken(),
          }, SetOptions(merge: true));
        }
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Kullanıcı girişi
  Future<User?> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  // Kullanıcı çıkışı
  Future<void> signOut() async {
    try {
      var userId = user.value?.uid;
      // tokenı sıfırla
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'fcmToken': null});
      }
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print(e);
    }
  }

  // Kullanıcı mevcut mu kontrolü
  Future<User?> getCurrentUser() async {
    User? user = _auth.currentUser;
    return user;
  }

  // Şifre sıfırlama
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Kullanıcıyı Firestore'dan silme
  Future<void> deleteUser() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      print("Error: $e");
    }
  }

  Future<void> addFavoriteCity(
      {required String cityId,
      required String cityName,
      required double lat,
      required double lon}) async {
    try {
      if (user.value == null) {
        throw ();
      }
      // Firestore'da users/{userId}/favorites koleksiyonuna şehir ekliyoruz
      await _firestore
          .collection("users")
          .doc(user.value!.uid)
          .collection("favorites")
          .doc(cityId)
          .set({
        "cityName": cityName,
        "latitude": lat,
        "longitude": lon,
        "addedAt": FieldValue.serverTimestamp(), // Eklenme tarihi
      }, SetOptions(merge: true));
    } catch (e) {
      Get.snackbar("Hata", "Favorilere eklenirken bir hata oluştu ❌");
      print("Favori şehir ekleme hatası: $e");
      rethrow;
    }
  }

  Future<void> removeFavoriteCity(String cityId) async {
    try {
      if (user.value == null) {
        throw ();
      }
      await _firestore
          .collection("users")
          .doc(user.value!.uid)
          .collection("favorites")
          .doc(cityId)
          .delete();
    } catch (e) {
      Get.snackbar("Hata", "Favori şehir silinemedi ❌");
      print("Favori şehir silme hatası: $e");
    }
  }

  Future<bool> checkFavoriteStatus(String cityId) async {
    try {
      if (user.value == null) {
        throw ();
      }
      var doc = await _firestore
          .collection("users")
          .doc(user.value!.uid)
          .collection("favorites")
          .doc(cityId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}

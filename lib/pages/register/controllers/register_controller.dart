import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth/auth_service.dart';

class RegisterController extends GetxController {
  final _authService = Get.find<AuthService>();

  final isPasswordObscure = true.obs;
  final isConfirmPasswordObscure = true.obs;
  final Rx<bool> isFarmerTab = true.obs;
  final Rx<bool> showPasswordFields =
      true.obs; // Şifre alanlarını göstermek için

  // Ülke kodları listesi
  final List<String> countryCodes = ['+90', '+1', '+44', '+49', '+33'];
  final Rx<String> selectedCountryCode = '+90'.obs; // Varsayılan olarak Türkiye

  @override
  void dispose() {
    formGroup.dispose();
    _authService.dispose();
    super.dispose();
  }

  @override
  void onInit() {
    super.onInit();

    // Kullanıcının username girişini dinle
    formGroup.control('username').valueChanges.listen((value) {
      if (value is String) {
        updatePasswordVisibility(value);
      }
    });
  }

  void toggleFarmerStatus() {
    isFarmerTab.value = !isFarmerTab.value;
  }

  final formGroup = FormGroup({
    'username': FormControl<String>(
      validators: [Validators.required],
    ),
    'password': FormControl<String>(
      // Şifre zorunlu değil, sadece email için aktif olacak
      validators: [],
    ),
    'confirmPassword': FormControl<String>(
      // Şifre tekrar alanı da email için olacak
      validators: [],
    ),
  }, validators: []);

  void updatePasswordVisibility(String input) {
    if (GetUtils.isEmail(input)) {
      showPasswordFields.value = true;
      formGroup.control('password').setValidators([
        Validators.required,
        Validators.minLength(6),
      ]);
      formGroup.control('confirmPassword').setValidators([
        Validators.required,
      ]);
    } else if (GetUtils.isPhoneNumber(input)) {
      showPasswordFields.value = false;
      formGroup.control('password').clearValidators();
      formGroup.control('confirmPassword').clearValidators();
    }
    formGroup.control('password').updateValueAndValidity();
    formGroup.control('confirmPassword').updateValueAndValidity();
  }

  Future<void> register(BuildContext context) async {
    if (formGroup.valid) {
      String username = formGroup.control('username').value as String;
      final isFarmer = isFarmerTab.value;

      if (_isValidPhoneNumber(username)) {
        username =
            selectedCountryCode.value + username; // Alan kodunu ekliyoruz
        await _registerWithPhoneNumber(username, isFarmer);
      } else if (_isValidEmail(username)) {
        final password = formGroup.control('password').value as String;
        await _registerWithEmail(username, password, isFarmer);
      } else {
        Get.snackbar(
          'Invalid Input',
          'Please enter a valid email or phone number.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'Invalid Input',
        'Please fill all fields correctly.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
    }
  }

  bool _isValidEmail(String input) {
    return GetUtils.isEmail(input);
  }

  bool _isValidPhoneNumber(String input) {
    return GetUtils.isPhoneNumber(input);
  }

  Future<void> _registerWithEmail(
      String email, String password, bool isFarmer) async {
    try {
      final User? user = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        isFarmer: isFarmer,
      );
      if (user != null) {
        await user.sendEmailVerification();
        Get.toNamed(Routes.EMAILVERIFICATION, arguments: {'email': email});
      } else {
        Get.snackbar(
          'Registration Error',
          'An unexpected error occurred during registration.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _handleAuthError(e);
    }
  }

  Future<void> _registerWithPhoneNumber(
      String phoneNumber, bool isFarmer) async {
    try {
      await _authService.registerWithPhoneNumber(
        phoneNumber: phoneNumber,
        isFarmer: isFarmer,
      );
    } catch (e) {
      _handleAuthError(e);
    }
  }

  void _handleAuthError(dynamic e) {
    String errorMessage;
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
              'This email is already in use. Please try another one.';
          break;
        case 'invalid-email':
          errorMessage =
              'The email address is not valid. Please check and try again.';
          break;
        case 'weak-password':
          errorMessage =
              'The password is too weak. Please choose a stronger password.';
          break;
        case 'operation-not-allowed':
          errorMessage =
              'Registration is currently disabled. Please contact support.';
          break;
        case 'network-request-failed':
          errorMessage =
              'Network error. Please check your connection and try again.';
          break;
        default:
          errorMessage =
              'An unexpected error occurred. Please try again later.';
      }
    } else {
      errorMessage = 'An error occurred: ${e.toString()}';
    }
    Get.snackbar(
      'Registration Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }
}

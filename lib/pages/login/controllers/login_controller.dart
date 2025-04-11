import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  var rememberMe = false.obs;
  final isPasswordObscure = true.obs;
  final Rx<bool> showPasswordFields = true.obs;
  final List<String> countryCodes = ['+90', '+1', '+44', '+49', '+33'];
  final Rx<String> selectedCountryCode = '+90'.obs;

  final formGroup = FormGroup({
    'username': FormControl<String>(validators: [Validators.required]),
    'password': FormControl<String>(validators: []),
  });

  @override
  void onInit() {
    super.onInit();
    formGroup.control('username').valueChanges.listen((value) {
      if (value is String) {
        updatePasswordVisibility(value);
      }
    });
  }

  void changeRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  void updatePasswordVisibility(String input) {
    if (GetUtils.isEmail(input)) {
      showPasswordFields.value = true;
      formGroup.control('password').setValidators([Validators.required]);
    } else if (GetUtils.isPhoneNumber(input)) {
      showPasswordFields.value = false;
      formGroup.control('password').clearValidators();
    }
    formGroup.control('password').updateValueAndValidity();
  }

  @override
  void dispose() {
    formGroup.dispose();
    _authService.dispose();
    super.dispose();
  }

  Future<void> loginWithGoogle() async {
    try {
      await _authService.signInWithGoogle();
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      Get.snackbar("Hata", "Google ile giriş yapılamadı: $e");
    }
  }

  Future<void> login(BuildContext context) async {
    if (formGroup.valid) {
      String username = formGroup.control('username').value;
      final password = formGroup.control('password').value;

      try {
        if (GetUtils.isEmail(username)) {
          await _authService.signInWithEmailAndPassword(
            email: username,
            password: password,
          );
          Get.offAllNamed(Routes.HOME);
        } else if (GetUtils.isPhoneNumber(username)) {
          username = selectedCountryCode.value + username;
          await _authService.signInWithPhoneNumber(
            phoneNumber: username,
          );
        } else {
          Get.snackbar(
            'Invalid Input',
            'Please enter a valid email or phone number.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orangeAccent,
            colorText: Colors.white,
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found for that email.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password. Please try again.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          case 'invalid-phone-number':
            errorMessage = 'The phone number is not valid.';
            break;
          default:
            errorMessage =
                'An unexpected error occurred. Please try again later.';
        }
        Get.snackbar(
          'Login Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar(
          'Login Error',
          'An unexpected error occurred. Please try again later.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      Get.snackbar(
        'Invalid Input',
        'Please fill in all fields',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

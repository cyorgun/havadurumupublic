import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:havadurumu/services/auth/auth_service.dart';

class ForgotPasswordController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final AuthService _authService = Get.find<AuthService>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void resetPassword() async {
    if (formKey.currentState!.validate()) {
      try {
        _authService.resetPassword(emailController.text);
        Get.snackbar("success".tr, "passwordResetEmailSent".tr,
            backgroundColor: Colors.green, colorText: Colors.white);
      } catch (e) {
        Get.snackbar("error".tr, e.toString(),
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }
}

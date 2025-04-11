import 'package:get/get.dart';

import '../controllers/forgotPassword_controller.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotPasswordController>(
      ForgotPasswordController.new,
    );
  }
}

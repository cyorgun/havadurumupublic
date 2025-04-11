import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth/auth_service.dart';

class EmailVerificationView extends StatefulWidget {
  @override
  _EmailVerificationViewState createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService authService = Get.find<AuthService>();
  bool isLoading = false;
  bool isResending = false;

  Future<void> checkEmailVerified() async {
    setState(() => isLoading = true);
    try {
      User? user = _auth.currentUser;
      await user?.reload();
      if (user != null && user.emailVerified) {
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.snackbar('verificationError'.tr, 'emailNotVerified'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('errorText'.tr, 'errorOccurred'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> resendVerificationEmail() async {
    setState(() => isResending = true);
    try {
      await _auth.currentUser?.sendEmailVerification();
      Get.snackbar('verificationEmail'.tr, 'newVerificationEmailSent'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.greenAccent,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('errorText'.tr, 'verificationEmailFailed'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      setState(() => isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await authService.signOut();
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('verifyEmail'.tr),
          automaticallyImplyLeading: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          'verificationEmailSent'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : checkEmailVerified,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'verifiedMyEmail'.tr,
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed:
                              isResending ? null : resendVerificationEmail,
                          child: isResending
                              ? CircularProgressIndicator()
                              : Text('resendVerificationEmail'.tr),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../colors/app_colors.dart';
import '../../../dimens/dimens.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/custom_widgets/blur_container.dart';
import '../../../shared/custom_widgets/circular_image.dart';
import '../../../shared/custom_widgets/curved_header.dart';
import '../../../shared/custom_widgets/forms/reactive_custom_text_field.dart';
import '../../../shared/custom_widgets/gradient_button.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final curvedBoxHeight = MediaQuery.of(context).size.height * .34;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          backgroundColor: Colors.transparent,
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Stack(
            children: [
              CurvedHeader(height: curvedBoxHeight),
              ListView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(top: kToolbarHeight),
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: (curvedBoxHeight / 2) -
                          (Dimens.logoHeight / 2) -
                          kToolbarHeight,
                    ),
                    child: CircularImage(
                      imageAddress: 'assets/images/icon.png',
                      width: Dimens.logoSize,
                      height: Dimens.logoSize,
                    ),
                  ),
                  _userInfoBox(context),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 70),
                    child: SignInButton(
                      Buttons.Google,
                      onPressed: () {
                        controller.loginWithGoogle();
                      },
                    ),
                  ),
                  Align(
                    child: TextButton(
                      onPressed: () {
                        Get.toNamed(Routes.REGISTER);
                      },
                      child: Column(
                        children: [
                          Text(
                            'noMember'.tr,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'register'.tr,
                            style: TextStyle(
                              fontSize: Dimens.medium2FontSize,
                              color: AppColors.textButtonColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userInfoBox(context) {
    return Stack(
      children: [
        BlurContainer(
          child: ReactiveForm(
            formGroup: controller.formGroup,
            child: Column(
              children: [
                Obx(() {
                  return Row(
                    children: [
                      if (!controller.showPasswordFields.value)
                        _countryCodeDropdown(),
                      Expanded(
                        child: ReactiveCustomTextField<String>(
                          key: const Key('username'),
                          formControlName: 'username',
                          labelText: 'username'.tr,
                          prefixIcon: Icons.account_circle,
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 20),
                Obx(() {
                  return Visibility(
                    visible: controller.showPasswordFields.value,
                    child: ReactiveCustomTextField<String>(
                      key: const Key('password'),
                      formControlName: 'password',
                      labelText: 'password'.tr,
                      prefixIcon: Icons.lock,
                      obscureText: controller.isPasswordObscure.value,
                      suffixIcon: IconButton(
                        onPressed: () {
                          controller.isPasswordObscure.value =
                              !controller.isPasswordObscure.value;
                        },
                        icon: Icon(
                          controller.isPasswordObscure.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.inputIconColor,
                        ),
                      ),
                    ),
                  );
                }),
                SizedBox(
                  height: 38,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Get.toNamed(Routes.FORGOTPASSWORD);
                      },
                      child: Text(
                        'forgotPass'.tr,
                        style: TextStyle(
                          fontSize: Dimens.smallFontSize,
                          color: AppColors.textButtonColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 60,
          right: 60,
          bottom: Dimens.buttonHeight / 2,
          child: GradientButton(
            key: const Key('login_button'),
            text: 'login'.tr.toUpperCase(),
            onPressed: () {
              FocusScope.of(context).unfocus();
              controller.login(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _countryCodeDropdown() {
    return Obx(() {
      return DropdownButton<String>(
        value: controller.selectedCountryCode.value,
        items: controller.countryCodes
            .map((code) => DropdownMenuItem(
                  value: code,
                  child: Text(code),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            controller.selectedCountryCode.value = value;
          }
        },
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../colors/app_colors.dart';
import '../../../dimens/dimens.dart';
import '../../../shared/custom_widgets/blur_container.dart';
import '../../../shared/custom_widgets/curved_header.dart';
import '../../../shared/custom_widgets/forms/reactive_custom_text_field.dart';
import '../../../shared/custom_widgets/gradient_button.dart';
import '../../../shared/custom_widgets/toggle_widget.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

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
                  Obx(() => Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 100.0,
                            vertical: (curvedBoxHeight / 2) -
                                (Dimens.logoHeight / 2) -
                                kToolbarHeight -
                                10),
                        child: ToggleSwitch(
                          firstTabName: "farmer".tr,
                          secondTabName: "standard".tr,
                          isFirstTab: controller.isFarmerTab.value,
                          onToggle: controller.toggleFarmerStatus,
                          selectionWidth: 100,
                          selectedColor: controller.isFarmerTab.value
                              ? Colors.green
                              : Colors.blue,
                          unselectedColor: Colors.grey.shade300,
                          textStyle: TextStyle(
                            color: controller.isFarmerTab.value
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                  Obx(() => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(
                                  controller.isFarmerTab.value ? 0.2 : 0.0),
                              // Hafif transparan arka plan
                              borderRadius: BorderRadius.circular(
                                  12), // Köşeleri yuvarlatma
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            child: Visibility(
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              visible: controller.isFarmerTab.value,
                              child: Text(
                                "farmerInfoButton".tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textColor),
                              ),
                            )),
                      )),
                  _userInfoBox(context),
                  Align(
                    child: TextButton(
                      onPressed: () {
                        Get.back(); // Kullanıcıyı login sayfasına geri döndür
                      },
                      child: Text(
                        'alreadyHaveAccount'.tr,
                        style: TextStyle(
                          fontSize: Dimens.medium2FontSize,
                          color: AppColors.textButtonColor,
                          fontWeight: FontWeight.bold,
                        ),
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
                      if (!controller.showPasswordFields
                          .value) // Yalnızca telefon için göster
                        _countryCodeDropdown(), // Ülke kodu seçici
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
                    child: Column(
                      children: [
                        ReactiveCustomTextField<String>(
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
                        const SizedBox(height: 20),
                        ReactiveCustomTextField<String>(
                          key: const Key('confirm_password'),
                          formControlName: 'confirmPassword',
                          labelText: 'confirmPassword'.tr,
                          prefixIcon: Icons.lock,
                          obscureText:
                              controller.isConfirmPasswordObscure.value,
                          suffixIcon: IconButton(
                            onPressed: () {
                              controller.isConfirmPasswordObscure.value =
                                  !controller.isConfirmPasswordObscure.value;
                            },
                            icon: Icon(
                              controller.isConfirmPasswordObscure.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.inputIconColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        Positioned(
          left: 60,
          right: 60,
          bottom: Dimens.buttonHeight / 2,
          child: Column(
            children: [
              GradientButton(
                key: const Key('register_button'),
                text: 'register'.tr.toUpperCase(),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  controller.register(context);
                },
              ),
            ],
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

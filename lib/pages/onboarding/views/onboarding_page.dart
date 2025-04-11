import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../routes/app_routes.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('first_time') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isFirstTime(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data == false) {
          Future.microtask(() => Get.offAllNamed(Routes.HOME));
          return const SizedBox.shrink();
        }
        return Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: PageView(
                  controller: controller.pageController,
                  onPageChanged: (index) => controller.pageIndex.value = index,
                  children: [
                    OnboardingPage(
                      backgroundImage: 'assets/images/onboarding1.jpg',
                      image: 'assets/images/icon.png',
                      description: 'appName'.tr,
                    ),
                    OnboardingPage(
                      backgroundImage: 'assets/images/onboarding1.jpg',
                      title: 'onboardingTitle2'.tr,
                      description: 'onboardingDescription2'.tr,
                      showButton: true,
                      onButtonPressed: controller.nextPage,
                    ),
                  ],
                ),
              ),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      2,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 20),
                        width: controller.pageIndex.value == index ? 12 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: controller.pageIndex.value == index
                              ? Colors.white
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String backgroundImage;
  final String? title;
  final String? image;
  final String description;
  final bool showButton;
  final VoidCallback? onButtonPressed;

  OnboardingPage({
    required this.backgroundImage,
    this.title,
    this.image,
    required this.description,
    this.showButton = false,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Image.asset(backgroundImage, fit: BoxFit.cover),
        ),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              title != null
                  ? Text(
                      title!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    )
                  : Image.asset(
                      image!,
                      height: 70,
                      width: 70,
                    ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(color: Colors.white, fontSize: 22),
                textAlign: TextAlign.center,
              ),
              if (showButton)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: onButtonPressed,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child: Text(
                      'start'.tr,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

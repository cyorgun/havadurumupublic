import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:havadurumu/pages/home/widgets/ad_banner.dart';
import 'package:havadurumu/pages/home/widgets/splash_page.dart';

import '../../../colors/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth/auth_service.dart';
import '../../../shared/custom_widgets/app_bar/custom_app_bar_widget.dart';
import '../../../shared/shared_prefs_helper.dart';
import '../controllers/ad_controller.dart';
import '../controllers/home_controller.dart';
import '../tabs/ai/views/ai_page.dart';
import '../tabs/forecast/views/forecast_tab.dart';
import '../tabs/hourly/views/hourly_tab.dart';
import '../tabs/weekly/views/weekly_tab.dart';
import 'complete_profile_page.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});

  final AuthService _authService = Get.find<AuthService>();
  final AdController adController = Get.put(AdController());

  final tabList = [
    const ForecastView(),
    HourlyView(),
    const WeeklyView(),
    AIView(),
  ];

  @override
  Widget build(BuildContext context) {
    controller.initSplash();
    _authService.checkUserVerification();
    return Obx(() => Stack(
          children: [
            controller.authService.userData.value?["isProfileComplete"] ?? true
                ? HomeContent(controller: controller, tabList: tabList)
                : CompleteProfilePage(),
            controller.shouldSplashShow.value ? const SplashView() : Container()
          ],
        ));
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({
    super.key,
    required this.controller,
    required this.tabList,
  });

  final HomeController controller;
  final List<Widget> tabList;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: CustomAppBarWidget(
            onSelectedCityChanged: (result) {
              controller.selectedCityModel.value = result;
              if (!controller.lastSearchedCityModels
                  .map((element) => element.name)
                  .toList()
                  .contains(result.name)) {
                controller.lastSearchedCityModels.add(result);
              }
              controller.fetchForecast();
            },
          ),
          drawer: Drawer(
            child: Column(
              children: [
                // Drawer Header
                DrawerHeader(
                  margin: EdgeInsets.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  // Varsayılan padding'i sıfırlıyoruz
                  decoration: BoxDecoration(
                    gradient: AppColors.buttonGradient,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (controller.authService.user.value != null) {
                                  Get.toNamed(Routes.NOTIFICATIONS);
                                }
                              },
                              child: const CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.notifications,
                                  size: 30,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.authService.user.value?.email ??
                                      controller.authService.user.value
                                          ?.phoneNumber ??
                                      "",
                                  style: TextStyle(color: AppColors.textColor),
                                ),
                                GestureDetector(
                                    onTap: () {
                                      controller.authService.user.value == null
                                          ? Get.toNamed(Routes.LOGIN)
                                          : controller.authService.signOut();
                                    },
                                    child: Text(
                                      controller.authService.user.value == null
                                          ? "signin".tr
                                          : "signout".tr,
                                      style:
                                          TextStyle(color: AppColors.textColor),
                                    )),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'recentCities'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'recentCitiesDescription'.tr,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ListView
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(top: 4),
                    color: AppColors.darkBackground,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: controller.lastSearchedCityModels.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.location_on,
                                color: Colors.blueAccent,
                              ),
                              title: Text(
                                controller.lastSearchedCityModels[index].name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textColor,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
                              onTap: () {
                                controller.selectedCityModel.value =
                                    controller.lastSearchedCityModels[index];
                                controller.loadFavoriteStatus();
                                controller.fetchForecast();

                                SharedPrefsHelper.setMainCity(
                                    cityModel:
                                        controller.selectedCityModel.value);
                                Navigator.pop(context);
                              },
                            ),
                            Divider(
                              color: Colors.grey.shade300,
                              thickness: 1,
                              indent: 16,
                              endIndent: 16,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Obx(
            () => controller.isLoadingVisible.value
                ? CustomLoadingIndicator()
                : Stack(
                    children: [
                      IndexedStack(
                        index: controller.selectedBottomBarItemIndex.value,
                        children: tabList,
                      ),
                      AdBanner(),
                    ],
                  ),
          ),
          bottomNavigationBar: Obx(() => Container(
                //TODO: deco gereksiz
                decoration: BoxDecoration(gradient: AppColors.buttonGradient),
                child: BottomNavigationBar(
                  currentIndex: controller.selectedBottomBarItemIndex.value,
                  selectedItemColor: AppColors.activeIconColor,
                  unselectedItemColor: AppColors.iconColor2,
                  items: [
                    BottomNavigationBarItem(
                      backgroundColor: AppColors.darkBackground,
                      icon: const Icon(
                        Icons.sunny,
                      ),
                      label: "forecastTab".tr,
                    ),
                    BottomNavigationBarItem(
                      backgroundColor: AppColors.darkBackground,
                      icon: const Icon(
                        Icons.access_time_filled,
                      ),
                      label: "hourlyTab".tr,
                    ),
                    BottomNavigationBarItem(
                      backgroundColor: AppColors.darkBackground,
                      icon: const Icon(
                        Icons.calendar_month,
                      ),
                      label: "weeklyTab".tr,
                    ),
                    BottomNavigationBarItem(
                      backgroundColor: AppColors.darkBackground,
                      icon: const Icon(
                        Icons.psychology,
                      ),
                      label: "aiTab".tr,
                    ),
                  ],
                  onTap: (index) {
                    controller.selectedBottomBarItemIndex.value = index;
                  },
                ),
              )),
        ));
  }
}

class CustomLoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;
  final bool isVisible;

  CustomLoadingIndicator(
      {this.size = 50.0, this.color = Colors.blue, this.isVisible = true});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Container(
        color: AppColors.darkBackground,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(color),
            strokeWidth: 6.0,
          ),
        ),
      ),
    );
  }
}

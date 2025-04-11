import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:havadurumu/colors/app_colors.dart';
import 'package:havadurumu/dimens/dimens.dart';
import 'package:havadurumu/models/CityModel.dart';
import 'package:havadurumu/routes/app_routes.dart';

import 'custom_app_bar_controller.dart';

class CustomAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final Widget? titleWidget;
  final Function(CityModel) onSelectedCityChanged;

  CustomAppBarWidget({
    super.key,
    this.titleWidget,
    required this.onSelectedCityChanged,
  });

  final CustomAppBarController controller = Get.put(CustomAppBarController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppBar(
        iconTheme: IconThemeData(color: AppColors.iconColor),
        actions: [
          Visibility(
            visible: controller.selectedCityModel.value.id != "?" &&
                controller.authService.user.value != null,
            child: IconButton(
              icon: Icon(
                controller.selectedCityModel.value.isFavorite
                    ? Icons.star
                    : Icons.star_outline,
                color: controller.selectedCityModel.value.isFavorite
                    ? Colors.yellow
                    : Colors.white,
                size: 30,
              ),
              onPressed: controller.toggleFavoriteStatus,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.search,
              color: AppColors.iconColor,
              size: 30,
            ),
            onPressed: () async {
              try {
                Get.toNamed(Routes.SEARCH)?.then((result) {
                  if (result != null) {
                    onSelectedCityChanged(result as CityModel);
                    controller.updateCity(result);
                  }
                });
              } catch (_) {}
            },
          ),
        ],
        title: titleWidget ??
            Text(
              controller.selectedCityModel.value.name,
              style: TextStyle(color: AppColors.textColor),
            ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.buttonGradient),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(Dimens.appBarSize);
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:havadurumu/pages/home/tabs/forecast/widgets/circular_wind_indicator.dart';

import '../../../../../colors/app_colors.dart';
import '../../../../../dimens/dimens.dart';
import '../widgets/animated_floating_panel.dart';
import '../widgets/dynamic_sky.dart';
import '../controllers/forecast_controller.dart';

class ForecastView extends StatefulWidget {
  const ForecastView({super.key});

  @override
  State<ForecastView> createState() => _ForecastViewState();
}

class _ForecastViewState extends State<ForecastView> {
  final ForecastController controller = Get.put(ForecastController());

  final GlobalKey columnKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getColumnHeight();
    });
  }

  void getColumnHeight() {
    //TODO: arada hata veriyor sanki
    final RenderBox? renderBox =
        columnKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      controller.columnHeight.value = renderBox.size.height;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Stack(
        children: [
          controller.homeController.isDataFetched.value
              ? DynamicSky(
                  weatherData: controller.homeController.weatherData.value,
                  onValueChanged: (newHour) {
                    controller.updateNewHourData(newHour);
                  })
              : Container(),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: Dimens.forecastTabMargin,
                  top: Dimens.forecastTabMargin,
                  right: Dimens.forecastTabMargin,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      key: columnKey,
                      children: [
                        Text(
                          "${"today".tr} ${controller.getHourAndMinutes()}",
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: Dimens.mediumFontSize,
                            fontWeight: Dimens.fontWeight,
                          ),
                        ),
                        Text(
                          "${controller.getCurrentDegree()}°",
                          style: TextStyle(
                              fontSize: Dimens.temperatureFontSize,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor),
                        ),
                        Text(
                          "${"feelsLike".tr} ${controller.getFeelsLike()}°",
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: Dimens.mediumFontSize,
                            fontWeight: Dimens.fontWeight,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 170,
                      height: controller.columnHeight.value,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(
                                  right: Dimens.forecastTabMargin),
                              child: CircularWindIndicator(
                                angle: controller.getWindAngle(),
                                text: controller.getWindSpeed(),
                              )),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            maxLines: 2,
                            textAlign: TextAlign.end,
                            controller.getWindText(),
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontSize: Dimens.mediumFontSize,
                              fontWeight: Dimens.fontWeight,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: Dimens.forecastTabMargin),
                child: Stack(
                  children: [
                    IgnorePointer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.getForecastSummary(),
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontSize: Dimens.largeFontSize,
                              fontWeight: Dimens.fontWeight,
                            ),
                          ),
                          Row(
                            children: [
                              Row(
                                children: [
                                  controller.newHourData.value != null
                                      ? Container()
                                      : Icon(
                                          Icons.keyboard_arrow_up,
                                          color: AppColors.iconColor,
                                        ),
                                  Text(
                                    controller.getMaxMinTempC(true),
                                    style: TextStyle(
                                      color: AppColors.textColor,
                                      fontWeight: Dimens.fontWeight,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Row(children: [
                                controller.newHourData.value != null
                                    ? Container()
                                    : Icon(
                                        Icons.keyboard_arrow_down,
                                        color: AppColors.iconColor,
                                      ),
                                Text(
                                  controller.getMaxMinTempC(false),
                                  style: TextStyle(
                                    color: AppColors.textColor,
                                    fontWeight: Dimens.fontWeight,
                                  ),
                                )
                              ])
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      alignment: Alignment.bottomRight,
                      child: AnimatedFloatingPanel(),
                    )
                  ],
                ),
              ))
            ],
          ),
        ],
      ),
    );
  }
}

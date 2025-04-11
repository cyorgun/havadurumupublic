import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../../../dimens/dimens.dart';
import '../../../shared/custom_widgets/blur_container.dart';
import '../../../shared/custom_widgets/circular_image.dart';
import '../../../shared/custom_widgets/curved_header.dart';
import '../../../shared/custom_widgets/gradient_button.dart';
import '../controllers/complete_profile_page_controller.dart';

class CompleteProfilePage extends StatelessWidget {
  final controller = Get.put(CompleteProfilePageController());
  final TextEditingController newProductController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  CompleteProfilePage({super.key});

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
                  Stack(
                    children: [
                      BlurContainer(
                        child: ReactiveForm(
                          formGroup: controller.formGroup,
                          child: Column(
                            children: [
                              MultiSelectDialogField(
                                buttonText: Text("select".tr),
                                items: controller.products
                                    .map((e) => MultiSelectItem<String>(e, e))
                                    .toList(),
                                title: Text('selectCrop'.tr),
                                initialValue: controller.formGroup
                                    .control("products")
                                    .value,
                                searchable: true,
                                searchHint: 'search'.tr,
                                onConfirm: (values) {
                                  controller.formGroup
                                      .control("products")
                                      .value = values;
                                },
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: newProductController,
                                        decoration: InputDecoration(
                                          labelText: 'addNewProduct'.tr,
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle,
                                          color: Colors.green),
                                      onPressed: () {
                                        String newProduct =
                                            newProductController.text.trim();
                                        if (newProduct.isNotEmpty &&
                                            !controller.products
                                                .contains(newProduct)) {
                                          controller.products.add(newProduct);

                                          // Reactive Form'un değerini güncelle ve UI'ı refresh et
                                          final updatedProducts =
                                              List<String>.from(controller
                                                      .formGroup
                                                      .control("products")
                                                      .value ??
                                                  []);
                                          updatedProducts.add(newProduct);
                                          controller.formGroup
                                              .control("products")
                                              .updateValue(updatedProducts);

                                          newProductController.clear();
                                          FocusScope.of(context)
                                              .unfocus(); // Klavyeyi ve focus'u kapat
                                          controller.update();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    labelText: 'yearlyTonnage'.tr),
                                onChanged: (value) {
                                  controller.formGroup
                                      .control("tonnage")
                                      .value = int.tryParse(value) ?? 0;
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              LocationSelector(controller: controller),
                              const SizedBox(
                                height: 10,
                              ),
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
                              key: const Key('save_button'),
                              text: 'continue'.tr.toUpperCase(),
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                controller.done();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

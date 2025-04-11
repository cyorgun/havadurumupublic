import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_controller.dart' as c;

import '../../../colors/app_colors.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final c.SearchController controller = Get.find<c.SearchController>();
  final TextEditingController textController = TextEditingController();

  void onSearchTextChanged(String text) {
    controller.isSearchActive.value = text.isNotEmpty;
    controller.search(text);
  }

  void clearSearch() {
    textController.clear();
    controller.isSearchActive.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: AppColors.iconColor,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            backgroundColor: AppColors.darkBackground,
            automaticallyImplyLeading: true,
            titleSpacing: 0,
            title: TextField(
              controller: textController,
              style: TextStyle(
                color: AppColors.textColor,
              ),
              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: AppColors.textColor,
                ),
                hintText: 'search'.tr,
                border: InputBorder.none,
                filled: false,
                fillColor: Colors.white10,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                suffixIcon: controller.isSearchActive.value
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: clearSearch,
                      )
                    : null,
              ),
              onChanged: onSearchTextChanged,
            ),
          ),
          body: Container(
            color: AppColors.darkBackground,
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: controller.cities.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        minTileHeight: 65,
                        onTap: () {
                          Get.back(result: controller.cities[index]);
                        },
                        title: Text(
                          controller.cities[index].name +
                              " / " +
                              controller.cities[index].country,
                          style: TextStyle(color: AppColors.textColor),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(
                        color: Colors.white,
                        thickness: 1,
                        height: 1,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

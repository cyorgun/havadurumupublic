import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/ad_controller.dart';

class AdBanner extends StatelessWidget {
  final AdController adController = Get.find<AdController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!adController.isAdVisible.value || adController.adData.isEmpty) {
        return const SizedBox.shrink();
      }
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: GestureDetector(
          onTap: () async {
            try {
              var urlString = adController.adData["link"];
              if (urlString != null && urlString.isNotEmpty) {
                Uri url = Uri.parse(urlString);
                if (!await launchUrl(url,
                    mode: LaunchMode.externalApplication)) {
                  throw Exception("Could not launch $url");
                }
              } else {
                print("no valid url");
              }
            } catch (e) {
              print("Error launching URL: $e");
            }
          },
          child: Container(
            height: MediaQuery.of(context).size.height * 0.20,
            color: Colors.white,
            child: Stack(
              children: [
                if (adController.adData["image"] != null)
                  Image.network(
                    width: double.infinity,
                    adController.adData["image"],
                    fit: BoxFit.cover,
                  ),
                Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          adController.adData["title"] ?? "",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          adController.adData["body"] ?? "",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => adController.closeAd(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../colors/app_colors.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../shared/custom_widgets/toggle_widget.dart';
import '../controllers/ai_controller.dart';

class AIView extends StatelessWidget {
  final AIController controller = Get.put(AIController());

  AIView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        centerTitle: true,
        title: Obx(() => controller.shouldShowAI()
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ToggleSwitch(
                  firstTabName: "question".tr,
                  secondTabName: "prediction".tr,
                  isFirstTab: controller.isQuestionMode.value,
                  onToggle: controller.toggleMode,
                ),
              )
            : Container()),
      ),
      body: Obx(() {
        return controller.shouldShowAI()
            ? controller.isQuestionMode.value
                ? const QuestionModeUI()
                : const EmptyPage()
            : SigninWidget(user: controller.authService.user.value);
      }),
    );
  }
}

class SigninWidget extends StatelessWidget {
  final User? user;

  const SigninWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            user == null ? "signinPrompt".tr : "onlyFarmers".tr,
            style: TextStyle(color: AppColors.textColor),
          ),
          const SizedBox(height: 10),
          user == null
              ? ElevatedButton(
                  onPressed: () {
                    Get.toNamed(Routes.LOGIN);
                  },
                  child: Text("signin".tr),
                )
              : Container(),
        ],
      ),
    );
  }
}

class QuestionModeUI extends StatelessWidget {
  const QuestionModeUI({super.key});

  @override
  Widget build(BuildContext context) {
    final AIController controller = Get.find();
    final TextEditingController textController = TextEditingController();

    return Column(
      children: [
        Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    if (message.text != null) {
                      final isUserMessage = message.text!.startsWith("You:");
                      return Align(
                        alignment: isUserMessage
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color:
                                isUserMessage ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                message.text!,
                                style: TextStyle(
                                    color: isUserMessage
                                        ? Colors.white
                                        : Colors.black),
                              ),
                              isUserMessage
                                  ? Container()
                                  : GestureDetector(
                                      onTap: () =>
                                          controller.speakText(message.text!),
                                      child: const Icon(Icons.volume_up,
                                          size: 20, color: Colors.black),
                                    ),
                            ],
                          ),
                        ),
                      );
                    } else if (message.image != null) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Image.memory(
                            message.image!,
                            fit: BoxFit.cover,
                            width: 160,
                            height: 160,
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ))),
        if (controller.isLoading.value)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        // Görsel yükleme butonu
        Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: Colors.grey[400],
            border: const Border(top: BorderSide(color: Colors.grey)),
          ),
          child: Row(
            children: [
              ImagePickerWidget(
                onImageSelected: (image) {
                  controller.uploadImage(image);
                },
              ),
              Obx(() => Container(
                    padding: const EdgeInsets.all(0.0),
                    width: 35.0,
                    child: IconButton(
                      icon: GestureDetector(
                        child: Icon(
                          controller.isListening.value
                              ? Icons.mic
                              : Icons.mic_none,
                        ),
                      ),
                      onPressed: () {
                        if (controller.isListening.value) {
                          controller.stopListening();
                        } else {
                          controller.startListening();
                        }
                      },
                    ),
                  )),
              const SizedBox(
                width: 7,
              ),
              Obx(
                () => ToggleButton(
                  isActive: controller.isTextToSpeechEnabled.value,
                  onTap: () => controller.toggleTextToSpeech(),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 150, // Maksimum yükseklik belirliyoruz
                  ),
                  child: TextField(
                    controller: textController,
                    minLines: 1,
                    maxLines: null,
                    // Sonsuz satır için null kullanıyoruz
                    decoration: InputDecoration(
                      hintText: "typeMessage".tr,
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType
                        .multiline, // Çok satırlı girişe izin veriyoruz
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  final messageQuota =
                      controller.authService.userData.value?["messageQuota"] ??
                          0;

                  if (messageQuota > 0) {
                    final message = textController.text.trim();
                    if (message.isNotEmpty) {
                      controller.sendMessage(message);
                      textController.clear();
                    }
                  } else {
                    Get.snackbar(
                      "quotaFull".tr,
                      "dailyMessageQuotaOverMessage".tr,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withOpacity(0.8),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 3),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("pageEmptyForNowMessage".tr),
    );
  }
}

class ToggleButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const ToggleButton({super.key, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? Colors.blue.shade700 : Colors.transparent,
              width: 2,
            ),
          ),
          child: Icon(Icons.volume_up)),
    );
  }
}

class ImagePickerWidget extends StatelessWidget {
  final Function(XFile) onImageSelected;

  const ImagePickerWidget({Key? key, required this.onImageSelected})
      : super(key: key);

  Future<void> _showImageSourceSelector(BuildContext context) async {
    final imagePicker = ImagePicker();

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: Text("Galeriden Seç".tr),
                onTap: () async {
                  Navigator.pop(context); // BottomSheet'i kapat
                  final XFile? image =
                      await imagePicker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    onImageSelected(image); // Seçilen resmi geri döndür
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text("Fotoğraf Çek".tr),
                onTap: () async {
                  Navigator.pop(context); // BottomSheet'i kapat
                  final XFile? image =
                      await imagePicker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    onImageSelected(image); // Çekilen resmi geri döndür
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0.0),
      width: 35.0,
      child: IconButton(
          onPressed: () => _showImageSourceSelector(context),
          icon: const Icon(Icons.image)),
    );
  }
}

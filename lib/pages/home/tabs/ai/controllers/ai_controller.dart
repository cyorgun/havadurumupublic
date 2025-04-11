import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../../lang/translation_service.dart';
import '../../../../../services/auth/auth_service.dart';

class AIController extends GetxController {
  var isQuestionMode = true.obs;
  var isLoading = false.obs;
  var messages = <Message>[].obs;
  final RxBool isTextToSpeechEnabled = false.obs; // TTS açık/kapalı
  final FlutterTts flutterTts = FlutterTts();
  var speechToText = SpeechToText();
  var isListening = false.obs;
  var speechText = "".obs;
  final AuthService authService = Get.find<AuthService>();

  final String deepSeekApiKey = '';
  final String visionApiUrl =
      'https://vision.googleapis.com/v1/images:annotate?key=';
  final String visionApiKey = '';

  AIController() {
    _configureTTS();
  }

  bool shouldShowAI() {
    return authService.userData.value?["isFarmer"] ?? false;
  }

  void toggleMode() {
    isQuestionMode.value = !isQuestionMode.value;
  }

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.isEmpty) {
      return;
    }
    addMessage(Message(text: "You: $userMessage"));
    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse('https://api.deepseek.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $deepSeekApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "deepseek-chat",
          "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": userMessage},
          ],
          "max_tokens": 150,
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        await decreaseMessageQuota();
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'];
        addMessage(Message(text: "AI: $reply"));
      } else {
        addMessage(Message(text: "AI: An error occurred."));
      }
    } catch (e) {
      addMessage(Message(text: "AI: Failed to connect."));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadImage(XFile image) async {
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    addMessage(Message(image: bytes));

    final requestBody = jsonEncode({
      "requests": [
        {
          "image": {
            "content": base64Image,
          },
          "features": [
            {
              "type": "LABEL_DETECTION",
              "maxResults": 10,
            },
          ],
        }
      ],
    });

    try {
      final response = await http.post(
        Uri.parse(visionApiUrl + visionApiKey),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final labels = responseBody['responses'][0]['labelAnnotations'];

        String resultMessage = "Detected Labels: ";
        for (var label in labels) {
          resultMessage += label['description'] + ", ";
        }
        await sendToDeepSeek(resultMessage);
      } else {
        addMessage(Message(text: "AI: Failed to analyze image."));
      }
    } catch (e) {
      addMessage(Message(text: "AI: Failed to connect."));
    }
  }

  //sesli mesaj almak için

  void _configureTTS() async {
    var langCode = Messages.mapLocale();
    await flutterTts.setLanguage(langCode); // Türkçe seslendirme
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  void toggleTextToSpeech() {
    isTextToSpeechEnabled.value = !isTextToSpeechEnabled.value;
  }

  void speakText(String text) async {
    await flutterTts.speak(text);
  }

  void addMessage(Message message) {
    messages.add(message);
    var isUserMessage =
        message.text == null ? false : message.text!.startsWith("You:");
    if (!isUserMessage && isTextToSpeechEnabled.value) {
      speakText(message.text!);
    }
  }

  //sesli mesaj göndermek için

  Future<void> startListening() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      bool available = await speechToText.initialize(
        onStatus: (status) {
          print("Speech status: $status");
          if (status == "not listening") {
            stopListening();
          } else if (status == "listening") {
          } else if (status == "done") {
            stopListening();
            sendMessage(speechText.value);
          }
        },
        onError: (error) {
          print("Speech error: $error");
        },
      );
      if (available) {
        isListening.value = true;
        speechToText.listen(onResult: (result) {
          speechText.value = result.recognizedWords;
        });
      }
    } else {
      Get.snackbar("İzin Gerekli", "Mikrofon izni verilmedi.");
    }
  }

  void stopListening() {
    speechToText.stop();
    isListening.value = false;
  }

  Future<void> decreaseMessageQuota() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("Kullanıcı oturum açmamış.");
      return;
    }

    final userRef = FirebaseFirestore.instance.collection("users").doc(userId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          print("Kullanıcı bulunamadı.");
          return;
        }

        final currentQuota = userDoc.data()?["messageQuota"] ?? 0;

        if (currentQuota > 0) {
          transaction.update(userRef, {"messageQuota": currentQuota - 1});
          print("Mesaj hakkı 1 azaltıldı. Yeni quota: ${currentQuota - 1}");
        } else {
          print("Mesaj hakkınız kalmadı.");
        }
      });
    } catch (e) {
      print("Hata oluştu: $e");
    }
  }

  Future<void> sendToDeepSeek(String visionResult) async {
    try {
      // DeepSeek API endpoint'i ve API anahtarınızı buraya ekleyin
      const String apiUrl =
          "https://api.deepseek.com/v1/chat/completions"; // DeepSeek endpoint'i

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $deepSeekApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "deepseek-chat", // DeepSeek model adı
          "messages": [
            {
              "role": "system",
              "content":
                  "You are an agricultural expert. Your task is to identify if the input relates to a plant disease or not, and respond accordingly."
            },
            {
              "role": "user",
              "content": """
Here are the detected labels from an image: $visionResult.

1. If the labels describe a plant disease, provide the following:
   - The name of the disease.
   - How it affects plants.
   - The cause of the disease.
   - Solutions or treatments.

2. If the labels do not describe a plant disease, respond with:
   'This is not related to a plant disease. Could you provide more details or a clearer image?'
"""
            }
          ],
          "max_tokens": 300, // Maksimum token sayısı
          "temperature": 0.7, // Yaratıcılık seviyesi
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'];
        messages.add(Message(text: "AI: $reply"));
      } else {
        print("DeepSeek error response: ${response.body}");
        messages.add(Message(
            text:
                "AI: An error occurred. Status Code: ${response.statusCode}"));
      }
    } catch (e) {
      messages.add(Message(text: "AI: Failed to connect. Error: $e"));
    }
  }
}

class Message {
  final String? text;
  final Uint8List? image; // Görselin URL'si ya da görselin base64 kodu

  Message({this.text, this.image});
}

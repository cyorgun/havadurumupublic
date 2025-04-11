import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth/auth_service.dart';

class NotificationsController extends GetxController {
  var notifications = <NotificationItem>[].obs;
  final _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  // Bildirimleri çeken fonksiyon
  Future<void> fetchNotifications() async {
    try {
      // İlk olarak genel bildirimleri alıyoruz
      List<NotificationItem> fetchedNotifications = [];

      // 'general' targetAudience'lı bildirimleri al
      var generalNotifications = await _firestore
          .collection('notifications')
          .where('targetAudience', isEqualTo: 'general')
          .orderBy('timestamp', descending: true) // En son eklenenler üstte
          .get();

      fetchedNotifications.addAll(generalNotifications.docs.map((doc) {
        return NotificationItem.fromJson(doc.data());
      }).toList());

      // Eğer kullanıcı bir farmer ise 'farmers' targetAudience'lı bildirimleri de alıyoruz
      if (_authService.userData.value?["isFarmer"] ?? false) {
        var farmerNotifications = await _firestore
            .collection('notifications')
            .where('targetAudience', isEqualTo: 'farmers')
            .orderBy('timestamp', descending: true)
            .get();

        fetchedNotifications.addAll(farmerNotifications.docs.map((doc) {
          return NotificationItem.fromJson(doc.data());
        }).toList());
      }

      // Kullanıcıya özel bildirimleri alıyoruz
      var userNotifications = await _firestore
          .collection('users')
          .doc(_authService.userData.value?["id"])
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .get();

      fetchedNotifications.addAll(userNotifications.docs.map((doc) {
        return NotificationItem.fromJson(doc.data());
      }).toList());

      // Tüm bildirimleri tarihe göre sıralıyoruz
      fetchedNotifications.sort((a, b) => b.date.compareTo(a.date));

      // Sıralanmış bildirimleri notifications listesine ekliyoruz
      notifications.assignAll(fetchedNotifications);
    } catch (e) {
      print("Error fetching notifications: $e");
    }
  }
}

class NotificationItem {
  String title;
  String message;
  DateTime date;
  String type;
  String targetAudience;

  NotificationItem({
    required this.title,
    required this.message,
    required this.date,
    required this.type,
    required this.targetAudience,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    var timestamp = json['timestamp'];
    DateTime date =
        (timestamp is Timestamp) ? timestamp.toDate() : DateTime.now();
    return NotificationItem(
      title: json['title'],
      message: json['message'],
      date: date,
      type: json['type'],
      targetAudience: json['targetAudience'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'timestamp': Timestamp.fromDate(date),
      'type': type,
      'targetAudience': targetAudience,
    };
  }
}

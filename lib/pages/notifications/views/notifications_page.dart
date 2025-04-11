import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("notifications".tr),
      ),
      body: Obx(() => controller.notifications.isEmpty
          ? Center(child: Text("noNotifications".tr))
          : ListView.builder(
              itemCount: controller.notifications.length,
              itemBuilder: (context, index) {
                final notification = controller.notifications[index];
                return GestureDetector(
                  onTap: () {},
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      title: Text(
                        notification.title,
                      ),
                      subtitle: Text(notification.message),
                      trailing: Text(
                        "${notification.date.hour}:${notification.date.minute}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                );
              },
            )),
    );
  }
}

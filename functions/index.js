const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
const axios = require("axios");
const API_KEY = "";

admin.initializeApp();
const db = admin.firestore();

exports.resetMessageQuota = functions.pubsub
  .schedule("every day 00:00")
  .timeZone("Europe/Istanbul") // Türkiye saat dilimi
  .onRun(async (context) => {
    const usersRef = admin.firestore().collection("users");

    try {
      const snapshot = await usersRef.get();
      const batch = admin.firestore().batch();

      snapshot.forEach((doc) => {
        const isFarmer = doc.data().isFarmer || false;
        const newQuota = isFarmer ? 10 : 3;

        batch.update(doc.ref, { messageQuota: newQuota });
      });

      await batch.commit();
      console.log("Tüm kullanıcıların mesaj kotası yenilendi.");
    } catch (error) {
      console.error("Mesaj kotası sıfırlanırken hata oluştu:", error);
    }
  });

exports.checkWeatherAlerts = functions.pubsub
    .schedule("every 12 hours")
    .timeZone("Europe/Istanbul")
    .onRun(async (context) => {
        try {
            const usersSnapshot = await db.collection("users").get();

            let notifications = [];

            for (const userDoc of usersSnapshot.docs) {
                const userId = userDoc.id;
                const favoritesSnapshot = await db.collection(`users/${userId}/favorites`).get();

                for (const favDoc of favoritesSnapshot.docs) {
                    const cityData = favDoc.data();

                    const latitude = cityData.latitude.toString()
                    const longitude = cityData.longitude.toString()

                    const alertApiUrl = `http://api.weatherapi.com/v1/alerts.json?key=${API_KEY}&q=${latitude},${longitude}`;

                    const response = await axios.get(alertApiUrl);
                    const alerts = response.data.alerts?.alert;

                    if (alerts && alerts.length > 0) {
                        notifications.push({
                            userId,
                            city: cityData.cityName,
                            alerts
                        });
                        // save to db
                        const alertData = {
                            title: "⚠️ " + cityData.cityName + " ⚠️️️️",
                            message: alert.headline,
                            image: null,
                            timestamp: admin.firestore.FieldValue.serverTimestamp(),
                            type: "alert",
                            targetAudience: "personal",
                        };
                        await db.collection("users/${userId}/notifications").add(alertData);
                    } else {
                       console.log("no weather alerts detected");
                    }
                }
            }

            await sendPushNotifications(notifications);
        } catch (error) {
            console.error("Error fetching alerts:", error);
        }
    });

async function sendPushNotifications(notifications) {
    for (const notif of notifications) {
        const userDoc = await db.collection("users").doc(notif.userId).get();
        const fcmToken = userDoc.data().fcmToken;

        if (!fcmToken) {
           console.warn(`⚠️ Kullanıcının FCM Token'ı yok: ${notif.userId}`);
           continue;
        }

        if (fcmToken) {
            const payload = {
                notification: {
                    title: `⚠️ ${notif.city} için hava durumu uyarısı!`,
                    body: notif.alerts[0].headline,
                },
                token: fcmToken
            };

            try {
                await admin.messaging().send(payload);
                console.log(`Bildirim gönderildi: ${notif.city}`);
            } catch (error) {
                console.error("Bildirim gönderilemedi:", error);
            }
        }
    }
}

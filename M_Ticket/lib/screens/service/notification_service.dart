// lib/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  final String serverKey = 'AIzaSyANFckqZV8lHzXtOewvdjX1mpNZH2llOgM';

  Future<void> sendNotification(String title, String body) async {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Formateur')
        .get();

    for (var userDoc in usersSnapshot.docs) {
      final String? token = userDoc['fcmToken']; // Assurez-vous que vous stockez le token FCM des utilisateurs
      if (token != null) {
        await sendNotificationToToken(token, title, body);
      }
    }
  }

  Future<void> sendNotificationToToken(String token, String title, String body) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final Map<String, dynamic> notification = {
      'to': token,
      'notification': {
        'title': title,
        'body': body,
      },
    };

    final http.Response response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: headers,
      body: jsonEncode(notification),
    );

    if (response.statusCode == 200) {
      print('Notification envoyée avec succès.');
    } else {
      print('Erreur lors de l\'envoi de la notification: ${response.body}');
    }
  }
}

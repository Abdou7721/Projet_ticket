import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:m_ticket/screens/login_page.dart';



// Fonction pour gérer les messages en arrière-plan
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Traitement des notifications ou autre logique
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCCOrktRjWHm1bo_HpaOqGwfEonzgUJYog",
        authDomain: "projet1-c2fba.firebaseapp.com",
        projectId: "projet1-c2fba",
        storageBucket: "projet1-c2fba.appspot.com",
        messagingSenderId: "675354525036",
        appId: "1:675354525036:web:9ca004b6de1d05e0b74749",
        measurementId: "G-HMC69LNLYS",
      ),
    );
  } else {
    // Configurer Firebase pour Android ou iOS
    await Firebase.initializeApp();

    // Configurer le gestionnaire des messages en arrière-plan
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // Initialiser les paramètres de notifications locales
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,

    );


  }

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

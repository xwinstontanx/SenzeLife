import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:senzelifeflutterapp/firebase_options_senzepact.dart';
import 'package:senzelifeflutterapp/src/app.dart';
// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'messaging_service.dart'; // Generated file

MessagingService _msgService = MessagingService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
  ;await Firebase.initializeApp(
      options: SecondaryFirebaseOptions.currentPlatform, name: "secondary");

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await _msgService.init();

  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('zh'), Locale('ms')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: App()),
  );

  EasyLocalization.logger.enableBuildModes = [];
}

/// Top level function to handle incoming messages when the app is in the background
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message");
}

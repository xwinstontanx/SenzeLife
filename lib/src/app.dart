import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:senzelifeflutterapp/src/screens/BottomNavIcons.dart';
import 'package:senzelifeflutterapp/src/screens/Dashboard.dart';
import 'package:senzelifeflutterapp/src/screens/ForgotPassword.dart';
import 'package:senzelifeflutterapp/src/screens/Home/Home.dart';
import 'package:senzelifeflutterapp/src/screens/demo.dart';
import 'package:senzelifeflutterapp/src/screens/Login.dart';

class App extends StatelessWidget {
  const App({super.key});


  @override
  Widget build(BuildContext context) {

    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.circle
      ..loadingStyle = EasyLoadingStyle.custom
      ..textStyle = const TextStyle(
        color: Colors.blue,
        fontSize: 18,
        fontWeight: FontWeight.w400,
      )
      ..backgroundColor = Colors.grey.shade100
      ..textColor = Colors.black
      ..indicatorColor = Colors.blue
      ..maskColor = Colors.black
      ..userInteractions = false
      ..dismissOnTap = false;
    return MaterialApp(
      title: "SenzeLife",
      theme: ThemeData(
        useMaterial3: false,
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routes: {
        // '/': (context) => kIsWeb ? const DemoPage() : const LoginScreen(),
        '/': (context) => FirebaseAuth.instance.currentUser != null ? const BottomNavIcons() : const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/login': (context) => const LoginScreen(),
        '/forgotpassword': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomePage(),
      },
      builder: EasyLoading.init(),
    );
  }
}


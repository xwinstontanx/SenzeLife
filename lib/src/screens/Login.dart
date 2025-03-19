import 'package:app_version_update/app_version_update.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:persistent_bottom_nav_bar_plus/persistent_bottom_nav_bar_plus.dart';
import 'package:senzelifeflutterapp/src/screens/CreateAccount.dart';
import 'package:senzelifeflutterapp/src/screens/ForgotPassword.dart';
import 'package:senzelifeflutterapp/src/screens/BottomNavIcons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

import '../service/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true;
  String version = "";

  @override
  void initState() {
    super.initState();
    checkInternetConnectivity();
    _verifyVersion();
    getVersion();

    // emailController.text = "proz_174@hotmail.com";
    // passwordController.text = "Test1234!";

    emailController.text = "";
    passwordController.text = "";
  }

  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.ethernet) {
      return true;
    } else {
      dialog(DialogType.error, 'Error'.tr(), 'No internet is available'.tr());
      return false;
    }
  }

  late final AnimationController _controller = AnimationController(
    lowerBound: 0.4,
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInSine,
  );

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  void _verifyVersion() async {
    await AppVersionUpdate.checkForUpdates(
            appleId: '6448743999',
            playStoreId: 'com.senzehub.senzelife',
            country: 'sg')
        .then((data) async {
      if (data.canUpdate!) {
        await AppVersionUpdate.showAlertUpdate(
          appVersionResult: data,
          context: context,
          backgroundColor: Colors.grey[200],
          title: 'New Version Available'.tr(),
          content: 'Do you want to proceed for update?'.tr(),
          updateButtonText: 'Yes'.tr(),
          cancelButtonText: 'No'.tr(),
          titleTextStyle: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w500, fontSize: 20.0),
          contentTextStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w300,
          ),
        );
      }
    });
  }

  Future<void> _launchEmail() async {
    if (!await launchUrl(Uri.parse(
        "mailto:contact@senzehub.com?subject=Enquiry From SenzeLife App&body="))) {
      throw 'Could not launch contact@senzehub.com';
    }
  }

  void dialog(type, title, desc) {
    AwesomeDialog(
      context: context,
      dialogType: type,
      animType: AnimType.bottomSlide,
      title: title,
      desc: desc,
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: kIsWeb ? 600.0 : double.infinity,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 32.0, bottom: 32.0, left: 16, right: 16),
                    child: Container(
                      color: Colors.white,
                      child: FadeTransition(
                        opacity: _animation,
                        child: Center(
                            child: Image.asset(
                                'assets/images/senzelifeImage.png',
                                height: 100,
                                fit: BoxFit.fill)),
                      ),
                    ),
                  ),
                  Card(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.black26, width: 1),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                      elevation: 7,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Text(
                              'Existing User'.tr(),
                              style: TextStyle(
                                  color: Colors.indigo[900],
                                  fontSize: 18,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 15, bottom: 0),
                            child: TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: 'Email'.tr(),
                                hintText: '',
                                prefixIcon: const Icon(Icons.email, size: 24),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 15, bottom: 0),
                            child: TextField(
                              controller: passwordController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: 'Password'.tr(),
                                hintText: '',
                                prefixIcon:
                                    const Icon(Icons.lock_rounded, size: 24),
                                suffixIcon: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 4, 0),
                                  child: GestureDetector(
                                    onTap: _toggle,
                                    child: Icon(
                                      _obscureText
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 50,
                            width: 250,
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20)),
                            child: TextButton(
                              onPressed: () => login(emailController.text,
                                  passwordController.text),
                              child: Text(
                                'Login'.tr(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const ForgotPasswordScreen()));
                            },
                            child: Text(
                              'FORGOT PASSWORD'.tr(),
                              style: const TextStyle(
                                  color: Colors.blue, fontSize: 15),
                            ),
                          ),
                        ],
                      )),
                  // const Padding(
                  //   padding: EdgeInsets.fromLTRB(0, 20, 0, 30),
                  //   child: Text(
                  //     '-------------------- or --------------------',
                  //     style: TextStyle(color: Colors.grey, fontSize: 20),
                  //   ),
                  // ),
                  Card(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black26, width: 1),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                    elevation: 7,
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Text(
                              'New User'.tr(),
                              style: TextStyle(
                                  color: Colors.indigo[900],
                                  fontSize: 18,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            height: 50,
                            width: 250,
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20)),
                            child: TextButton(
                              onPressed: () => {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const CreateAccountScreen("email")))
                              },
                              child: Text(
                                'CREATE ACCOUNT'.tr(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                    child: Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context1) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    title: Text('ENGLISH'.tr()),
                                    onTap: () async {
                                      context.setLocale(const Locale('en'));
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: Text('CHINESE'.tr()),
                                    onTap: () async {
                                      context.setLocale(const Locale('zh'));
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: Text('MALAY'.tr()),
                                    onTap: () async {
                                      context.setLocale(const Locale('ms'));
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Change Language".tr()),
                            const Icon(Icons.language,
                                size: 30, color: Colors.blue),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                    child: Column(
                      children: [
                        Text(
                          'For enquiries'.tr(),
                          style: const TextStyle(
                              color: Colors.black, fontSize: 15, height: 0.0),
                        ),
                        GestureDetector(
                          onTap: _launchEmail,
                          child: const Text(
                            'contact@senzehub.com',
                            style: TextStyle(
                                color: Colors.blue, fontSize: 15, height: 0.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'V$version',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getDeviceInfo() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'DeviceModel': androidInfo.model,
        'DeviceSystemVersion': androidInfo.version.release
      });
    } else if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'DeviceModel': iosInfo.model,
        'DeviceSystemVersion': iosInfo.systemVersion
      });
    }
  }

  Future<void> login(email, password) async {
    if (email != "" && password != "" && password.length > 5) {
      EasyLoading.show(status: 'Loading'.tr());
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        final user = userCredential.user;
        if (user?.emailVerified == true) {
          if (user != null) {
            await UserService().setUser(FirebaseAuth.instance.currentUser!.uid);

            // Update fcm token
            String? fcmToken = "";
            if (!kIsWeb) {
              fcmToken = await FirebaseMessaging.instance.getToken();
            }

            // Update last login
            FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .update({
              'LastLoginAt': DateTime.now(),
              'LastLaunchAt': DateTime.now()
            });

            // Update log history
            FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .collection('LogHistory')
                .add({
              'CreatedAt': DateTime.now(),
              'From': 'Mobile',
              'Action': 'Login'
            });

            await getDeviceInfo();

            EasyLoading.dismiss();

            // Navigate to Bottom Navigation
            if (!mounted) return;
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const BottomNavIcons(),
            );
          }
        } else {
          EasyLoading.dismiss();
          dialog(DialogType.error, 'Error'.tr(),
              'Please verify email in your inbox/junk'.tr());
        }
      } on FirebaseAuthException catch (e) {
        EasyLoading.dismiss();
        dialog(
            DialogType.error, 'Error'.tr(), 'Incorrect login credential'.tr());
        // if (e.code == 'user-not-found') {
        //   dialog(DialogType.error, 'Error'.tr(),
        //       'No user found for that email'.tr());
        //   // print('No user found for that email.');
        // } else if (e.code == 'wrong-password') {
        //   dialog(DialogType.error, 'Error'.tr(),
        //       'Wrong password provided for that user'.tr());
        //   // print('Wrong password provided for that user');
        // }
      }
    } else {
      EasyLoading.dismiss();
      dialog(DialogType.error, 'Error'.tr(), 'Fill in required fields'.tr());
    }
  }
}

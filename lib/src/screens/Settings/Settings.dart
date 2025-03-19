import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:senzelifeflutterapp/src/screens/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:senzelifeflutterapp/src/screens/Responsive/FormFactor.dart';
import 'package:senzelifeflutterapp/src/screens/Settings/Alert.dart';
import 'package:senzelifeflutterapp/src/screens/Settings/CaregiversList.dart';
import 'package:senzelifeflutterapp/src/screens/Settings/DevicesList.dart';
import 'package:senzelifeflutterapp/src/screens/Settings/Profile.dart';
import 'package:senzelifeflutterapp/src/service/user_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String version = "";

  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  retrieveData() async {
    await getVersion();
  }

  Future<void> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  signout() async {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'FcmToken': ''});
    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('LogHistory')
        .add({
      'CreatedAt': DateTime.now(),
      'From': 'Mobile',
      'Action': 'Logout'
    });

    FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const LoginScreen();
        },
      ),
      (_) => false,
    );
  }

  Future<void> _launchEmail() async {
    if (!await launchUrl(Uri.parse(
        "mailto:contact@senzehub.com?subject=Enquiry From SenzeLife App&body="))) {
      throw 'Could not launch contact@senzehub.com';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
      child: Scaffold(
        appBar: AppBar(
          title: Text('SETTINGS'.tr()),
          automaticallyImplyLeading: false,
          actions: const <Widget>[],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: kIsWeb ? FormFactor.desktop : double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, bottom: 0.0, left: 10, right: 10),
                        child: NiceButtons(
                            stretch: true,
                            borderRadius: 30,
                            startColor: Colors.blue,
                            endColor: Colors.blue,
                            borderColor: Colors.blue,
                            onTap: (finish) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const ProfilePage()));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.person_outline_outlined,
                                    size: 40.0,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      'Profile'.tr(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 30.0, bottom: 0.0, left: 10, right: 10),
                        child: NiceButtons(
                            stretch: true,
                            borderRadius: 30,
                            startColor: Colors.blue,
                            endColor: Colors.blue,
                            borderColor: Colors.blue,
                            gradientOrientation: GradientOrientation.Vertical,
                            onTap: (finish) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const DevicesListPage()));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.sensors,
                                    size: 40.0,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      'DEVICES LIST'.tr(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 30.0, bottom: 0.0, left: 10, right: 10),
                        child: NiceButtons(
                            stretch: true,
                            borderRadius: 30,
                            startColor: Colors.blue,
                            endColor: Colors.blue,
                            borderColor: Colors.blue,
                            onTap: (finish) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const AlertSettingsPage()));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_alert,
                                    size: 40.0,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      'Alerts'.tr(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 30.0, bottom: 0.0, left: 10, right: 10),
                        child: NiceButtons(
                            stretch: true,
                            borderRadius: 30,
                            startColor: Colors.blue,
                            endColor: Colors.blue,
                            borderColor: Colors.blue,
                            gradientOrientation: GradientOrientation.Vertical,
                            onTap: (finish) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const CaregiverslistPage()));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.handshake,
                                    size: 40.0,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      'CAREGIVERS LIST'.tr(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 30.0, bottom: 0.0, left: 10, right: 10),
                        child: NiceButtons(
                            stretch: true,
                            borderRadius: 30,
                            startColor: Colors.blue,
                            endColor: Colors.blue,
                            borderColor: Colors.blue,
                            gradientOrientation: GradientOrientation.Vertical,
                            onTap: (finish) {
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      ListTile(
                                        title: Text('ENGLISH'.tr()),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          await context
                                              .setLocale(const Locale('en'));
                                          // Reload the app
                                          setState(() {
                                            context
                                                .setLocale(const Locale('en'));
                                          });
                                        },
                                      ),
                                      ListTile(
                                        title: Text('CHINESE'.tr()),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          await context
                                              .setLocale(const Locale('zh'));
                                          // Reload the app
                                          setState(() {
                                            context
                                                .setLocale(const Locale('zh'));
                                          });
                                        },
                                      ),
                                      ListTile(
                                        title: Text('MALAY'.tr()),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          await context
                                              .setLocale(const Locale('ms'));
                                          // Reload the app
                                          setState(() {
                                            context
                                                .setLocale(const Locale('ms'));
                                          });
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.language,
                                    size: 40.0,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      'CHANGE LANGUAGE'.tr(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 30.0, bottom: 0.0, left: 10, right: 10),
                        child: NiceButtons(
                            startColor: Colors.deepOrangeAccent,
                            endColor: Colors.deepOrangeAccent,
                            borderColor: Colors.deepOrangeAccent,
                            stretch: true,
                            borderRadius: 30,
                            gradientOrientation: GradientOrientation.Vertical,
                            onTap: (finish) {
                              signout();
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.logout,
                                    size: 40.0,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      'Logout'.tr(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                        child: Column(
                          children: [
                            Text(
                              'V$version',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  height: 0.0),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Column(
                          children: [
                            Text(
                              'For enquiries'.tr(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  height: 0.0),
                            ),
                            GestureDetector(
                              onTap: _launchEmail,
                              child: const Text(
                                'contact@senzehub.com',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                    height: 0.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

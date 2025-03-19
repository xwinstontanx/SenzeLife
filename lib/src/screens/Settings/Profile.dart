import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:senzelifeflutterapp/src/screens/Login.dart';
import 'package:senzelifeflutterapp/src/screens/Settings/Settings.dart';
import 'package:senzelifeflutterapp/src/service/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<ProfilePage> {
  var emailController = TextEditingController();
  var nameController = TextEditingController();
  var phoneController = TextEditingController();

  Map<String, dynamic>? userProfileV;

  @override
  void initState() {
    super.initState();

    nameController.text = UserService().user?.name ?? "";
    getProfile();
  }


  Future<void> getProfile() async {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        var profile = snapshot.data();

        setState(() {
          emailController.text = profile?['Email'] ?? "";
          phoneController.text = profile?['PhoneNumber'] ?? "";
        });
      } else {
        setState(() {
          emailController.text = "";
          phoneController.text = "";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop()),
        title: Text("Profile".tr()),
        actions: <Widget>[
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.delete_rounded),
                color: Colors.red,
                onPressed: () {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.warning,
                    animType: AnimType.bottomSlide,
                    title: "Delete Profile".tr(),
                    desc: "Are you sure you want to delete profile".tr(),
                    btnOkOnPress: () async {
                      // Add to DisabledAccount collection
                      FirebaseFirestore.instance
                          .collection('DisabledAccount')
                          .add({
                        'Uid': FirebaseAuth.instance.currentUser!.uid,
                        'CreatedAt': DateTime.now(),
                      }).then((value) => {
                                FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .update({'FcmToken': ''}),
                                FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('LogHistory')
                                    .add({
                                  'CreatedAt': DateTime.now(),
                                  'From': 'Mobile',
                                  'Action': 'DeleteAccount'
                                })
                              });
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.remove("userUid");
                      FirebaseAuth.instance.signOut();
                      if (!mounted) return;
                      Navigator.of(context, rootNavigator: true)
                          .pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return const LoginScreen();
                          },
                        ),
                        (_) => false,
                      );
                    },
                    btnCancelOnPress: () {},
                  ).show();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                child: TextField(
                  readOnly: true,
                  controller: nameController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Name'.tr(),
                      labelStyle:
                          const TextStyle(color: Colors.blue, fontSize: 16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                child: TextField(
                  readOnly: true,
                  controller: emailController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Email'.tr(),
                      labelStyle:
                          const TextStyle(color: Colors.blue, fontSize: 16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                child: TextField(
                  readOnly: true,
                  controller: phoneController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Phone Number'.tr(),
                      labelStyle:
                          const TextStyle(color: Colors.blue, fontSize: 16)),
                ),
              ),
              // Container(
              //   height: 50,
              //   width: 250,
              //   margin: const EdgeInsets.symmetric(vertical: 30),
              //   decoration: BoxDecoration(
              //       color: Colors.blue,
              //       borderRadius: BorderRadius.circular(20)),
              //   child: TextButton(
              //     onPressed: () => UpdateProfile(),
              //     child: Text(
              //       'Update Profile'.tr(),
              //       style: const TextStyle(color: Colors.white, fontSize: 15),
              //     ),
              //   ),
              // ),
              // const SizedBox(
              //   height: 80,
              // )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> UpdateProfile() async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.bottomSlide,
      // title: 'Profile'.tr(),
      desc: 'Proceed to submit your updated profile?'.tr(),
      btnOkOnPress: () {
        FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).update({
          'UpdatedAt': DateTime.now(),
          'Name': nameController.text,
          'PhoneNumber': phoneController.text,
        }).then(
          (value) => AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            // title: 'Profile'.tr(),
            desc: "Submitted Successfully".tr(),
            btnOkOnPress: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setString('userName', nameController.text);
              // getUser();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsPage()));
            },
            btnCancelOnPress: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setString('userName', nameController.text);
              // getUser();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsPage()));
            },
          ).show(),
        );
      },
      btnCancelOnPress: () {},
    ).show();
  }
}

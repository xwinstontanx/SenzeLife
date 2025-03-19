import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:nice_buttons/nice_buttons.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:senzelifeflutterapp/src/service/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Caregiver {
  String? uid;
  String? name;
  String? phoneNumber;
  String? createdAt;

  Caregiver({this.uid, this.name, this.phoneNumber, this.createdAt});
}

class CaregiverslistPage extends StatefulWidget {
  const CaregiverslistPage({super.key});

  @override
  State<CaregiverslistPage> createState() => _CaregiverslistPageState();
}

class _CaregiverslistPageState extends State<CaregiverslistPage> {
  var renderOverlay = true;
  var visible = true;
  var switchLabelPosition = false;
  var extend = false;
  var rmicons = false;
  var customDialRoot = false;
  var closeManually = false;
  var useRAnimation = true;
  var isDialOpen = ValueNotifier<bool>(false);
  var speedDialDirection = SpeedDialDirection.up;
  var buttonSize = const Size(56.0, 56.0);
  var childrenButtonSize = const Size(56.0, 56.0);
  var addCaregiverFlag = false;

  final phonenumberController = TextEditingController();

  List<Caregiver> caregiversList = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getCaregivers();
  }

  Future<void> getCaregivers() async {
    caregiversList = [];
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("CaregiversList")
        .get()
        .then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        FirebaseFirestore.instance
            .collection("Users")
            .where('Uid', isEqualTo: result.data()['Uid'])
            .get()
            .then((querySnapshot2) {
          for (var result2 in querySnapshot2.docs) {
            var date = result2.data()['CreatedAt'].toDate().toString();
            var time =
                '${Moment.parse(date).format('DD MMM YYYY')} ${Moment.parse(date).format('h:mm a')}';

            caregiversList.add(Caregiver(
                uid: result2.data()['Uid'],
                name: result2.data()['Name'],
                phoneNumber: result2.data()['PhoneNumber'],
                createdAt: time));
            setState(() {
              caregiversList:
              caregiversList.sort((b, a) =>
                  a.createdAt.toString().compareTo(b.createdAt.toString()));
            });
          }
          setState(() {
            isLoading = false;
          });
        });
      }
    });
  }

  Future<void> onPressedDelete(int index) async {
    var tempUid;
    tempUid = caregiversList[index].uid;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: "Delete Caregiver".tr(),
      desc:
          'Are you sure that you want to delete ${caregiversList[index].name} ${caregiversList[index].phoneNumber} ?',
      btnOkOnPress: () {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(tempUid)
            .collection("DeviceUnderCare")
            .get()
            .then((querySnapshot) {
          for (var result in querySnapshot.docs) {
            if (result.data()['MainUser'] == FirebaseAuth.instance.currentUser!.uid) {
              FirebaseFirestore.instance
                  .collection("Users")
                  .doc(tempUid)
                  .collection("DeviceUnderCare")
                  .doc(result.id)
                  .delete();
            }
          }
          FirebaseFirestore.instance
              .collection("Users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection("CaregiversList")
              .get()
              .then((querySnapshot2) {
            for (var result2 in querySnapshot2.docs) {
              if (result2.data()['Uid'] == tempUid) {
                FirebaseFirestore.instance
                    .collection("Users")
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection("CaregiversList")
                    .doc(result2.id)
                    .delete();
              }
            }
          });
          setState(() {
            caregiversList.removeAt(index);
          });
        });
      },
      btnCancelOnPress: () {},
    ).show();
  }

  pressAddCaregiver() {
    if (addCaregiverFlag == true) {
      setState(() {
        addCaregiverFlag = false;
      });
    } else {
      setState(() {
        addCaregiverFlag = true;
      });
    }
  }

  submitAddCaregiver(phonenumber) {
    if (phonenumber != "") {
      var csUserUid = "";
      FirebaseFirestore.instance
          .collection("Users")
          .where('PhoneNumber', isEqualTo: phonenumber)
          .get()
          .then((querySnapshot2) {
        if (querySnapshot2.size != 0) {
          querySnapshot2.docs.forEach((result) {
            csUserUid = result.data()['Uid'];

            if (csUserUid == FirebaseAuth.instance.currentUser!.uid) {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.error,
                animType: AnimType.bottomSlide,
                title: 'Error'.tr(),
                desc: 'Cannot key in your own phone number'.tr(),
                btnOkOnPress: () {},
              ).show();
            }
            if (csUserUid != FirebaseAuth.instance.currentUser!.uid) {
              if (caregiversList.any((caregiver) =>
                  caregiver.phoneNumber.toString() == phonenumber.toString())) {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.error,
                  animType: AnimType.bottomSlide,
                  title: 'Error'.tr(),
                  desc: 'Caregiver already added'.tr(),
                  btnOkOnPress: () {},
                ).show();
              } else {
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('CaregiversList')
                    .add({
                  'CreatedAt': DateTime.now(),
                  'FcmToken': result.data()['FcmToken'],
                  'Uid': csUserUid,
                }).then((value) => {
                          FirebaseFirestore.instance
                              .collection("Users")
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection("DeviceUnderCare")
                              .get()
                              .then((querySnapshot) {
                            querySnapshot.docs.forEach((result) {
                              FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(csUserUid)
                                  .collection('DeviceUnderCare')
                                  .add({
                                'CreatedAt': DateTime.now(),
                                'Address': result.data()['Address'],
                                'DeviceEui': result.data()['DeviceEui'],
                                'MainUser': FirebaseAuth.instance.currentUser!.uid,
                              });
                            });
                          }).then((value) => {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.success,
                                      animType: AnimType.bottomSlide,
                                      title: 'Caregiver Added'.tr(),
                                      desc: ''.tr(),
                                      btnOkOnPress: () {
                                        setState(() {
                                          addCaregiverFlag = false;
                                          phonenumberController.clear();
                                        });
                                        getCaregivers();
                                      },
                                    ).show(),
                                  })
                        });
              }
            }
          });
        } else {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Error'.tr(),
            desc: 'Caregiver Not Found'.tr(),
            btnOkOnPress: () {},
          ).show();
        }
      });
    } else if (phonenumber == "") {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Error'.tr(),
        desc: 'Fill in required fields'.tr(),
        btnOkOnPress: () {},
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('CAREGIVERS LIST'.tr()),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: const <Widget>[],
        ),
        body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? LoadingAnimationWidget.horizontalRotatingDots(
                    color: Colors.blue,
                    size: 50,
                  )
                : ListView(
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      if (addCaregiverFlag)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                // if you need this
                                side: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                )),
                            child: Column(
                              children: <Widget>[
                                const Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Text(
                                    'Add Caregiver',
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 25),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: phonenumberController,
                                    decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        labelText: 'Phone Number',
                                        hintText: 'Enter Phone Number'),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      NiceButtons(
                                        stretch: false,
                                        width: 150,
                                        startColor: Colors.blue,
                                        endColor: Colors.blue,
                                        borderColor: Colors.blue,
                                        gradientOrientation:
                                            GradientOrientation.Horizontal,
                                        onTap: (finish) {
                                          submitAddCaregiver(
                                              phonenumberController.text);
                                        },
                                        child: const Text(
                                          'Submit',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      NiceButtons(
                                        stretch: false,
                                        width: 150,
                                        startColor: Colors.red,
                                        endColor: Colors.red,
                                        borderColor: Colors.red,
                                        gradientOrientation:
                                            GradientOrientation.Horizontal,
                                        onTap: (finish) {
                                          pressAddCaregiver();
                                        },
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (caregiversList.isNotEmpty &&
                          addCaregiverFlag == false)
                        SizedBox(
                          width: 200,
                          height: 100.0 * caregiversList.length,
                          child: ListView.builder(
                            itemCount: caregiversList.length,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 6,
                                margin: const EdgeInsets.all(10),
                                child: ListTile(
                                  // tileColor: Colors.red,
                                  leading: const Icon(Icons.handshake),
                                  title: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            "${caregiversList[index].name} ${caregiversList[index].phoneNumber!}",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            "Added on ${caregiversList[index].createdAt!}",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 20.0,
                                        ),
                                        onPressed: () {
                                          onPressedDelete(index);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      if (caregiversList.isEmpty && addCaregiverFlag == false)
                        Center(
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                // if you need this
                                side: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                  width: 2,
                                )),
                            child: Padding(
                              padding: const EdgeInsets.all(25.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("Add Caregiver".tr(),
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                        "Click the + button on the right bottom to add caregiver"
                                            .tr(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.blue, fontSize: 13)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        floatingActionButton: addCaregiverFlag == false
            ? FloatingActionButton(
                onPressed: () {
                  pressAddCaregiver();
                },
                backgroundColor: Colors.blue,
                child: const Icon(Icons.add),
              )
            : const SizedBox(
                height: 0,
              ),
      ),
    );
  }
}

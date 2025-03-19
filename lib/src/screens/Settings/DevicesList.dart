import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:senzelifeflutterapp/src/screens/Settings/AddDevice.dart';
import 'package:senzelifeflutterapp/src/service/user_service.dart';
import '../../Model/device.dart';

class DevicesListPage extends StatefulWidget {
  const DevicesListPage({super.key});

  @override
  State<DevicesListPage> createState() => _DevicesListPageState();
}

class _DevicesListPageState extends State<DevicesListPage> {
  var editDeviceFlag = false;
  var visible = true;
  final addressController = TextEditingController();
  final deviceeuiController = TextEditingController();
  final _bedTime1Controller = TextEditingController();
  final _bedTime2Controller = TextEditingController();
  final _wakeTime1Controller = TextEditingController();
  final _wakeTime2Controller = TextEditingController();

  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
  DateFormat timeFormat = DateFormat("hh:mm a");

  bool isLoading = true;

  List<Device> devicesList = [];
  int currentEditIndex = 0;

  @override
  void initState() {
    super.initState();
    getDevices();
  }

  @override
  void dispose() {
    devicesList.clear();
    super.dispose();
  }

  Future<void> getDevices() async {
    devicesList = [];
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("DeviceUnderCare")
        .get()
        .then((querySnapshot) async {
      for (var result in querySnapshot.docs) {
        await FirebaseFirestore.instance
            .collection("Devices")
            .doc(result.data()['DeviceEui'])
            .get()
            .then((querySnapshot) {
          devicesList.add(Device(
            docID: result.id,
            deviceEui: result.data()['DeviceEui'],
            address: result.data()['Address'],
            mainUser: result.data()['MainUser'],
            createdAt:
                DateTime.parse(result.data()['CreatedAt']!.toDate().toString())
                    .toString(),
            wakeTime1: querySnapshot.data()?['WakeTime1'],
            wakeTime2: querySnapshot.data()?['WakeTime2'],
            bedTime1: querySnapshot.data()?['BedTime1'],
            bedTime2: querySnapshot.data()?['BedTime2'],
          ));
        });

        setState(() {
          devicesList:
          devicesList.sort(
              (b, a) => b.address.toString().compareTo(a.address.toString()));
        });
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('DEVICES LIST'.tr()),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: const <Widget>[],
          ),
          body: Container(
            alignment: Alignment.topCenter,
            child: isLoading
                ? LoadingAnimationWidget.horizontalRotatingDots(
                    color: Colors.blue,
                    size: 50,
                  )
                : editDeviceFlag
                    ? EditDevice()
                    : (devicesList.isNotEmpty)
                        ? ShowDevices(context)
                        : (devicesList.isEmpty)
                            ? EmptyDevice()
                            : const SizedBox(height: 0),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AddDevicePage()))
                  .then((_) => getDevices());
              // pressAddDevice();
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add),
          )),
    );
  }

  void onPressedEdit(int index, BuildContext context) {
    if (devicesList[index].mainUser ==
        FirebaseAuth.instance.currentUser?.uid) {
      setState(() {
        currentEditIndex = index;
        editDeviceFlag = true;
      });
    } else {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: '',
          message: 'Only the person who set up the device can edit the settings',

          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  Future<void> onPressedDelete(int index) async {
    String? tempDeviceEui;
    tempDeviceEui = devicesList[index].deviceEui;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: "Delete".tr(),
      desc: 'Are you sure to delete "${devicesList[index].address}" ?',
      btnOkOnPress: () {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("DeviceUnderCare")
            .doc(devicesList[index].docID)
            .delete()
            .then((value) => setState(() {
                  devicesList.removeAt(index);

                  // Erase current user
                  FirebaseFirestore.instance
                      .collection("Devices")
                      .doc(tempDeviceEui)
                      .collection("UserList")
                      .get()
                      .then((querySnapshot) {
                    for (var result in querySnapshot.docs) {
                      if (result.data()['UserUid'] ==
                          FirebaseAuth.instance.currentUser!.uid) {
                        FirebaseFirestore.instance
                            .collection("Devices")
                            .doc(tempDeviceEui)
                            .collection("UserList")
                            .doc(result.id)
                            .delete();
                      }
                    }

                    // If no user in the userlist, delete the device
                    FirebaseFirestore.instance
                        .collection("Devices")
                        .doc(tempDeviceEui)
                        .collection("UserList")
                        .get()
                        .then((querySnapshot) {
                      if (querySnapshot.docs.length == 0) {
                        FirebaseFirestore.instance
                            .collection("Devices")
                            .doc(tempDeviceEui)
                            .delete();
                      }
                    });
                  });

                  // for (int i = 0; i < caregiversList.length; i++) {
                  //   if (caregiversList[i].uid != null) {
                  //     FirebaseFirestore.instance
                  //         .collection("Users")
                  //         .doc(caregiversList[i].uid)
                  //         .collection("DeviceUnderCare")
                  //         .get()
                  //         .then((querySnapshot2) {
                  //       for (var result2 in querySnapshot2.docs) {
                  //         if (result2.data()['DeviceEui'] == tempDeviceEui) {
                  //           FirebaseFirestore.instance
                  //               .collection("Users")
                  //               .doc(caregiversList[i].uid)
                  //               .collection("DeviceUnderCare")
                  //               .doc(result2.id)
                  //               .delete();
                  //         }
                  //       }
                  //     });
                  //   }
                  // }
                }));
      },
      btnCancelOnPress: () {},
    ).show();
  }

  pressAddDevice() {
    deviceeuiController.text = "";
    addressController.text = "";
    _wakeTime1Controller.text = "";
    _wakeTime1Controller.text = "";
    _bedTime1Controller.text = "";
    _bedTime2Controller.text = "";
  }

  submitEditDevice(address, waking1, waking2, bed1, bed2) {
    if (address != "" &&
        waking1 != "" &&
        waking2 != "" &&
        bed1 != "" &&
        bed2 != "") {
      if (devicesList[currentEditIndex].wakeTime1 == null ||
          devicesList[currentEditIndex].wakeTime2 == null ||
          devicesList[currentEditIndex].bedTime1 == null ||
          devicesList[currentEditIndex].bedTime2 == null) {
        FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('DeviceUnderCare')
            .doc(devicesList[currentEditIndex].docID)
            .set({
          'Address': address,
        });

        FirebaseFirestore.instance
            .collection("Devices")
            .doc(devicesList[currentEditIndex].deviceEui)
            .set({
          'WakeTime1': waking1,
          'WakeTime2': waking2,
          'BedTime1': bed1,
          'BedTime2': bed2,
          'Location': address,
          'CreatedAt': DateTime.now(),
          'CreatedBy': FirebaseAuth.instance.currentUser!.uid,
        });
      } else {
        FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('DeviceUnderCare')
            .doc(devicesList[currentEditIndex].docID)
            .update({
          'Address': address,
        });

        FirebaseFirestore.instance
            .collection("Devices")
            .doc(devicesList[currentEditIndex].deviceEui)
            .update({
          'WakeTime1': waking1,
          'WakeTime2': waking2,
          'BedTime1': bed1,
          'BedTime2': bed2,
          'Location': address,
          'CreatedAt': DateTime.now(),
          'CreatedBy': FirebaseAuth.instance.currentUser!.uid,
        });
      }

      FirebaseFirestore.instance
          .collection("Users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("CaregiversList")
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) {
          FirebaseFirestore.instance
              .collection('Users')
              .doc(result.data()['Uid'])
              .collection('DeviceUnderCare')
              .where('DeviceEui',
                  isEqualTo: devicesList[currentEditIndex].deviceEui)
              .get()
              .then((querySnapshotDevice) {
            if (querySnapshotDevice.docs.isNotEmpty) {
              if (devicesList[currentEditIndex].wakeTime1 == null ||
                  devicesList[currentEditIndex].wakeTime2 == null ||
                  devicesList[currentEditIndex].bedTime1 == null ||
                  devicesList[currentEditIndex].bedTime2 == null) {
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(result.data()['Uid'])
                    .collection('DeviceUnderCare')
                    .doc(querySnapshotDevice.docs.first.id)
                    .set({
                  'Address': address,
                });
              } else {
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(result.data()['Uid'])
                    .collection('DeviceUnderCare')
                    .doc(querySnapshotDevice.docs.first.id)
                    .update({
                  'Address': address,
                });
              }
            }
          });
        });
      }).then((value) => {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.success,
                  animType: AnimType.bottomSlide,
                  title: 'Updated Successfully'.tr(),
                  desc: ''.tr(),
                  btnOkOnPress: () {
                    setState(() {
                      editDeviceFlag = false;
                      deviceeuiController.clear();
                      addressController.clear();
                      _wakeTime1Controller.clear();
                      _wakeTime2Controller.clear();
                      _bedTime1Controller.clear();
                      _bedTime2Controller.clear();
                    });
                    getDevices();
                  },
                ).show(),
              });
    } else {
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

  SizedBox ShowDevices(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: devicesList.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 6,
            margin: const EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    border: Border.all(
                      color: Colors.blue,
                      width: 2,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 30.0,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  onPressedEdit(index, context);
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  devicesList[index].address!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22),
                                ),
                                Text(
                                  devicesList[index].deviceEui!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 30.0,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  onPressedDelete(index);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.blue,
                      width: 2,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sunny,
                                  size: 25.0,
                                  color: Colors.yellow,
                                ),
                                Text(
                                  " Waking Time:",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 15),
                                ),
                              ],
                            ),
                            Text(
                              "${devicesList[index].wakeTime1 ?? ""} - ${devicesList[index].wakeTime2 ?? ""}",
                              style: const TextStyle(
                                  color: Colors.blue, fontSize: 18),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.nightlight,
                                  size: 25.0,
                                  color: Colors.yellow,
                                ),
                                Text(
                                  " Bed Time:",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 15),
                                ),
                              ],
                            ),
                            Text(
                              "${devicesList[index].bedTime1 ?? ""} - ${devicesList[index].bedTime2 ?? ""}",
                              style: const TextStyle(
                                  color: Colors.blue, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Center EmptyDevice() {
    return Center(
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
              Text("Add Device".tr(),
                  style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                    "Click the + button on the right bottom to add device".tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.blue, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding EditDevice() {
    deviceeuiController.text = devicesList[currentEditIndex].deviceEui!;
    addressController.text = devicesList[currentEditIndex].address!;
    _wakeTime1Controller.text = devicesList[currentEditIndex].wakeTime1 == null
        ? ""
        : devicesList[currentEditIndex].wakeTime1!;
    _wakeTime2Controller.text = devicesList[currentEditIndex].wakeTime2 == null
        ? ""
        : devicesList[currentEditIndex].wakeTime2!;
    _bedTime1Controller.text = devicesList[currentEditIndex].bedTime1 == null
        ? ""
        : devicesList[currentEditIndex].bedTime1!;
    _bedTime2Controller.text = devicesList[currentEditIndex].bedTime2 == null
        ? ""
        : devicesList[currentEditIndex].bedTime2!;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            // if you need this
            side: const BorderSide(
              color: Colors.blue,
              width: 2,
            )),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  'Edit Device'.tr(),
                  style: const TextStyle(color: Colors.blue, fontSize: 25),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Location'.tr()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _wakeTime1Controller,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Waking Time (From)'.tr(),
                    suffixIcon: IconButton(
                        onPressed: () {
                          DateTime wakeTime = DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day, 6, 0);
                          DatePicker.showTime12hPicker(context,
                              showTitleActions: true, onConfirm: (time) {
                            _wakeTime1Controller.text = timeFormat.format(time);
                          }, onCancel: () {
                            _wakeTime1Controller.text =
                                devicesList[currentEditIndex]
                                    .wakeTime1
                                    .toString();
                          }, currentTime: wakeTime);
                        },
                        icon: const Icon(Icons.access_time)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _wakeTime2Controller,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Waking Time (To)'.tr(),
                    suffixIcon: IconButton(
                        onPressed: () {
                          DateTime wakeTime = DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day, 6, 0);
                          DatePicker.showTime12hPicker(context,
                              showTitleActions: true, onConfirm: (time) {
                            _wakeTime2Controller.text = timeFormat.format(time);
                          }, onCancel: () {
                            _wakeTime2Controller.text =
                                devicesList[currentEditIndex]
                                    .wakeTime2
                                    .toString();
                          }, currentTime: wakeTime);
                        },
                        icon: const Icon(Icons.access_time)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _bedTime1Controller,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Bed Time (From)'.tr(),
                    suffixIcon: IconButton(
                        onPressed: () {
                          DateTime bedTime = DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day, 22, 0);
                          DatePicker.showTime12hPicker(context,
                              showTitleActions: true, onConfirm: (time) {
                            _bedTime1Controller.text = timeFormat.format(time);
                          }, onCancel: () {
                            _bedTime1Controller.text =
                                devicesList[currentEditIndex]
                                    .bedTime1
                                    .toString();
                          }, currentTime: bedTime);
                        },
                        icon: const Icon(Icons.access_time)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _bedTime2Controller,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Bed Time (To)'.tr(),
                    suffixIcon: IconButton(
                        onPressed: () {
                          DateTime bedTime = DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day, 22, 0);
                          DatePicker.showTime12hPicker(context,
                              showTitleActions: true, onConfirm: (time) {
                            _bedTime2Controller.text = timeFormat.format(time);
                          }, onCancel: () {
                            _bedTime2Controller.text =
                                devicesList[currentEditIndex]
                                    .bedTime2
                                    .toString();
                          }, currentTime: bedTime);
                        },
                        icon: const Icon(Icons.access_time)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    NiceButtons(
                      stretch: false,
                      width: 150,
                      startColor: Colors.blue,
                      endColor: Colors.blue,
                      borderColor: Colors.blue,
                      gradientOrientation: GradientOrientation.Horizontal,
                      onTap: (finish) {
                        submitEditDevice(
                            addressController.text,
                            _wakeTime1Controller.text,
                            _wakeTime2Controller.text,
                            _bedTime1Controller.text,
                            _bedTime2Controller.text);
                      },
                      child: Text(
                        'Submit'.tr(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 10),
                    NiceButtons(
                      stretch: false,
                      width: 150,
                      startColor: Colors.red,
                      endColor: Colors.red,
                      borderColor: Colors.red,
                      gradientOrientation: GradientOrientation.Horizontal,
                      onTap: (finish) {
                        setState(() {
                          editDeviceFlag = false;
                        });
                      },
                      child: Text(
                        'Cancel'.tr(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

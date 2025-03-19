import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:senzelifeflutterapp/src/screens/Home/DeviceHistory.dart';
import '../../Model/device.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  List<Device> devicesList = [];
  final int alertThresholdHours = 2;
  late var listenerDeviceUnderCare;
  late var listenerDevice;
  late var listenerDeviceHistory;

  @override
  void initState() {
    super.initState();
    getDevices();
    updateFCM();
  }

  @override
  void dispose() {
    listenerDeviceUnderCare.cancel();
    listenerDevice.cancel();
    listenerDeviceHistory.cancel();
    devicesList.clear();
    super.dispose();
  }

  Future<void> updateFCM() async {
    if (!kIsWeb) {
      var fcmToken = await FirebaseMessaging.instance.getToken();
      FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'LastLaunchAt': DateTime.now(), 'FcmToken': fcmToken});
    }
  }

  Future<void> getDevices() async {
    devicesList = [];
    listenerDeviceUnderCare = FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("DeviceUnderCare")
        .snapshots()
        .listen((deviceQuerySnapshot) {
      if (deviceQuerySnapshot.docs.isNotEmpty) {
        devicesList = [];
        for (var deviceDetail in deviceQuerySnapshot.docs) {
          listenerDeviceHistory = FirebaseFirestore.instance
              .collection("Devices")
              .doc(deviceDetail.data()['DeviceEui'])
              .collection("History")
              .where("Movement", isEqualTo: "Detected")
              .orderBy('CreatedAt', descending: true)
              .limit(1)
              .snapshots()
              .listen((historySnapshot) {
            if (historySnapshot.docs.isNotEmpty) {
              // Show Last Movement detected on
              for (var history in historySnapshot.docs) {
                devicesList.isNotEmpty
                    ? devicesList.removeWhere((item) =>
                        item.deviceEui == deviceDetail.data()['DeviceEui'])
                    : null;

                var date = history
                    .data()['CreatedAt']
                    .toDate()
                    .subtract(const Duration(minutes: 30))
                    .toString();
                var date2 = history.data()['CreatedAt'].toDate().toString();
                var time =
                    '${Moment.parse(date).format('DD MMM YYYY')} \n ${Moment.parse(date).format('h:mm a')} - ${Moment.parse(date2).format('h:mm a')}';

                listenerDevice = FirebaseFirestore.instance
                    .collection("Devices")
                    .doc(deviceDetail.data()['DeviceEui'])
                    .get()
                    .then((deviceQuerySnapshot) async {
                  devicesList.isNotEmpty
                      ? devicesList.removeWhere((item) =>
                          item.deviceEui == deviceDetail.data()['DeviceEui'])
                      : null;

                  devicesList.add(Device(
                      deviceEui: deviceDetail.data()['DeviceEui'],
                      address: deviceDetail.data()['Address'],
                      mainUser: deviceDetail.data()['MainUser'],
                      createdAt:
                          deviceDetail.data()['CreatedAt']!.toDate().toString(),
                      notification: deviceDetail.data()['Notification'],
                      wakeTime1: deviceQuerySnapshot.data()?['WakeTime1'],
                      wakeTime2: deviceQuerySnapshot.data()?['WakeTime2'],
                      bedTime1: deviceQuerySnapshot.data()?['BedTime1'],
                      bedTime2: deviceQuerySnapshot.data()?['BedTime2'],
                      status: deviceQuerySnapshot.data()?['Status'] ?? false,
                      lastStatus: deviceQuerySnapshot
                          .data()?['LastStatus']
                          ?.toDate()
                          .toString(),
                      lastRecordedAt: time,
                      noData: false));

                  setState(() {
                    devicesList.sort((b, a) =>
                        b.address.toString().compareTo(a.address.toString()));
                    isLoading = false;
                  });
                });
              }
            } else {
              // Show Last Updated On
              listenerDevice = FirebaseFirestore.instance
                  .collection("Devices")
                  .doc(deviceDetail.data()['DeviceEui'])
                  .collection("History")
                  .orderBy('CreatedAt', descending: true)
                  .limit(1)
                  .snapshots()
                  .listen((historySnapshot) {
                if (historySnapshot.docs.isNotEmpty) {
                  for (var history in historySnapshot.docs) {
                    devicesList.isNotEmpty
                        ? devicesList.removeWhere((item) =>
                            item.deviceEui == deviceDetail.data()['DeviceEui'])
                        : null;

                    var date = history
                        .data()['CreatedAt']
                        .toDate()
                        .subtract(const Duration(minutes: 30))
                        .toString();
                    var date2 = history.data()['CreatedAt'].toDate().toString();
                    var time =
                        '${Moment.parse(date).format('DD MMM YYYY')} \n ${Moment.parse(date).format('h:mm a')} - ${Moment.parse(date2).format('h:mm a')}';

                    FirebaseFirestore.instance
                        .collection("Devices")
                        .doc(deviceDetail.data()['DeviceEui'])
                        .get()
                        .then((deviceQuerySnapshot) async {
                      devicesList.isNotEmpty
                          ? devicesList.removeWhere((item) =>
                              item.deviceEui ==
                              deviceDetail.data()['DeviceEui'])
                          : null;

                      devicesList.add(Device(
                          deviceEui: deviceDetail.data()['DeviceEui'],
                          address: deviceDetail.data()['Address'],
                          mainUser: deviceDetail.data()['MainUser'],
                          createdAt: deviceDetail
                              .data()['CreatedAt']!
                              .toDate()
                              .toString(),
                          notification: deviceDetail.data()['Notification'],
                          wakeTime1: deviceQuerySnapshot.data()?['WakeTime1'],
                          wakeTime2: deviceQuerySnapshot.data()?['WakeTime2'],
                          bedTime1: deviceQuerySnapshot.data()?['BedTime1'],
                          bedTime2: deviceQuerySnapshot.data()?['BedTime2'],
                          status:
                              deviceQuerySnapshot.data()?['Status'] ?? false,
                          lastStatus: deviceQuerySnapshot
                              .data()?['LastStatus']
                              ?.toDate()
                              .toString(),
                          lastRecordedAt: time,
                          noData: true));

                      setState(() {
                        // devicesList;
                        devicesList.sort((b, a) => b.address
                            .toString()
                            .compareTo(a.address.toString()));
                        isLoading = false;
                      });
                    });
                  }
                }
              });
              setState(() {
                isLoading = false;
              });
            }
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hello,'),
          automaticallyImplyLeading: false,
          actions: const <Widget>[],
        ),
        body: Container(
          alignment: Alignment.center,
          child: isLoading
              ? LoadingAnimationWidget.horizontalRotatingDots(
                  color: Colors.blue,
                  size: 50,
                )
              : Column(
                  children: [
                    if (devicesList.isNotEmpty)
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: getDevices,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: devicesList.length,
                            itemBuilder: (context, index) {
                              return Visibility(
                                visible: devicesList[index].mainUser != null,
                                // && devicesList[index].mainUser == userUid
                                // ? true
                                // : false,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          border: Border.all(
                                            color: Colors.green,
                                            width: 2,
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Icon(
                                                    devicesList[index].status ==
                                                            null
                                                        ? null
                                                        : devicesList[index]
                                                                    .status ==
                                                                true
                                                            ? Icons
                                                                .power_outlined
                                                            : Icons
                                                                .power_off_outlined,
                                                    size: 35.0,
                                                    color: devicesList[index]
                                                                .status ==
                                                            null
                                                        ? null
                                                        : devicesList[index]
                                                                    .status ==
                                                                true
                                                            ? Colors.yellow
                                                            : Colors.deepOrange,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 4,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        devicesList[index]
                                                            .address!,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 28),
                                                      ),
                                                      Text(
                                                        devicesList[index]
                                                            .deviceEui!,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.7),
                                                            fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 4.0),
                                                    child: IconButton(
                                                      icon: const Icon(
                                                        Icons.history,
                                                        size: 40.0,
                                                        color: Colors.yellow,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context).push(MaterialPageRoute(
                                                            builder: (context) =>
                                                                DeviceHistoryPage(
                                                                    devicesList[
                                                                            index]
                                                                        .deviceEui
                                                                        .toString(),
                                                                    devicesList[
                                                                            index]
                                                                        .address
                                                                        .toString())));
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
                                            color: Colors.green,
                                            width: 2,
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 24.0, bottom: 24.0),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    devicesList[index].noData !=
                                                                null &&
                                                            devicesList[index]
                                                                    .noData ==
                                                                false
                                                        ? "Last Movement Detected On:"
                                                            .tr()
                                                        : "Last Updated On:"
                                                            .tr(),
                                                    style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 13),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                        4.0, 8.0, 4.0, 0.0),
                                                    child: Text(
                                                      devicesList[index]
                                                          .lastRecordedAt!,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                          color: Colors.blue,
                                                          fontSize: 19),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    if (devicesList.isEmpty)
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
                                const Icon(Icons.directions_run,
                                    size: 50, color: Colors.blue),
                                Text("No Devices Found".tr(),
                                    style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                      "Go to Settings > Devices List to add new device"
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
    );
  }
}

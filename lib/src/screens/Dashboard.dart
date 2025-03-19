import 'package:app_version_update/app_version_update.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:senzelifeflutterapp/firebase_options_senzepact.dart';
import 'package:senzelifeflutterapp/src/screens/CreateAccount.dart';
import 'package:senzelifeflutterapp/src/screens/ForgotPassword.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:senzelifeflutterapp/src/screens/BottomNavIcons.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class DropdownOption {
  final String label;
  final String value;

  DropdownOption(this.label, this.value);
}

class DashboardDevice {
  bool? status = false;
  String? userUid;
  String? lastStatus;
  String? deviceEui;
  String? name;
  String? phoneNumber;
  String? address;
  String? mainUser;
  String? movement;
  Color? movementColor;
  String? lastRecordedAt;
  String? fsCreatedAt;
  bool? alert = false;

  DashboardDevice(
      {this.status,
      this.userUid,
      this.lastStatus,
      this.deviceEui,
      this.name,
      this.phoneNumber,
      this.address,
      this.mainUser,
      this.movement,
      this.movementColor,
      this.lastRecordedAt,
      this.fsCreatedAt,
      this.alert});
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isLoading = true;
  List devicesList = [];
  final int alertThresholdHours = 2;

  @override
  void initState() {
    super.initState();
    getDevices();
    // fetchAssignToFromFirestore();
  }

  @override
  void dispose() {
    super.dispose();
    devicesList.clear();
  }

  Future<List<DropdownOption>> fetchAssignToFromFirestore() async {
    final FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'SecondaryApp',
      options: SecondaryFirebaseOptions.currentPlatform,
    );
    QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instanceFor(app: secondaryApp)
            .collection('Users')
            .where('Organisation', isEqualTo: 'testingSL')
            .get();

    List<DropdownOption> assignToList = [DropdownOption('None', 'None')];

    for (var doc in usersSnapshot.docs) {
      Map<String, dynamic>? userData = doc.data() as Map<String, dynamic>?;

      if (userData != null && userData['Name'] != null) {
        assignToList.add(DropdownOption(userData['Name'] as String, doc.id));
      }
    }
    return assignToList;
  }

  Future<String> fetchSelectedOptionFromFirestore(String userUid) async {
    QuerySnapshot volunteerSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .collection('Volunteer')
        .orderBy('CreatedAt', descending: true)
        .limit(1)
        .get();

    if (volunteerSnapshot.docs.isNotEmpty) {
      var volunteerData =
          volunteerSnapshot.docs.first.data() as Map<String, dynamic>;
      if (volunteerData['Volunteer'] != null) {
        return volunteerData['Volunteer'] as String;
      }
    }
    return 'None';
  }

  Future<void> getDevices() async {
    devicesList = [];
    await FirebaseFirestore.instance
        .collection("Users")
        .get()
        .then((userQuerySnapshot) {
      for (var userDoc in userQuerySnapshot.docs) {
        var userUid = userDoc.id;
        FirebaseFirestore.instance
            .collection("Users")
            .doc(userUid)
            .collection("DeviceUnderCare")
            .snapshots()
            .listen((deviceQuerySnapshot) {
          if (deviceQuerySnapshot.docs.isNotEmpty) {
            for (var deviceDetail in deviceQuerySnapshot.docs) {
              var deviceEui = deviceDetail.data()['DeviceEui'] ?? '';
              if (deviceEui.isEmpty) continue;

              FirebaseFirestore.instance
                  .collection("Devices")
                  .doc(deviceEui)
                  .collection("History")
                  .where("Movement", isEqualTo: "Detected")
                  .orderBy('CreatedAt', descending: true)
                  .limit(1)
                  .snapshots()
                  .listen((historySnapshot) {
                if (historySnapshot.docs.isNotEmpty) {
                  for (var history in historySnapshot.docs) {
                    var createdAt = history.data()['CreatedAt']?.toDate();
                    if (createdAt == null) continue;

                    devicesList
                        .removeWhere((item) => item.deviceEui == deviceEui);

                    var date = createdAt
                        .subtract(const Duration(minutes: 30))
                        .toString();
                    var date2 = createdAt.toString();
                    var time =
                        '${Moment.parse(date).format('DD MMM YYYY')} \n ${Moment.parse(date).format('h:mm a')} - ${Moment.parse(date2).format('h:mm a')}';
                    var lastTimestamp = Moment.parse(date);

                    FirebaseFirestore.instance
                        .collection("Devices")
                        .doc(deviceEui)
                        .get()
                        .then((deviceQuerySnapshot) {
                      var deviceData = deviceQuerySnapshot.data();
                      devicesList.add(DashboardDevice(
                          status: deviceData?['Status'] ?? '',
                          userUid: userUid,
                          lastStatus:
                              deviceData?['LastStatus']?.toDate()?.toString() ??
                                  '',
                          deviceEui: deviceEui ?? '',
                          name: userDoc.data()['Name'] ?? '',
                          phoneNumber: userDoc.data()['PhoneNumber'] ?? '',
                          address: deviceDetail.data()['Address'] ?? '',
                          mainUser: deviceDetail.data()['MainUser'] ?? '',
                          movement: history.data()['Movement'] ?? '',
                          movementColor: Colors.green,
                          lastRecordedAt: time,
                          fsCreatedAt: createdAt.toString(),
                          alert: history.data()['Movement'] != "Detected"
                              ? true
                              : Moment.now()
                                      .difference(lastTimestamp)
                                      .inHours >=
                                  alertThresholdHours));

                      setState(() {
                        devicesList.sort((b, a) => b.address
                            .toString()
                            .compareTo(a.address.toString()));
                        isLoading = false;
                      });
                    });
                  }
                } else {
                  FirebaseFirestore.instance
                      .collection("Devices")
                      .doc(deviceEui)
                      .collection("History")
                      .orderBy('CreatedAt', descending: true)
                      .limit(1)
                      .snapshots()
                      .listen((historySnapshot) {
                    if (historySnapshot.docs.isNotEmpty) {
                      for (var history in historySnapshot.docs) {
                        var createdAt = history.data()['CreatedAt']?.toDate();
                        if (createdAt == null) continue;

                        devicesList
                            .removeWhere((item) => item.deviceEui == deviceEui);

                        var date = createdAt
                            .subtract(const Duration(minutes: 30))
                            .toString();
                        var date2 = createdAt.toString();
                        var time =
                            '${Moment.parse(date).format('DD MMM YYYY')} \n ${Moment.parse(date).format('h:mm a')} - ${Moment.parse(date2).format('h:mm a')}';
                        var lastTimestamp = Moment.parse(date);

                        FirebaseFirestore.instance
                            .collection("Devices")
                            .doc(deviceEui)
                            .get()
                            .then((deviceQuerySnapshot) {
                          var deviceData = deviceQuerySnapshot.data();
                          devicesList.add(DashboardDevice(
                              status: deviceData?['Status'] ?? '',
                              lastStatus: deviceData?['LastStatus']
                                      ?.toDate()
                                      ?.toString() ??
                                  '',
                              deviceEui: deviceEui,
                              name: userDoc.data()['Name'],
                              phoneNumber: userDoc.data()['PhoneNumber'] ?? '',
                              address: deviceDetail.data()['Address'] ?? '',
                              mainUser: deviceDetail.data()['MainUser'] ?? '',
                              movement: history.data()['Movement'] ?? '',
                              movementColor: Colors.green,
                              lastRecordedAt: time,
                              fsCreatedAt: createdAt.toString(),
                              alert: history.data()['Movement'] != "Detected"
                                  ? true
                                  : Moment.now()
                                          .difference(lastTimestamp)
                                          .inHours >=
                                      alertThresholdHours));

                          setState(() {
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
    });
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
      appBar: AppBar(
        title: const Text('SenzeLife'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
          alignment: Alignment.center,
          child: isLoading
              ? LoadingAnimationWidget.horizontalRotatingDots(
                  color: Colors.blue,
                  size: 50,
                )
              : Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateColor.resolveWith(
                              (states) => Colors.grey[200]!,
                            ),
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'Name',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Device Eui',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Movement',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Last Recorded At',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Alert',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Actions',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows: devicesList.map((device) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(device.name ?? ''),
                                  ),
                                  DataCell(
                                    Text(device.deviceEui ?? ''),
                                  ),
                                  DataCell(Text(device.movement ?? '')),
                                  DataCell(Text(device.lastRecordedAt ?? '')),
                                  DataCell(Text(device.alert.toString())),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon:
                                              const Icon(Icons.remove_red_eye),
                                          color: Colors.blue,
                                          iconSize: 28.0,
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                  ),
                                                  title: const Text(
                                                    'Device Details',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4.0),
                                                        child: Row(
                                                          children: [
                                                            const Text(
                                                              'Name: ',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                  device.name ??
                                                                      'N/A'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4.0),
                                                        child: Row(
                                                          children: [
                                                            const Text(
                                                              'PhoneNumber: ',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Expanded(
                                                              child: Text(device
                                                                      .phoneNumber ??
                                                                  'N/A'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4.0),
                                                        child: Row(
                                                          children: [
                                                            const Text(
                                                              'Device Eui: ',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Expanded(
                                                              child: Text(device
                                                                      .deviceEui ??
                                                                  'N/A'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4.0),
                                                        child: Row(
                                                          children: [
                                                            const Text(
                                                              'Movement: ',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Expanded(
                                                              child: Text(device
                                                                      .movement ??
                                                                  'N/A'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4.0),
                                                        child: Row(
                                                          children: [
                                                            const Text(
                                                              'Last Recorded At: ',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Expanded(
                                                              child: Text(device
                                                                      .lastRecordedAt ??
                                                                  'N/A'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4.0),
                                                        child: Row(
                                                          children: [
                                                            const Text(
                                                              'Alert: ',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Expanded(
                                                              child: Text(device
                                                                      .alert
                                                                      .toString() ??
                                                                  'N/A'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text('Close',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red)),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          color: Colors.green,
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return EditDialog(
                                                  device: device,
                                                  onUpdate: (newName,
                                                      newPhoneNumber) async {
                                                    setState(() {
                                                      device.name = newName;
                                                      device.phoneNumber =
                                                          newPhoneNumber;
                                                    });
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('Users')
                                                        .doc(device.userUid)
                                                        .update({
                                                      'Name': newName,
                                                      'PhoneNumber':
                                                          newPhoneNumber,
                                                      'UpdatedAt':
                                                          DateTime.now(),
                                                    });
                                                    // getDevices();
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.handshake),
                                          color: Colors.amber,
                                          onPressed: () async {
                                            List<DropdownOption>
                                                dropdownOptions =
                                                await fetchAssignToFromFirestore();
                                            String selectedOption =
                                                await fetchSelectedOptionFromFirestore(
                                                    device.userUid);

                                            // String selectedOption =
                                            //     dropdownOptions[0].value;

                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return StatefulBuilder(
                                                  builder: (BuildContext
                                                          context,
                                                      StateSetter setState) {
                                                    return AlertDialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.0),
                                                      ),
                                                      title: const Text(
                                                        'Select Assign To',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          DropdownButton<
                                                              String>(
                                                            value:
                                                                selectedOption,
                                                            items: dropdownOptions
                                                                .map((DropdownOption
                                                                    option) {
                                                              return DropdownMenuItem<
                                                                  String>(
                                                                value: option
                                                                    .value,
                                                                child: Text(
                                                                    option
                                                                        .label),
                                                              );
                                                            }).toList(),
                                                            onChanged: (String?
                                                                newValue) {
                                                              setState(() {
                                                                selectedOption =
                                                                    newValue!;
                                                              });
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                              'Cancel',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red)),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Users')
                                                                .doc(device
                                                                    .userUid)
                                                                .collection(
                                                                    'Volunteer')
                                                                .add({
                                                              'Volunteer':
                                                                  selectedOption,
                                                              'CreatedAt':
                                                                  DateTime
                                                                      .now(),
                                                            });
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors.amber,
                                                          ),
                                                          child: const Text(
                                                              'Submit'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
    );
  }
}

class EditDialog extends StatefulWidget {
  final DashboardDevice device;
  final Function(String, String) onUpdate;

  EditDialog({required this.device, required this.onUpdate});

  @override
  _EditDialogState createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.device.name);
    _phoneController = TextEditingController(text: widget.device.phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onUpdate(_nameController.text, _phoneController.text);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: const Text('Update'),
        ),
      ],
    );
  }
}

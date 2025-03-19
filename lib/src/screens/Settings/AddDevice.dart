import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:senzelifeflutterapp/src/service/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({super.key});

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  var steps = 1;

  final deviceeIDController = TextEditingController();
  final wifiSSIDController = TextEditingController();
  final wifiPasswordController = TextEditingController();

  final nameController = TextEditingController();
  final _bedTime1Controller = TextEditingController();
  final _bedTime2Controller = TextEditingController();
  final _wakeTime1Controller = TextEditingController();
  final _wakeTime2Controller = TextEditingController();

  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
  DateFormat timeFormat = DateFormat("hh:mm a");

  late BluetoothDevice senzelifeDevice;
  bool doneProvision = false;
  bool showRetryButton = false;
  String provisionStatus = "Connecting to home safety kit...".tr();

  var subscription;

  @override
  void initState() {
    super.initState();

    deviceeIDController.text = "";
    wifiSSIDController.text = "";
    wifiPasswordController.text = "";
    nameController.text = "";
    _bedTime1Controller.text = "";
    _bedTime2Controller.text = "";
    _wakeTime1Controller.text = "";
    _wakeTime2Controller.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('Add Device'.tr()),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: const <Widget>[],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                steps == 1 ? step1() : emptyBox(),
                steps == 2 ? step2() : emptyBox(),
                steps == 3 ? step3() : emptyBox(),
                steps == 4 ? step4() : emptyBox(),
                steps == 5 ? step5() : emptyBox(),
                steps == 6 ? step6() : emptyBox(),
              ],
            ),
          )),
    );
  }

  SizedBox emptyBox() {
    return const SizedBox(
      height: 0,
    );
  }

  Column stepContent(Widget content) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
          child: Text("${"Step".tr()} $steps",
              style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
          child: StepProgressIndicator(
            totalSteps: 6,
            currentStep: steps,
            selectedColor: Colors.blue,
            unselectedColor: Colors.blue.shade100,
          ),
        ),
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: content,
            ),
          ),
        ),
      ],
    );
  }

  Column step1() {
    return stepContent(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                "Please input the Device ID found on the back of the device, or scan the QR code by clicking the QR icon below"
                    .tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
            child: TextField(
              controller: deviceeIDController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Device ID'.tr(),
                suffixIcon: GestureDetector(
                  onTap: _handleQRTap,
                  child: const Icon(
                    Icons.qr_code_scanner,
                    size: 24.0,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: NiceButtons(
              stretch: false,
              width: 150,
              startColor: Colors.blue,
              endColor: Colors.blue,
              borderColor: Colors.blue,
              gradientOrientation: GradientOrientation.Horizontal,
              onTap: (finish) {
                if (deviceeIDController.text == "") {
                  snackBar('Kindly fill up all the fields'.tr());
                } else {
                  setState(() {
                    steps = 2;
                  });
                }
              },
              child: Text(
                'Next'.tr(),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column step2() {
    return stepContent(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("${"Please enter the Wifi SSID".tr()}:",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
            child: TextField(
              controller: wifiSSIDController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Wifi SSID'.tr(),
              ),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: NiceButtons(
                  stretch: false,
                  width: 150,
                  startColor: Colors.blue,
                  endColor: Colors.blue,
                  borderColor: Colors.blue,
                  gradientOrientation: GradientOrientation.Horizontal,
                  onTap: (finish) {
                    setState(() {
                      steps = 1;
                    });
                  },
                  child: Text(
                    'Previous'.tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: NiceButtons(
                  stretch: false,
                  width: 150,
                  startColor: Colors.blue,
                  endColor: Colors.blue,
                  borderColor: Colors.blue,
                  gradientOrientation: GradientOrientation.Horizontal,
                  onTap: (finish) {
                    if (wifiSSIDController.text == "") {
                      snackBar('Kindly fill up all the fields'.tr());
                    } else {
                      setState(() {
                        steps = 3;
                      });
                    }
                  },
                  child: Text(
                    'Next'.tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Column step3() {
    return stepContent(Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("${"Please enter the Wifi Password".tr()}:",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
          child: TextField(
            controller: wifiPasswordController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Wifi Password'.tr(),
            ),
          ),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: NiceButtons(
                stretch: false,
                width: 150,
                startColor: Colors.blue,
                endColor: Colors.blue,
                borderColor: Colors.blue,
                gradientOrientation: GradientOrientation.Horizontal,
                onTap: (finish) {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                  setState(() {
                    steps = 2;
                  });
                },
                child: Text(
                  'Previous'.tr(),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: NiceButtons(
                stretch: false,
                width: 150,
                startColor: Colors.blue,
                endColor: Colors.blue,
                borderColor: Colors.blue,
                gradientOrientation: GradientOrientation.Horizontal,
                onTap: (finish) {
                  if (wifiPasswordController.text == "") {
                    snackBar('Kindly fill up all the fields'.tr());
                  } else {
                    setState(() {
                      steps = 4;
                    });
                  }
                },
                child: Text(
                  'Next'.tr(),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ],
    ));
  }

  Column step4() {
    return stepContent(Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("${"Make sure following information is correct".tr()}:",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 8.0),
          child: Text("${"Device ID".tr()}:",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 18)),
        ),
        Text(deviceeIDController.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold)),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 8.0),
          child: Text("${"Wifi SSID".tr()}:",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 18)),
        ),
        Text(wifiSSIDController.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold)),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 8.0),
          child: Text("${"Wifi Password".tr()}:",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 18)),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Text(wifiPasswordController.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: NiceButtons(
                stretch: false,
                width: 150,
                startColor: Colors.blue,
                endColor: Colors.blue,
                borderColor: Colors.blue,
                gradientOrientation: GradientOrientation.Horizontal,
                onTap: (finish) {
                  setState(() {
                    steps = 3;
                  });
                },
                child: Text(
                  'Previous'.tr(),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: NiceButtons(
                stretch: false,
                width: 150,
                startColor: Colors.blue,
                endColor: Colors.blue,
                borderColor: Colors.blue,
                gradientOrientation: GradientOrientation.Horizontal,
                onTap: (finish) {
                  if (wifiPasswordController.text == "") {
                    snackBar('Kindly fill up all the fields'.tr());
                  } else {
                    // Make sure information is correct
                    enableBLE();
                    setState(() {
                      steps = 5;
                    });
                  }
                },
                child: Text(
                  'Next'.tr(),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ],
    ));
  }

  Column step5() {
    return stepContent(Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
              "** ${"Please ensure the home safety kit is powered".tr()} **",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 8.0),
          child: Text("Status".tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 18,
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Text(provisionStatus,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
        showRetryButton
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: NiceButtons(
                  stretch: false,
                  width: 150,
                  startColor: Colors.blue,
                  endColor: Colors.blue,
                  borderColor: Colors.blue,
                  gradientOrientation: GradientOrientation.Horizontal,
                  onTap: (finish) {
                    enableBLE();
                    setState(() {
                      showRetryButton = false;
                    });
                  },
                  child: Text(
                    'Retry'.tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              )
            : emptyBox(),
        doneProvision
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: NiceButtons(
                  stretch: false,
                  width: 150,
                  startColor: Colors.blue,
                  endColor: Colors.blue,
                  borderColor: Colors.blue,
                  gradientOrientation: GradientOrientation.Horizontal,
                  onTap: (finish) {
                    setState(() {
                      steps = 6;
                    });
                  },
                  child: Text(
                    'Next'.tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              )
            : emptyBox(),
      ],
    ));
  }

  Column step6() {
    return stepContent(Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: nameController,
            decoration: InputDecoration(
                border: const OutlineInputBorder(), labelText: 'Location'.tr()),
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
                      _wakeTime1Controller.text = "";
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
                      _wakeTime2Controller.text = "";
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
                      _bedTime1Controller.text = "";
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
                      _bedTime2Controller.text = "";
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
                  submitAddDevice(
                      "SENZELIFE-${deviceeIDController.text}",
                      nameController.text,
                      _wakeTime1Controller.text,
                      _wakeTime2Controller.text,
                      _bedTime1Controller.text,
                      _bedTime2Controller.text);
                },
                child: Text(
                  'Submit'.tr(),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  void snackBar(String content) {
    final snackBar = SnackBar(
      /// need to set following properties for best effect of awesome_snackbar_content
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: '',
        message: content,

        /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
        contentType: ContentType.failure,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  Future<void> _handleQRTap() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera
          .onGrantedCallback(QRScanner() as FutureOr<void>? Function()?)
          .request();
    } else {
      QRScanner();
    }
  }

  Future<void> QRScanner() async {
    var result = await BarcodeScanner.scan();
    setState(() {
      deviceeIDController.text = result.rawContent;
    });
  }

  Future<void> enableBLE() async {
    if (await FlutterBluePlus.isSupported == false) {
      snackBar("Bluetooth not supported by this device".tr());
      return;
    }

    Future.delayed(const Duration(milliseconds: 15000), () {
      if (!doneProvision) {
        setState(() {
          provisionStatus = "Failed to connect, please retry...".tr();
          showRetryButton = true;
        });
      }
    });

    // cancel to prevent duplicate listeners
    if (subscription != null) {
      subscription.cancel();
    }

    // handle bluetooth on & off
    // note: for iOS the initial state is typically BluetoothAdapterState.unknown
    // note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
    subscription = FlutterBluePlus.adapterState
        .listen((BluetoothAdapterState state) async {
      if (state == BluetoothAdapterState.on) {
        // listen to scan results
        // Note: `onScanResults` only returns live scan results, i.e. during scanning. Use
        //  `scanResults` if you want live scan results *or* the results from a previous scan.
        var subscriptionScan = FlutterBluePlus.onScanResults.listen(
          (results) async {
            if (results.isNotEmpty) {
              ScanResult r = results.last;
              senzelifeDevice = r.device;
              // print(
              //     '${senzelifeDevice.remoteId}: "${r.advertisementData.advName}" found!');

              await senzelifeDevice.connect();

              if (Platform.isAndroid) {
                await senzelifeDevice.requestMtu(185); //iOS max is 185
              }

              setState(() {
                provisionStatus = "Connected to home safety kit...".tr();
                showRetryButton = false;
              });

              // listen for disconnection
              var subscriptionConnectionState = senzelifeDevice.connectionState
                  .listen((BluetoothConnectionState state) async {
                if (state == BluetoothConnectionState.disconnected) {
                  setState(() {
                    provisionStatus = "Provisioning done!!".tr();
                    showRetryButton = false;
                    doneProvision = true;
                  });
                  senzelifeDevice.disconnect();
                }
              });
              senzelifeDevice.cancelWhenDisconnected(
                  subscriptionConnectionState,
                  delayed: true,
                  next: true);

              List<BluetoothService> services =
                  await senzelifeDevice.discoverServices();
              for (var service in services) {
                var characteristics = service.characteristics;
                for (BluetoothCharacteristic c in characteristics) {
                  if (c.properties.write) {
                    setState(() {
                      provisionStatus = "Provisioning started...".tr();
                      showRetryButton = false;
                    });
                    String data =
                        "{\"ssid\":\"${wifiSSIDController.text}\",\"pwd\":\"${wifiPasswordController.text}\",\"user_doc_id\":\"${UserService().user!.uid}\"\}";
                    List<int> bytes = utf8.encode(data);
                    await c.write(bytes, allowLongWrite: true);
                  }
                }
              }
            }
          },
          onError: (e) => {snackBar(e.toString())},
        );

        // cleanup: cancel subscription when scanning stops
        FlutterBluePlus.cancelWhenScanComplete(subscriptionScan);

        // Wait for Bluetooth enabled & permission granted
        // In your real app you should use `FlutterBluePlus.adapterState.listen` to handle all states
        await FlutterBluePlus.adapterState
            .where((val) => val == BluetoothAdapterState.on)
            .first;

        // Start scanning w/ timeout
        // Optional: use `stopScan()` as an alternative to timeout
        await FlutterBluePlus.startScan(
            withNames: ["SENZELIFE-${deviceeIDController.text}"],
            timeout: const Duration(seconds: 60));

        // wait for scanning to stop
        await FlutterBluePlus.isScanning.where((val) => val == false).first;
      }
      // else {
      //   // show an error to the user, etc
      //   snackBar(state.toString());
      //   // print(state);
      // }
    });

    // turn on bluetooth ourself if we can
    // for iOS, the user controls bluetooth enable/disable
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
  }

  submitAddDevice(deviceID, name, waking1, waking2, bed1, bed2) async {
    if (deviceID != "" &&
        name != "" &&
        waking1 != "" &&
        waking2 != "" &&
        bed1 != "" &&
        bed2 != "") {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('DeviceUnderCare')
          .add({
        'CreatedAt': DateTime.now(),
        'Address': name,
        'DeviceEui': deviceID,
        'MainUser': FirebaseAuth.instance.currentUser!.uid,
        'Notification': 'sound',
        'Status': 'Unpaired'
      });

      FirebaseFirestore.instance
          .collection('Devices')
          .doc(deviceID)
          .collection('UserList')
          .add({
        'CreatedAt': DateTime.now(),
        'Name': UserService().getUser()?.name,
        'Role': 2,
        'UserUid': FirebaseAuth.instance.currentUser!.uid,
        'Notification': true,
        'FcmToken': await FirebaseMessaging.instance.getToken(),
      });

      FirebaseFirestore.instance.collection("Devices").doc(deviceID).set({
        'CreatedAt': DateTime.now(),
        'WakeTime1': waking1,
        'WakeTime2': waking2,
        'BedTime1': bed1,
        'BedTime2': bed2,
        'CreatedBy': FirebaseAuth.instance.currentUser!.uid,
        'Location': name,
        'Status': true
      });

      FirebaseFirestore.instance
          .collection("Users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("CaregiversList")
          .get()
          .then((querySnapshot) {
        for (var result in querySnapshot.docs) {
          // Check device has added to user
          FirebaseFirestore.instance
              .collection('Users')
              .doc(result.data()['Uid'])
              .collection('DeviceUnderCare')
              .where('DeviceEui', isEqualTo: deviceID)
              .get()
              .then((querySnapshotDevice) {
            if (querySnapshotDevice.docs.isEmpty) {
              FirebaseFirestore.instance
                  .collection('Users')
                  .doc(result.data()['Uid'])
                  .collection('DeviceUnderCare')
                  .add({
                'CreatedAt': DateTime.now(),
                'Address': name,
                'DeviceEui': deviceID,
                'MainUser': FirebaseAuth.instance.currentUser!.uid,
                'Notification': 'sound',
                'Status': 'Unpaired'
              });
            }
          });
        }
      }).then((value) => {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.success,
                  animType: AnimType.bottomSlide,
                  title: 'Device Added'.tr(),
                  desc: ''.tr(),
                  btnOkOnPress: () {
                    setState(() {
                      deviceeIDController.clear();
                      wifiSSIDController.clear();
                      wifiPasswordController.clear();
                      nameController.clear();
                      _wakeTime1Controller.clear();
                      _wakeTime1Controller.clear();
                      _bedTime1Controller.clear();
                      _bedTime2Controller.clear();
                    });
                    //Back to device list
                    Navigator.of(context).pop();
                  },
                ).show(),
              });
    } else {
      snackBar('Fill in required fields'.tr());
    }
  }
}

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:toggle_switch/toggle_switch.dart';

enum FrequencyOptions { Once, Recurring }

class AlertSettingsPage extends StatefulWidget {
  const AlertSettingsPage({super.key});

  @override
  State<AlertSettingsPage> createState() => _AlertSettingsPageState();
}

class _AlertSettingsPageState extends State<AlertSettingsPage> {
  bool alertNotification = false;
  bool isLoading = true;

  // bool ruleBasedNotification = false;
  // int thresholdCountTemp = 0;
  // int thresholdCount = 255;
  bool showEditRuleBased = false;
  bool showEditThreshold = false;
  bool isOnce = false;
  bool isRecurring = false;
  FrequencyOptions? _character = FrequencyOptions.Once;
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _remarkController = TextEditingController();

  // final _sleepTimeController = TextEditingController();
  // final _wakeTimeController = TextEditingController();
  late DateTime start;
  late DateTime end;
  late DateTime currentDateTime;

  // late String bedTime;
  // late String wakeTime;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
  DateFormat timeFormat = DateFormat("HH:mm");
  List rulesList = [];

  List<String> dropDownDevices = [];
  List<String> dropDownSelectedValue = [];

  @override
  void initState() {
    super.initState();
    getDetails();
    setState(() {
      _startController.text = "";
      _endController.text = "";
      _remarkController.text = "";
    });
    currentDateTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, DateTime.now().hour, 0);
  }


  Future<void> getDetails() async {
    rulesList = [];

    await FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((userQuerySnapshot) async {
      if (userQuerySnapshot.exists) {
        alertNotification =
            userQuerySnapshot.data()!.containsKey("AlertNotification")
                ? userQuerySnapshot.data()!['AlertNotification']
                : false;
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("DeviceUnderCare")
            .get()
            .then((deviceQuerySnapshot) async {
          for (var device in deviceQuerySnapshot.docs) {
            dropDownDevices.add("${"(" + device.data()['Address']}) " +
                device.data()['DeviceEui']);

            await FirebaseFirestore.instance
                .collection("Devices")
                .doc(device.data()['DeviceEui'])
                .collection("Rules")
                .get()
                .then((rulesQuerySnapshot) {
              if (rulesQuerySnapshot.size > 0) {
                for (var element in rulesQuerySnapshot.docs) {
                  rulesList.add({
                    'ID': element.id,
                    'Data': element.data(),
                    'Location': device.data()['Address'],
                    'DeviceEui': device.data()['DeviceEui']
                  });
                }
                setState(() {
                  rulesList;
                });
              }
            });
          }
        });

        // thresholdCount =
        //     deviceQuerySnapshot.data()!.containsKey("ThresholdCount")
        //         ? deviceQuerySnapshot.data()!['ThresholdCount']
        //         : 255;
        // bedTime = deviceQuerySnapshot.data()!.containsKey("BedTime")
        //     ? deviceQuerySnapshot.data()!['BedTime']
        //     : "";
        // wakeTime = deviceQuerySnapshot.data()!.containsKey("WakeTime")
        //     ? deviceQuerySnapshot.data()!['WakeTime']
        //     : "";
        // ruleBasedNotification =
        //     deviceQuerySnapshot.data()!.containsKey("RuleBasedNotification")
        //         ? deviceQuerySnapshot.data()!['RuleBasedNotification']
        //         : false;
        setState(() {
          alertNotification;
          // thresholdCount;
          // _sleepTimeController.text = bedTime;
          // _wakeTimeController.text = wakeTime;
          // ruleBasedNotification;
          isLoading = false;
        });
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
          centerTitle: true,
          title: Text('ALERTS'.tr()),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: const <Widget>[],
        ),
        body: isLoading
            ? Container(
                alignment: Alignment.topCenter,
                child: LoadingAnimationWidget.horizontalRotatingDots(
                  color: Colors.blue,
                  size: 50,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Notification(context),
                    alertNotification
                        ? RuleBasedNotification(context)
                        : EmptySizedBox(),
                    // alertNotification ? BedTime(context) : EmptySizedBox(),
                    // alertNotification ? WakeupTime(context) : EmptySizedBox(),
                    // alertNotification
                    //     ? ThresholdNotification(context)
                    //     : EmptySizedBox(),
                  ],
                ),
              ),
      ),
    );
  }

  // Padding BedTime(BuildContext context) {
  //   return Padding(
  //     padding:
  //         const EdgeInsets.only(left: 15.0, right: 15.0, top: 8, bottom: 8),
  //     child: Container(
  //       decoration: boxDecoration(Colors.blue),
  //       child: Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             Align(
  //               alignment: Alignment.centerLeft,
  //               child: Text("Bed Time".tr(),
  //                   style: const TextStyle(
  //                       color: Colors.blue, fontWeight: FontWeight.bold)),
  //             ),
  //             TextFormField(
  //               controller: _sleepTimeController,
  //               decoration: InputDecoration(
  //                   suffixIcon: IconButton(
  //                       onPressed: () {
  //                         DatePicker.showTimePicker(context,
  //                             showTitleActions: true,
  //                             showSecondsColumn: false, onConfirm: (time) {
  //                           _sleepTimeController.text = timeFormat.format(time);
  //                           FirebaseFirestore.instance
  //                               .collection("Users")
  //                               .doc(userUid)
  //                               .update({
  //                             'BedTime': timeFormat.format(time)
  //                           }).then((value) => {
  //                                     getDetials(),
  //                                     AwesomeDialog(
  //                                       context: context,
  //                                       dialogType: DialogType.success,
  //                                       animType: AnimType.bottomSlide,
  //                                       title: "Done".tr(),
  //                                       desc: "Updated Successfully".tr(),
  //                                       btnOkOnPress: () {},
  //                                       btnCancelOnPress: () {},
  //                                     ).show()
  //                                   });
  //                         }, currentTime: DateTime.now());
  //                       },
  //                       icon: const Icon(Icons.calendar_month,
  //                           color: Colors.blue))),
  //             )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Padding WakeupTime(BuildContext context) {
  //   return Padding(
  //     padding:
  //         const EdgeInsets.only(left: 15.0, right: 15.0, top: 8, bottom: 8),
  //     child: Container(
  //       decoration: boxDecoration(Colors.blue),
  //       child: Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             Align(
  //               alignment: Alignment.centerLeft,
  //               child: Text("Wake Time".tr(),
  //                   style: const TextStyle(
  //                       color: Colors.blue, fontWeight: FontWeight.bold)),
  //             ),
  //             TextFormField(
  //               controller: _wakeTimeController,
  //               decoration: InputDecoration(
  //                   suffixIcon: IconButton(
  //                       onPressed: () {
  //                         DatePicker.showTimePicker(context,
  //                             showTitleActions: true,
  //                             showSecondsColumn: false, onConfirm: (time) {
  //                           _wakeTimeController.text = timeFormat.format(time);
  //                           // print('confirm $date');
  //                           FirebaseFirestore.instance
  //                               .collection("Users")
  //                               .doc(userUid)
  //                               .update({
  //                             'WakeTime': timeFormat.format(time)
  //                           }).then((value) => {
  //                                     getDetials(),
  //                                     AwesomeDialog(
  //                                       context: context,
  //                                       dialogType: DialogType.success,
  //                                       animType: AnimType.bottomSlide,
  //                                       title: "Done".tr(),
  //                                       desc: "Updated Successfully".tr(),
  //                                       btnOkOnPress: () {},
  //                                       btnCancelOnPress: () {},
  //                                     ).show()
  //                                   });
  //                         }, currentTime: DateTime.now());
  //                       },
  //                       icon: const Icon(Icons.calendar_month,
  //                           color: Colors.blue))),
  //             )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  SizedBox EmptySizedBox() {
    return const SizedBox(
      height: 0,
    );
  }

  Padding Notification(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 15.0, right: 15.0, top: 8, bottom: 8),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Notification".tr(),
                        style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    ToggleSwitch(
                      // customWidths: [90.0, 50.0],
                      cornerRadius: 20.0,
                      activeBgColors: const [
                        [Colors.greenAccent],
                        [Colors.redAccent]
                      ],
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.grey,
                      inactiveFgColor: Colors.white,
                      totalSwitches: 2,
                      initialLabelIndex: alertNotification ? 0 : 1,
                      labels: ['ON'.tr(), 'OFF'.tr()],
                      // icons: [Icons.check, Icons.check],
                      onToggle: (index) {
                        if ((alertNotification && index == 1) ||
                            (!alertNotification && index == 0)) {
                          FirebaseFirestore.instance
                              .collection("Users")
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .update({
                            'AlertNotification': index == 0 ? true : false
                          }).then((value) => {
                                    getDetails(),
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.success,
                                      animType: AnimType.bottomSlide,
                                      title: "Done".tr(),
                                      desc: "Updated Successfully".tr(),
                                      btnOkOnPress: () {},
                                      btnCancelOnPress: () {},
                                    ).show()
                                  });
                        }
                      },
                    ),
                  ],
                ),
              ),
              Text("Turn on or off for receving all the notifications".tr(),
                  style: const TextStyle(color: Colors.blue, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Padding RuleBasedNotification(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 15.0, right: 15.0, top: 8, bottom: 8),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Rule-based Notification".tr(),
                        style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Text(
                  "To avoid notification on specific date or time if sensor is not detected any motion"
                      .tr(),
                  style: const TextStyle(color: Colors.blue, fontSize: 12)),
              !showEditRuleBased
                  ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextButton(
                          onPressed: () {
                            setState(() {
                              showEditRuleBased = true;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                width: 1.0, color: Colors.blue),
                          ),
                          child: Text(
                            'Add New Rule'.tr(),
                            style: const TextStyle(color: Colors.blue),
                          )),
                    )
                  : EmptySizedBox(),
              showEditRuleBased
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 12),
                      child: Container(
                        decoration: boxDecoration(Colors.grey),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              children: [
                                Text("Set New Rule".tr(),
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold)),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: DropdownSearch<String>.multiSelection(
                                    popupProps:
                                        const PopupPropsMultiSelection.menu(
                                      showSearchBox: true,
                                      showSelectedItems: true,
                                      // disabledItemFn: (String s) => s.startsWith('I'),
                                    ),
                                    items: dropDownDevices,
                                    dropdownDecoratorProps:
                                        DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        labelStyle: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold),
                                        labelText: dropDownSelectedValue == []
                                            ? "Select device(s): "
                                            : "Device(s): ",
                                        hintText: dropDownSelectedValue == []
                                            ? "Select device(s): "
                                            : "Device(s): ",
                                      ),
                                    ),
                                    onChanged: (List<String> users) => {
                                      setState(() {
                                        dropDownSelectedValue = users;
                                      }),
                                      // RetrieveDailyData(getUserID(user)),
                                    },
                                    selectedItems: [],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text("Start from:".tr(),
                                            style: const TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      TextFormField(
                                        controller: _startController,
                                        decoration: InputDecoration(
                                            suffixIcon: IconButton(
                                                onPressed: () {
                                                  DatePicker.showDateTimePicker(
                                                      context,
                                                      showTitleActions: true,
                                                      minTime:
                                                          DateTime(2024, 1, 1),
                                                      onConfirm: (date) {
                                                    setState(() {
                                                      start = date;
                                                    });
                                                    _startController.text =
                                                        dateFormat
                                                            .format(start);
                                                    // print('confirm $date');
                                                  },
                                                      currentTime:
                                                          currentDateTime);
                                                },
                                                icon: const Icon(
                                                    Icons.calendar_month,
                                                    color: Colors.blue))),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text("End by:".tr(),
                                            style: const TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      TextFormField(
                                        controller: _endController,
                                        decoration: InputDecoration(
                                            suffixIcon: IconButton(
                                                onPressed: () {
                                                  DatePicker.showDateTimePicker(
                                                      context,
                                                      showTitleActions: true,
                                                      minTime:
                                                          DateTime(2024, 1, 1),
                                                      onConfirm: (date) {
                                                    setState(() {
                                                      end = date;
                                                    });
                                                    _endController.text =
                                                        dateFormat.format(end);
                                                    // print('confirm $date');
                                                  },
                                                      currentTime:
                                                          currentDateTime);
                                                },
                                                icon: const Icon(
                                                    Icons.calendar_month,
                                                    color: Colors.blue))),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text("Remark:".tr(),
                                            style: const TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      TextFormField(
                                        controller: _remarkController,
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () {
                                        if (dropDownSelectedValue.isNotEmpty &&
                                            _startController.text != "" &&
                                            _endController.text != "" &&
                                            _remarkController.text != "") {
                                          for (var element
                                              in dropDownSelectedValue) {
                                            FirebaseFirestore.instance
                                                .collection("Devices")
                                                .doc(getDeviceID(element))
                                                .collection("Rules")
                                                .add({
                                              "CreatedAt": DateTime.now(),
                                              "Remark": _remarkController.text
                                                  .toString(),
                                              "Start": _startController.text
                                                  .toString(),
                                              "End":
                                                  _endController.text.toString()
                                            }).then((value) => {
                                                      getDetails(),
                                                      AwesomeDialog(
                                                        context: context,
                                                        dialogType:
                                                            DialogType.success,
                                                        animType: AnimType
                                                            .bottomSlide,
                                                        title: "Done".tr(),
                                                        desc:
                                                            "Updated Successfully"
                                                                .tr(),
                                                        btnOkOnPress: () {
                                                          setState(() {
                                                            showEditRuleBased =
                                                                false;
                                                            _startController
                                                                .text = "";
                                                            _endController
                                                                .text = "";
                                                            _remarkController
                                                                .text = "";
                                                          });
                                                        },
                                                        btnCancelOnPress: () {},
                                                      ).show()
                                                    });
                                          }
                                        } else {
                                          AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.error,
                                            animType: AnimType.bottomSlide,
                                            title: "Error".tr(),
                                            desc:
                                                "Kindly fill up all the fields"
                                                    .tr(),
                                            btnOkOnPress: () {},
                                            btnCancelOnPress: () {},
                                          ).show();
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            width: 1.0, color: Colors.green),
                                      ),
                                      child: Text('SUBMIT'.tr(),
                                          style: const TextStyle(
                                              color: Colors.green)),
                                    ),
                                    OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          showEditRuleBased = false;
                                          _startController.text = "";
                                          _endController.text = "";
                                          _remarkController.text = "";
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            width: 1.0, color: Colors.red),
                                      ),
                                      child: Text('Cancel'.tr(),
                                          style: const TextStyle(
                                              color: Colors.red)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : EmptySizedBox(),
              rulesList.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: rulesList.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.green,
                                      width: 1,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10))),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 4.0, bottom: 4.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "${'Device'.tr()}:",
                                                    style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 14),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Text(
                                                      rulesList[index]
                                                          ['Location'],
                                                      style: const TextStyle(
                                                          color: Colors.blue,
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "${'Device Eui'.tr()}:",
                                                    style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 14),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Text(
                                                      rulesList[index]
                                                          ['DeviceEui'],
                                                      style: const TextStyle(
                                                          color: Colors.blue,
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'Start from:'.tr(),
                                                    style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 14),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Text(
                                                      rulesList[index]['Data']
                                                          ['Start'],
                                                      style: const TextStyle(
                                                          color: Colors.blue,
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'End by:'.tr(),
                                                    style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 14),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Text(
                                                      rulesList[index]['Data']
                                                          ['End'],
                                                      style: const TextStyle(
                                                          color: Colors.blue,
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "${'Remark:'.tr()}:",
                                                    style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 14),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Text(
                                                      rulesList[index]['Data']
                                                          ['Remark'],
                                                      style: const TextStyle(
                                                          color: Colors.blue,
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.question,
                                            animType: AnimType.bottomSlide,
                                            title: "Delete".tr(),
                                            desc:
                                                "Are you sure to delete ".tr(),
                                            btnOkOnPress: () {
                                              FirebaseFirestore.instance
                                                  .collection("Devices")
                                                  .doc(rulesList[index]
                                                      ['DeviceEui'])
                                                  .collection("Rules")
                                                  .doc(rulesList[index]['ID'])
                                                  .delete()
                                                  .then((value) => {
                                                        getDetails(),
                                                        setState(() {
                                                          isLoading = true;
                                                        })
                                                      });
                                            },
                                            btnCancelOnPress: () {},
                                          ).show();
                                        },
                                        child: const Center(
                                            child: Icon(Icons.delete,
                                                color: Colors.red)),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : EmptySizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  // Padding ThresholdNotification(BuildContext context) {
  //   return Padding(
  //     padding:
  //         const EdgeInsets.only(left: 15.0, right: 15.0, top: 8, bottom: 8),
  //     child: Container(
  //       decoration: boxDecoration(Colors.blue),
  //       child: Padding(
  //         padding: const EdgeInsets.all(12.0),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Padding(
  //               padding: const EdgeInsets.only(bottom: 8.0),
  //               child: Text("Threshold".tr(),
  //                   style: const TextStyle(
  //                       color: Colors.blue,
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold)),
  //             ),
  //             Text(
  //                 "To be notified immediately if number of detections over the threshold. Click the number below to change:"
  //                     .tr(),
  //                 style: const TextStyle(color: Colors.blue, fontSize: 12)),
  //             showEditThreshold
  //                 ? EmptySizedBox()
  //                 : Padding(
  //                     padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
  //                     child: GestureDetector(
  //                       onTap: () {
  //                         setState(() {
  //                           showEditThreshold = !showEditThreshold;
  //                         });
  //                       }, // Image tapped
  //                       child: Center(
  //                         child: Text(thresholdCount.toString(),
  //                             style: const TextStyle(
  //                                 color: Colors.blue,
  //                                 fontSize: 25,
  //                                 fontWeight: FontWeight.bold)),
  //                       ),
  //                     ),
  //                   ),
  //             showEditThreshold
  //                 ? Padding(
  //                     padding: const EdgeInsets.only(top: 12.0, bottom: 12),
  //                     child: Container(
  //                       decoration: boxDecoration(Colors.grey),
  //                       child: Padding(
  //                         padding: const EdgeInsets.all(12.0),
  //                         child: SizedBox(
  //                           width: double.infinity,
  //                           child: Column(
  //                             children: [
  //                               Text("Set New Threshold".tr(),
  //                                   style: const TextStyle(
  //                                       color: Colors.grey,
  //                                       fontWeight: FontWeight.bold)),
  //                               TextFormField(
  //                                 textAlign: TextAlign.center,
  //                                 keyboardType: TextInputType.number,
  //                                 onChanged: (String? value) {
  //                                   thresholdCountTemp = int.parse(value!);
  //                                 },
  //                               ),
  //                               Row(
  //                                 mainAxisAlignment:
  //                                     MainAxisAlignment.spaceEvenly,
  //                                 children: [
  //                                   OutlinedButton(
  //                                     onPressed: () {
  //                                       FirebaseFirestore.instance
  //                                           .collection("Users")
  //                                           .doc(userUid)
  //                                           .update({
  //                                         'ThresholdCount': thresholdCountTemp
  //                                       }).then((value) => {
  //                                                 getDetials(),
  //                                                 AwesomeDialog(
  //                                                   context: context,
  //                                                   dialogType:
  //                                                       DialogType.success,
  //                                                   animType:
  //                                                       AnimType.bottomSlide,
  //                                                   title: "Done".tr(),
  //                                                   desc: "Updated Successfully"
  //                                                       .tr(),
  //                                                   btnOkOnPress: () {
  //                                                     setState(() {
  //                                                       showEditThreshold =
  //                                                           false;
  //                                                     });
  //                                                   },
  //                                                   btnCancelOnPress: () {},
  //                                                 ).show()
  //                                               });
  //                                     },
  //                                     style: OutlinedButton.styleFrom(
  //                                       side: const BorderSide(
  //                                           width: 1.0, color: Colors.green),
  //                                     ),
  //                                     child: Text('SUBMIT'.tr(),
  //                                         style: const TextStyle(
  //                                             color: Colors.green)),
  //                                   ),
  //                                   OutlinedButton(
  //                                     onPressed: () {
  //                                       setState(() {
  //                                         showEditThreshold = false;
  //                                       });
  //                                     },
  //                                     style: OutlinedButton.styleFrom(
  //                                       side: const BorderSide(
  //                                           width: 1.0, color: Colors.red),
  //                                     ),
  //                                     child: Text('Cancel'.tr(),
  //                                         style: const TextStyle(
  //                                             color: Colors.red)),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   )
  //                 : EmptySizedBox()
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  String? getDeviceID(String? device) {
    if (device != "") {
      var str = device;
      var id = str?.split(') ');
      return id?[1];
    }
    return "";
  }

  BoxDecoration boxDecoration(Color color) {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: color,
        width: 2,
      ),
      borderRadius: const BorderRadius.all(
        Radius.circular(10),
      ),
    );
  }
}

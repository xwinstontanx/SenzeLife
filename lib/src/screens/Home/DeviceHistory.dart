import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:moment_dart/moment_dart.dart';


class DeviceHistory {
  String? deviceEui;
  String? movement;
  String? slotValue;
  String? result;
  String? createdAt;

  DeviceHistory(
      {this.deviceEui,
      this.movement,
      this.slotValue,
      this.result,
      this.createdAt});
}

class DeviceHistoryPage extends StatefulWidget {
  final String deviceEui;
  final String address;

  const DeviceHistoryPage(this.deviceEui, this.address, {super.key});

  @override
  _DeviceHistoryPageState createState() => _DeviceHistoryPageState();
}

class _DeviceHistoryPageState extends State<DeviceHistoryPage> {
  var deviceEui = "";
  var address = "";
  bool isLoading = true;
  List<DeviceHistory> deviceHistoryList = [];

  @override
  void initState() {
    super.initState();
    getDeviceHistory();
  }

  Future<void> getDeviceHistory() async {
    deviceHistoryList = [];
    await FirebaseFirestore.instance
        .collection("Devices")
        .doc(widget.deviceEui)
        .collection("History")
        .where("Movement", isEqualTo: "Detected")
        .orderBy('CreatedAt', descending: true)
        .limit(450) //Load 3 days++ of data
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        for (var result in querySnapshot.docs) {
          var date = result.data()['CreatedAt'].toDate().subtract(const Duration(minutes: 30)).toString();
          var date2 = result.data()['CreatedAt'].toDate().toString();

          var time =
              '${Moment.parse(date).format('DD MMM YYYY')} ${Moment.parse(date).format('h:mm a')} - ${Moment.parse(date2).format('h:mm a')}';

          deviceHistoryList.add(DeviceHistory(
              deviceEui: result.data()['DeviceEui'],
              movement: result.data()['Movement'],
              slotValue: result.data()['Movement'] == "Detected"
                  ? result.data()['SlotValue'].toString()
                  : "",
              result: result.data()['Movement'] == "Detected"
                  ? result.data()['SlotValue'].toString() +
                      " movement was detected".tr()
                  : "No Movement was detected".tr(),
              createdAt: time));

          setState(() {
            deviceHistoryList;
          });
        }
        setState(() {
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
            leading: const BackButton(color: Colors.white),
            centerTitle: true,
            title: Text(widget.address + " History".tr()),
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
                : deviceHistoryList.isNotEmpty == true
                    ? ListView.builder(
                        itemCount: deviceHistoryList.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 6,
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              leading: deviceHistoryList[index].movement ==
                                      "Detected"
                                  ? const Icon(Icons.directions_run,
                                      size: 40.0, color: Colors.green)
                                  : const Icon(Icons.no_accounts,
                                      size: 40.0, color: Colors.red),
                              title: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        "${deviceHistoryList[index].result}",
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
                                        deviceHistoryList[index].createdAt!,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : const SizedBox(height: 0),
          )),
    );
  }
}

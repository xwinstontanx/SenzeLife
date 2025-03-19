import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  _DemoPageState createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  List demoHistoryList = [];
  bool showHistory = false;
  final f = DateFormat('yyyy-MM-dd hh:mm:ss');

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection("Demo")
        .doc("0080e1150540e2fb") //Device Leila Room
        .collection("History")
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .listen((querySnapshot) {
      demoHistoryList = [];
      print(querySnapshot.docs.length);
      if (querySnapshot.docs.isNotEmpty) {
        for (var record in querySnapshot.docs) {
          var temp = record.data();
          temp['CreatedAt'] = f.format(temp['CreatedAt'].toDate());
          demoHistoryList.add(temp);
          setState(() {
            demoHistoryList;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _launchURL() async {
    if (!await launchUrl(Uri.parse("https://www.senzelife.com/"))) {
      throw 'https://www.senzelife.com/';
    }
  }

  Future<void> _launchEmail() async {
    if (!await launchUrl(Uri.parse(
        "mailto:george@senzehub.com?subject=Enquiry For SenzeLife&body="))) {
      throw 'Could not launch george@senzehub.com';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SenzeLife'),
        automaticallyImplyLeading: false,
        actions: const <Widget>[],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(""),
            ListView(
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 750,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side:
                              const BorderSide(color: Colors.black26, width: 1),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: const EdgeInsets.all(15.0),
                        elevation: 7,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const Text(
                                  "This demo shows the number of counts where the SenzeLife device has been detected:",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                height: 120,
                                width: 250.0,
                                child: Center(
                                  child: DefaultTextStyle(
                                    style: const TextStyle(
                                      fontSize: 100.0,
                                    ),
                                    child: AnimatedTextKit(
                                      pause: const Duration(milliseconds: 250),
                                      repeatForever: true,
                                      animatedTexts: [
                                        ScaleAnimatedText(demoHistoryList
                                            .first['Count']
                                            .toString()),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Text("Counts"),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                                child: Text(
                                    "Last updated on: ${demoHistoryList.first['CreatedAt']}",
                                    style: const TextStyle(
                                        color: Colors.blueAccent,
                                        fontSize: 14)),
                              ),
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                                  child: Center(
                                    child: Text.rich(TextSpan(
                                        text: "For more details, please visit ",
                                        style: const TextStyle(
                                            fontSize: 13, color: Colors.grey),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text:
                                                  'https://www.senzelife.com/',
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.blue,
                                                  decoration:
                                                      TextDecoration.underline),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  _launchURL();
                                                }),
                                          TextSpan(
                                            text: " or contact ",
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey),
                                          ),
                                          TextSpan(
                                              text: "george@senzehub.com",
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.blue,
                                                  decoration:
                                                      TextDecoration.underline),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  _launchEmail();
                                                }),
                                          TextSpan(
                                            text: " to enquire.",
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey),
                                          ),
                                        ])),
                                  )),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: TextButton(
                                    onPressed: () {
                                      showHistory = !showHistory;
                                      setState(() {
                                        showHistory;
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 10, 0),
                                          child: Icon(
                                            Icons.history,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                        showHistory
                                            ? const Text("Hide History",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14))
                                            : const Text("Show History",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    showHistory
                        ? SizedBox(
                            width: 750,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Colors.black26, width: 1),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              margin: const EdgeInsets.all(15.0),
                              elevation: 7,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    const Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(0, 0, 0, 20.0),
                                      child: Text("History",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.blueAccent,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    SizedBox(
                                      height: 200.0,
                                      child: ListView.builder(
                                        itemCount: demoHistoryList.length,
                                        itemBuilder: (context, index) {
                                          return Card(
                                            elevation: 6,
                                            margin: const EdgeInsets.all(10),
                                            child: ListTile(
                                              // leading: demoHistoryList[index].movement == "Detected"
                                              //     ? const Icon(Icons.directions_run,
                                              //     size: 40.0, color: Colors.green)
                                              //     : const Icon(Icons.no_accounts,
                                              //     size: 40.0, color: Colors.red),
                                              title: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        demoHistoryList[index]
                                                                    ['Count']!
                                                                .toString() +
                                                            " counts",
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
                                                        demoHistoryList[index]
                                                            ['CreatedAt'],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(
                            height: 0,
                          ),
                    SizedBox(
                      width: 750,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side:
                              const BorderSide(color: Colors.black26, width: 1),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: const EdgeInsets.all(15.0),
                        elevation: 7,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 20.0),
                                child: Text("Current Problem",
                                    style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(
                                width: 700,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        color: Colors.black26, width: 1),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Image.asset('assets/images/news.png',
                                      fit: BoxFit.scaleDown),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 750,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side:
                              const BorderSide(color: Colors.black26, width: 1),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: const EdgeInsets.all(15.0),
                        elevation: 7,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                                child: Text("Benefits of Our Solution",
                                    style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.check,
                                    color: Colors.greenAccent,
                                  ),
                                  Flexible(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Simple",
                                          style: TextStyle(
                                              color: Colors.blueAccent,
                                              fontSize: 17)),
                                      Text(
                                          "Do not need to get to the device (Press emergency button) or wear",
                                          style: TextStyle(
                                              color: Colors.blueAccent,
                                              fontSize: 10)),
                                    ],
                                  ))
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.check,
                                    color: Colors.greenAccent,
                                  ),
                                  Flexible(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Large Coverage",
                                          style: TextStyle(
                                              color: Colors.blueAccent,
                                              fontSize: 17)),
                                      Text(
                                          "No camera is required, can be installed in anywhere (toilet / bathroom)",
                                          style: TextStyle(
                                              color: Colors.blueAccent,
                                              fontSize: 10)),
                                    ],
                                  ))
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.check,
                                    color: Colors.greenAccent,
                                  ),
                                  Flexible(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Preserve Privacy",
                                          style: TextStyle(
                                              color: Colors.blueAccent,
                                              fontSize: 17)),
                                      Text(
                                          "Activity of the senior will not be tracked",
                                          style: TextStyle(
                                              color: Colors.blueAccent,
                                              fontSize: 10)),
                                    ],
                                  ))
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.check,
                                    color: Colors.greenAccent,
                                  ),
                                  Flexible(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("High Accuracy",
                                          style: TextStyle(
                                              color: Colors.blueAccent,
                                              fontSize: 17)),
                                      Text(
                                          "Highly customization to prevent false alert",
                                          style: TextStyle(
                                              color: Colors.blueAccent,
                                              fontSize: 10)),
                                    ],
                                  ))
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

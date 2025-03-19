import 'dart:async';
import 'package:app_version_update/app_version_update.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_plus/persistent_bottom_nav_bar_plus.dart';

// import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:senzelifeflutterapp/src/screens/Settings/Settings.dart';
import 'package:senzelifeflutterapp/src/screens/Home/Home.dart';
import '../service/user_service.dart';
import 'Responsive/FormFactor.dart';
import 'package:url_launcher/url_launcher.dart';

class BottomNavIcons extends StatefulWidget {
  const BottomNavIcons({Key? key}) : super(key: key);

  @override
  State<BottomNavIcons> createState() => _BottomNavIconsState();
}

class _BottomNavIconsState extends State<BottomNavIcons> {
  late PersistentTabController _controller;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    checkInternetConnectivity();
    _verifyVersion();
    setUser();
    _controller = PersistentTabController();
  }

  Future<void> setUser() async {
    await UserService().setUser(FirebaseAuth.instance.currentUser!.uid);
  }

  List<Widget> _buildScreens() => [
        const HomePage(),
        const SettingsPage(),
      ];

  List<PersistentBottomNavBarItem> _navBarsItems() => [
        PersistentBottomNavBarItem(
            icon: const Icon(Icons.home),
            title: "HOME".tr(),
            activeColorPrimary: Colors.blue,
            inactiveColorPrimary: Colors.grey),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.settings),
          title: "SETTINGS".tr(),
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
        ),
      ];

  Future<void> launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.shortestSide;

    return Scaffold(
      body: deviceWidth > FormFactor.desktop
          ? Row(
              children: [
                NavigationRail(
                    selectedIndex: _selectedIndex,
                    destinations: _buildDestinations(),
                    onDestinationSelected: (int index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    labelType: NavigationRailLabelType.all),
                if (_selectedIndex == 0)
                  const Expanded(
                    child: Center(child: HomePage()),
                  ),
                if (_selectedIndex == 1)
                  const Expanded(
                    child: Center(child: SettingsPage()),
                  ),
              ],
            )
          : Center(
              child: PersistentTabView(
                context,
                controller: _controller,
                screens: _buildScreens(),
                items: _navBarsItems(),
                resizeToAvoidBottomInset: true,
                navBarHeight: MediaQuery.of(context).viewInsets.bottom > 0
                    ? 0.0
                    : kBottomNavigationBarHeight,
                bottomScreenMargin: 0,
                backgroundColor: Colors.white,
                // hideNavigationBar: false,
                // popAllScreensOnTapAnyTabs:true,
                decoration:
                    const NavBarDecoration(colorBehindNavBar: Colors.blue),
                // itemAnimationProperties: const ItemAnimationProperties(
                //   duration: Duration(milliseconds: 200),
                //   curve: Curves.ease,
                // ),
                // screenTransitionAnimation: const ScreenTransitionAnimation(
                //   animateTabTransition: true,
                // ),
                navBarStyle: NavBarStyle
                    .style6, // Choose the nav bar style with this property
              ),
            ),
    );
  }

  List<NavigationRailDestination> _buildDestinations() {
    return [
      NavigationRailDestination(
        icon: const Icon(Icons.home),
        label: Text("HOME".tr()),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.settings),
        label: Text("SETTINGS".tr()),
      ),
    ];
  }

  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.ethernet) {
      return true;
    } else {
      dialog(DialogType.error, 'Error'.tr(), 'No internet is available'.tr());
      return false;
    }
  }

  void _verifyVersion() async {
    await AppVersionUpdate.checkForUpdates(
        appleId: '6448743999',
        playStoreId: 'com.senzehub.senzelife',
        country: 'sg')
        .then((data) async {
      if (data.canUpdate!) {
        await AppVersionUpdate.showAlertUpdate(
          appVersionResult: data,
          context: context,
          backgroundColor: Colors.grey[200],
          title: 'New Version Available'.tr(),
          content: 'Do you want to proceed for update?'.tr(),
          updateButtonText: 'Yes'.tr(),
          cancelButtonText: 'No'.tr(),
          titleTextStyle: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w500, fontSize: 20.0),
          contentTextStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w300,
          ),
        );
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
}

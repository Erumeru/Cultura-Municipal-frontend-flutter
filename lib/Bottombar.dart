// ignore_for_file: avoid_print, deprecated_member_use, unnecessary_null_comparison, unnecessary_brace_in_string_interps, unused_element, file_names

import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:goevent2/booking/TicketStatus.dart';
import 'package:goevent2/home/home.dart';
import 'package:goevent2/profile/profile.dart';
import 'package:goevent2/utils/Images.dart';
import 'package:goevent2/utils/color.dart';
import 'package:goevent2/utils/colornotifire.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Search/SearchPage.dart';
import 'home/bookmark.dart';

class Bottombar extends StatefulWidget {
  const Bottombar({Key? key}) : super(key: key);

  @override
  _BottombarState createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {
  late ColorNotifire notifire;

  late int _lastTimeBackButtonWasTapped;
  static const exitTimeInMillis = 2000;
  int _selectedIndex = 0;
  var isLogin = false;

  final _pageOption = [
    const Home(),
    const SearchPage(),
    const Bookmark(),
    const TicketStatusPage(),
    const Profile(""),
  ];

  @override
  void initState() {
    super.initState();
    getdarkmodepreviousstate();
    // isLogin = getdata.read("firstLogin") ?? false;
    setState(() {});
  }

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }

  Future<bool> _handleWillPop() async {
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (_lastTimeBackButtonWasTapped != null &&
        (currentTime - _lastTimeBackButtonWasTapped) < exitTimeInMillis) {
      return true;
    } else {
      _lastTimeBackButtonWasTapped = DateTime.now().millisecondsSinceEpoch;
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              unselectedItemColor: notifire.bottommenucolore,
              backgroundColor: notifire.backgrounde,
              selectedLabelStyle: const TextStyle(
                  fontFamily: 'Gilroy_Medium', fontWeight: FontWeight.w500,),
              fixedColor: buttonColor,
              unselectedFontSize: 13,
              selectedFontSize: 13,
              unselectedLabelStyle: const TextStyle(fontFamily: 'Gilroy_Medium'),
              currentIndex: _selectedIndex,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: [
                BottomNavigationBarItem(
                    icon: Image.asset(Images.home,
                        color: _selectedIndex == 0 ? buttonColor : notifire.bottommenucolore,
                        height: MediaQuery.of(context).size.height / 35),
                    label: 'Explore'.tr),
                BottomNavigationBarItem(
                    icon: Image.asset(Images.search, color: _selectedIndex == 1 ? buttonColor : notifire.bottommenucolore, height: MediaQuery.of(context).size.height / 33),
                    label: 'Map'.tr),
                BottomNavigationBarItem(
                  icon: Image.asset(Images.rectangle,
                      color: _selectedIndex == 2
                          ? buttonColor
                          : notifire.bottommenucolore,
                      height: MediaQuery.of(context).size.height / 35),
                  label: 'Favorite'.tr,
                ),
                BottomNavigationBarItem(
                    icon: Image.asset(Images.calendar,
                        color: _selectedIndex == 3
                            ? buttonColor
                            : notifire.bottommenucolore,
                        height: MediaQuery.of(context).size.height / 35),
                    label: 'Events'.tr),
                BottomNavigationBarItem(
                  icon: Image.asset(Images.user,
                      color: _selectedIndex == 4
                          ? buttonColor
                          : notifire.bottommenucolore,
                      height: MediaQuery.of(context).size.height / 35),
                  label: 'Profile'.tr,
                ),
              ],
              onTap: (index) {
                setState(() {});
                _selectedIndex = index;
              }),
          body: _pageOption[_selectedIndex]),
    );
  }
}

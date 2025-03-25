// ignore_for_file: avoid_print, prefer_const_constructors

import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goevent2/Api/ApiWrapper.dart';
import 'package:goevent2/AppModel/Homedata/HomedataController.dart';
import 'package:goevent2/Controller/AuthController.dart';
import 'package:goevent2/Controller/UserPreferences.dart';
import 'package:goevent2/home/bookmark.dart';
import 'package:goevent2/profile/ReferFriend.dart';
import 'package:goevent2/profile/Wallet/WalletHistory.dart';
import 'package:goevent2/profile/faq.dart';
import 'package:goevent2/home/home.dart';
import 'package:goevent2/login_signup/Login.dart';
import 'package:goevent2/notification/notification.dart';
import 'package:goevent2/profile/editprofile.dart';
import 'package:goevent2/profile/loream.dart';
import 'package:goevent2/utils/AppWidget.dart';
import 'package:goevent2/utils/color.dart';
import 'package:goevent2/utils/colornotifire.dart';
import 'package:goevent2/utils/media.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Api/Config.dart';
import '../booking/TicketStatus.dart';

class Profile extends StatefulWidget {
  final String title;
  const Profile(this.title, {Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final x = Get.put(AuthController());

  bool isLodding = false;

  late ColorNotifire notifire;
  String? text;
  List<DynamicPageData> dynamicPageDataList = [];
  final List locale = [
    {'name': 'ENGLISH', 'locale': const Locale('en', 'US')},
    {'name': 'عربى', 'locale': const Locale('ar', 'IN')},
    {'name': 'हिंदी', 'locale': const Locale('hi', 'IN')},
    {'name': 'Spanish', 'locale': const Locale('es', 'ES')},
    {'name': 'France', 'locale': const Locale('de', 'ES')},
    {'name': 'Germany', 'locale': const Locale('UN', 'ES')},
    {'name': 'Indonesia', 'locale': const Locale('fr', 'ES')},
    // **********************************************************
    {'name': 'South Africa', 'locale': const Locale('ZA', 'ES')},
    {'name': 'Turkish', 'locale': const Locale('tr', 'ES')},
    {'name': 'Portuguese', 'locale': const Locale('pt', 'ES')},
    {'name': 'Dutch', 'locale': const Locale('nl', 'ES')},
    {'name': 'Vietnamese', 'locale': const Locale('vi', 'ES')},
  ];

  updateLanguage(Locale locale) {
    Get.back();
    Get.updateLocale(locale);
  }

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    notifire.setIsDark = previusstate;
  }

  @override
  void initState() {
    super.initState();
    getdarkmodepreviousstate();
    getWebData();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.backgrounde,
      body: Column(
        children: [
          SizedBox(height: height / 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Settings".tr,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Gilroy Medium',
                    color: notifire.textcolor),
              ),
            ],
          ),
          SizedBox(height: Get.height * 0.02),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Account Settings".tr,
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Gilroy Bold',
                            color: Colors.grey)),
                    SizedBox(height: Get.height * 0.02),
                    settingWidget(
                      tital: "Profile".tr,
                      image: "image/Profile.png",
                      onTap: () {
                        Get.to(() => const Edit());
                      },
                    ),
                    SizedBox(height: Get.height * 0.02),
                    settingWidget(
                      tital: "Events".tr,
                      image: "image/Calendar.png",
                      onTap: () {
                        Get.to(() => const TicketStatusPage(type: "0"));
                      },
                    ),
                    SizedBox(height: Get.height * 0.02),
                    settingWidget(
                      tital: "Wallet".tr,
                      image: "image/wallet.png",
                      onTap: () {
                        Get.to(() => const WalletReportPage());
                      },
                    ),
                    // SizedBox(height: Get.height * 0.02),
                    // settingWidget(
                    //   tital: "Chat".tr,
                    //   image: "image/chat123.png",
                    //   onTap: () {
                    //     Get.to(() => const ChatList());
                    //   },
                    // ),
                    SizedBox(height: Get.height * 0.02),
                    settingWidget(
                      tital: "Favorite".tr,
                      image: "image/Heart.png",
                      onTap: () {
                        Get.to(() => const Bookmark(type: "0"));
                      },
                    ),
                    SizedBox(height: Get.height * 0.02),
                    settingWidget(
                      tital: "Notification".tr,
                      image: "image/Notification2.png",
                      onTap: () {
                        Get.to(() => const Note());
                      },
                    ),
                    SizedBox(height: Get.height * 0.02),
                    settingWidget(
                      tital: "Refer a Friend".tr,
                      image: "image/Discount-1.png",
                      onTap: () {
                        Get.to(() => const ReferFriendPage());
                      },
                    ),
                    SizedBox(height: Get.height * 0.02),
                    settingWidget(
                      tital: "Dark Mode".tr,
                      image: "image/Show.png",
                      darkmode: Transform.scale(
                        scale: 0.7,
                        child: CupertinoSwitch(
                          activeColor: notifire.getbuttonscolor,
                          value: notifire.getIsDark,
                          onChanged: (val) async {
                            final prefs = await SharedPreferences.getInstance();
                            setState(() {
                              notifire.setIsDark = val;
                              prefs.setBool("setIsDark", val);
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: Get.height * 0.02),
                    ListView.builder(
                      itemCount: dynamicPageDataList.length,
                      shrinkWrap: true,
                      itemExtent: 60,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return InkWell(
                          child: Column(
                            children: [
                              settingWidget(
                                tital: dynamicPageDataList[index].title,
                                image: "image/Paper.png",
                                onTap: () {
                                  Get.to(() =>
                                      Loream(dynamicPageDataList[index].title));
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    settingWidget(
                      tital: "FAQ".tr,
                      image: "image/faq.png",
                      onTap: () {
                        Get.to(() => const Faq());
                      },
                    ),
                    SizedBox(height: Get.height * 0.02),
                    settingWidget(
                        tital: "Language".tr,
                        image: "image/langauge.png",
                        onTap: bottomsheet),
                    SizedBox(height: Get.height * 0.02),
                    settingWidget(
                      tital: "Delete Account".tr,
                      image: "image/Delete.png",
                      onTap: () {
                        dialogShow(
                            title:
                                "Are you sure ?\n You want to delete the account"
                                    .tr);
                      },
                    ),
                    SizedBox(height: Get.height * 0.02),
                    settingWidget(
                      tital: "Logout".tr,
                      image: "image/Logout.png",
                      onTap: () {
                        signoutSheetMenu();
                      },
                    ),
                    SizedBox(height: Get.height * 0.02),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  dialogShow({required String title}) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
              content: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              actions: <Widget>[
                TextButton(
                    onPressed: accountDelete,
                    child: Text("Delete".tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, letterSpacing: 0.5))),
                TextButton(
                  child: Text("No".tr,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, letterSpacing: 0.5)),
                  onPressed: () {
                    Get.back();
                  },
                )
              ]);
        });
  }

  settingWidget({Function()? onTap, String? tital, image, Widget? darkmode}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        height: Get.height * 0.06,
        decoration: BoxDecoration(
            color: notifire.containercolore,
            border: Border.all(color: notifire.bordercolore, width: 0.5),
            borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      radius: 20,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image(
                            image: AssetImage(image!),
                            color: notifire.getdarkscolor),
                      )),
                  SizedBox(width: Get.width * 0.02),
                  Text(
                    tital!,
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Gilroy Medium',
                        color: notifire.textcolor),
                  ),
                ],
              ),
              darkmode ??
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 20,
                    color: Colors.grey.withOpacity(0.4),
                  )
            ],
          ),
        ),
      ),
    );
  }

  void signoutSheetMenu() {
    showModalBottomSheet(
        backgroundColor: notifire.containercolore,
        isDismissible: false,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        context: context,
        builder: (builder) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: Get.height * 0.02),
              Container(
                  height: 6,
                  width: 80,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(25))),
              SizedBox(height: Get.height * 0.02),
              Text(
                "Logout".tr,
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Gilroy Bold',
                    color: const Color(0xffF0635A)),
              ),
              SizedBox(height: Get.height * 0.02),
              Text(
                "Are you sure you want to log out?".tr,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Gilroy Medium',
                    color: notifire.gettextcolor),
              ),
              SizedBox(height: Get.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: Get.width * 0.35,
                    height: Get.height * 0.06,
                    child: MaterialButton(
                      color: const Color(0xFFE9E7FC),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      onPressed: () {
                        Get.back();
                      },
                      child: Text("Cancel".tr,
                          style: TextStyle(color: buttonColor, fontSize: 16)),
                    ),
                  ),
                  SizedBox(
                    width: Get.width * 0.35,
                    height: Get.height * 0.06,
                    child: MaterialButton(
                      color: buttonColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      onPressed: () async {
                        await UserPreferences.removeToken();
                        await UserPreferences.removeUserId();
                        await UserPreferences.removeExpToken();
                        Get.offAll(() => const Login());
                      },
                      child: Text(
                        "Yes Logout".tr,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: Get.height * 0.04),
            ],
          );
        });
  }

  //! Account Delete User
  accountDelete() {
    var data = {"uid": uID};
    ApiWrapper.dataPost(Config.deleteAc, data).then((accDelete) {
      log(accDelete.toString(), name: "Delete Data Api user :: ");
      if ((accDelete != null) && (accDelete.isNotEmpty)) {
        if ((accDelete['ResponseCode'] == "200") &&
            (accDelete['Result'] == "true")) {
          log(accDelete.toString(), name: "Account Delete :: ");
          getData.remove("UserData");
          Get.offAll(() => const Login());
          ApiWrapper.showToastMessage(accDelete["ResponseMsg"]);
        }
      }
    });
  }

  bottomsheet() {
    return showModalBottomSheet(
        backgroundColor: notifire.containercolore,
        isScrollControlled: true,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                height: Get.height * 0.7,
                child: ListView.separated(
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            updateLanguage(locale[index]['locale']);
                            print(locale[index]['name']);
                          });
                        },
                        child: Row(children: [
                          Image.asset(FlagList[index]["img"], height: 25),
                          SizedBox(width: Get.width * 0.03),
                          InkWell(
                              onTap: () {
                                print(locale[index]['name']);
                                updateLanguage(locale[index]['locale']);
                              },
                              child: Text(
                                locale[index]['name'],
                                style: TextStyle(color: notifire.textcolor),
                              )),
                        ]),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(
                        color: Colors.grey,
                      );
                    },
                    itemCount: locale.length));
          });
        });
  }

  void getWebData() {
    Map<String, dynamic> data = {};

    dynamicPageDataList.clear();
    ApiWrapper.dataPost(Config.pagelist, data).then((value) {
      if ((value != null) &&
          (value.isNotEmpty) &&
          (value['ResponseCode'] == "200")) {
        List da = value['pagelist'];
        for (int i = 0; i < da.length; i++) {
          Map<String, dynamic> mapData = da[i];
          DynamicPageData a = DynamicPageData.fromJson(mapData);
          dynamicPageDataList.add(a);
        }

        for (int i = 0; i < dynamicPageDataList.length; i++) {
          if ((widget.title == dynamicPageDataList[i].title)) {
            text = dynamicPageDataList[i].description;
            setState(() {});
            return;
          } else {
            text = "";
          }
        }
        print(
            "jwgqdskdjchsjdilcuhsilcjsailkfhcjilsjfcsilkjfchidshfcid${dynamicPageDataList.length}");
        setState(() {
          isLodding = true;
        });
      }
    });
  }
}

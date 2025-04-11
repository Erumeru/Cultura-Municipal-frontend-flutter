// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goevent2/Api/ApiWrapper.dart';
import 'package:goevent2/Api/Config.dart';
import 'package:goevent2/AppModel/Homedata/HomedataController.dart';
import 'package:goevent2/Controller/UserModel.dart';
import 'package:goevent2/Controller/UserPreferences.dart';
import 'package:goevent2/promotions/PromotionModel.dart';
import 'package:goevent2/promotions/PromotionsController.dart';

import 'package:goevent2/utils/AppWidget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../utils/colornotifire.dart';
import '../utils/media.dart';

class Promotions extends StatefulWidget {
  const Promotions({Key? key}) : super(key: key);

  @override
  _NoteState createState() => _NoteState();
}

class _NoteState extends State<Promotions> {
  late ColorNotifire notifire;
  List notificationList = [];
  bool isLoading = false;
  final promotionsControl = PromotionsController();
  UserModel? userData;
  List<PromotionModel>? promotionList;

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    notifire.setIsDark = previusstate;
  }

  @override
  void initState() {
    super.initState();
    getdarkmodepreviousstate();
    loadPromotions(); // Esta función se encarga de todo
  }

  Future<void> loadPromotions() async {
    await getUserData(); // Espera a que se obtenga el usuario

    promotionList = await promotionsControl.getFilteredPromotions(
      age: userData!.edad,
      gender: userData!.genero,
      idMunicipio: userData!.idMunicipio,
    );

    promotionList?.forEach((promo) {
      print('promocion ${promo.mensaje}');
    });

    // if (userData != null) {

    //   print(promotionList);
    //   print(promotionList);

    //   promotionListApi(); // Si este también depende del userData
    // } else {
    //   print('userData is null');
    // }

    setState(() {});
  }

  Future<void> getUserData() async {
    userData = await UserPreferences.getUser();
  }

  notificationListApis() {
    setState(() {
      isLoading = true;
    });
    var data = {"uid": uID};
    ApiWrapper.dataPost(Config.notification, data).then((val) {
      setState(() {});
      if ((val != null) && (val.isNotEmpty)) {
        if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
          notificationList = val["NotificationData"];

          setState(() {});
          isLoading = false;
        } else {
          setState(() {});
          isLoading = false;
        }
      }
    });
  }

  Future promotionListApi() async {
    var data = {"uid": uID};
    try {
      var url = Uri.parse(Config.api_url + Config.notification);
      var request = await http.post(url,
          headers: ApiWrapper.headers, body: jsonEncode(data));
      var response = jsonDecode(request.body);

      if (request.statusCode == 200) {
        return response["NotificationData"];
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print("Exeption----- $e");
    }
  }

  Uint8List? decodeBase64Image(String base64String) {
    try {
      // Elimina el encabezado "data:image/png;base64," si existe
      final base64Data = base64String.split(',').last;
      return base64Decode(base64Data);
    } catch (e) {
      print('Error al decodificar la imagen base64: $e');
      return null;
    }
  }

  String timeAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365)
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    if (diff.inDays > 30)
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "m" : "m"} ago";
    if (diff.inDays > 7)
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "week"}";
    if (diff.inDays > 0)
      return "${diff.inDays} ${diff.inDays == 1 ? "day" : "day"} ago";
    if (diff.inHours > 0)
      return "${diff.inHours} ${diff.inHours == 1 ? "h" : "h"} ago";
    if (diff.inMinutes > 0)
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "min"} ago";
    return "just now";
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.backgrounde,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: height / 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(Icons.arrow_back, color: notifire.textcolor)),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  "Promotions".tr,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Gilroy Medium',
                      color: notifire.textcolor),
                ),
              ),
              const SizedBox(),
            ],
          ),
          SizedBox(height: height / 40),
          Expanded(
            child: SingleChildScrollView(
              child: promotionList == null
                  ? const Center(child: CircularProgressIndicator())
                  : promotionList!.isEmpty
                      ? Center(child: Text('No hay promociones disponibles.'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(12),
                          itemCount: promotionList!.length,
                          itemBuilder: (context, i) {
                            final promo = promotionList![i];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              child: InkWell(
                                onTap: () {
                                  print(
                                      'Promoción seleccionada: ${promo.mensaje}');
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      if (promo.imagen != null)
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.memory(
                                            decodeBase64Image(promo.imagen!)!,
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      else
                                        Container(
                                          height: 80,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Icon(Icons.image_not_supported,
                                              size: 40,
                                              color: Colors.grey[600]),
                                        ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          promo.mensaje ?? 'Sin mensaje',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: notifire.textcolor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

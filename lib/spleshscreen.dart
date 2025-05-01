// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goevent2/Controller/AuthController.dart';
import 'package:goevent2/Bottombar.dart';
import 'package:goevent2/Controller/UserPreferences.dart';
import 'package:goevent2/home/home.dart';
import 'package:goevent2/utils/AppWidget.dart';
import 'package:goevent2/utils/globals.dart';
import 'package:goevent2/utils/media.dart';
import 'package:latlong2/latlong.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AppModel/Homedata/HomedataController.dart';
import 'onbonding.dart';
import 'utils/colornotifire.dart';

import 'package:http/http.dart' as http;

String long = "", lat = "";
double longD = 0, latD = 0;

class Spleshscreen extends StatefulWidget {
  const Spleshscreen({Key? key}) : super(key: key);

  @override
  _SpleshscreenState createState() => _SpleshscreenState();
}

class _SpleshscreenState extends State<Spleshscreen> {
  final hData = Get.put(HomeController());

  final x = Get.put(AuthController());
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;

  String? token;
  String? userId;
  String? fechaExpiracion;
  bool? status;

  late StreamSubscription<Position> positionStream;

  // Future<bool> validarToken(String token) async {
  //   final encodedToken = Uri.encodeComponent(token).replaceAll('%24', '\$');
  //   final String apiUrl =
  //       'http://216.225.205.93:3000/api/auth/validToken/$encodedToken';
  //   print('URL completa: $apiUrl');
  //   print(token);
  //   try {
  //     final response = await http.get(
  //       Uri.parse(apiUrl),
  //       headers: {
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //     );

  //     // Imprime el código de estado y el cuerpo de la respuesta
  //     print('Response status: ${response.statusCode}');
  //     print('Response body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       // Intenta decodificar la respuesta solo si el código de estado es 200
  //       try {
  //         var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
  //         if (jsonResponse['rta'] == true) {
  //           print('TOKEN VALIDO');
  //           return true;
  //         } else {
  //           print(
  //               'Error en la validación del token: ${jsonResponse['message']}');
  //           print('TOKEN INVALIDO');
  //           return false;
  //         }
  //       } catch (e) {
  //         print('Error al decodificar el JSON: $e');
  //         return false;
  //       }
  //     } else {
  //       print('Error en la solicitud: ${response.statusCode}');
  //       return false;
  //     }
  //   } catch (e) {
  //     print('Error en en validar el token: $e');
  //     throw Exception('Error al realizar la solicitud: $e');
  //   }
  // }

  Future<void> initializeAsyncDependencies() async {
    try {
       if (deepLinkHandled) return;
      token = await UserPreferences.getToken();

      if (token == null || !await AuthController().validarToken(token!)) {
        Get.to(() => const Onbonding(), duration: Duration.zero);
      } else {
        Get.to(() => const Bottombar(), duration: Duration.zero);
      }

      ;
    } catch (e) {
      print("problemaaaaaaaa: ${e}");
      Get.to(() => const Onbonding(), duration: Duration.zero);
    }
  }

  @override
  void initState() {
    super.initState();
    checkGps();
    getdarkmodepreviousstate();
    initializeAsyncDependencies();
  }

  late ColorNotifire notifire;

  getdarkmodepreviousstate() async {
    x.cCodeApi();
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    notifire.setIsDark = previusstate;
  }

//! permission handel
  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
        } else if (permission == LocationPermission.deniedForever) {
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }
      if (haspermission) {
        setState(() {});
        getLocation();
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }
    setState(() {
      //refresh the UI
    });
  }

//! get lat long
  getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print("Long${position.longitude}"); //Output: 80.24599079
    print("lat${position.latitude}");

    long = position.longitude.toString();
    lat = position.latitude.toString();
    var latlong = LatLng(position.latitude, position.longitude);
    getAddressFromLatLong(latlong);

    setState(() {});
  }

  Future<void> getAddressFromLatLong(LatLng latLng) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      String city = place.locality.toString();
      String country = place.country.toString();

      var currentAddress = city + ((city.isNotEmpty) ? ", " : "") + country;
      save("CurentAdd", currentAddress);
      print(currentAddress);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: notifire.backgrounde,
      body: Center(
        child: Container(
          color: notifire.backgrounde,
          child: Column(
            children: [
              SizedBox(height: height / 2.5),
              Container(
                  color: Colors.transparent,
                  height: height / 7,
                  child: Image.asset("image/Evson.png")),
              SizedBox(height: height / 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "EvSon".tr,
                    style: TextStyle(
                        fontSize: 35,
                        fontFamily: 'Gilroy ExtraBold',
                        color: notifire.gettextcolor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: file_names, avoid_print, dead_code, unnecessary_brace_in_string_interps

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:goevent2/Api/Config.dart';
import 'package:goevent2/Controller/UserPreferences.dart';
import 'package:goevent2/utils/color.dart';
import 'package:http/http.dart' as http;

// Map map = {"uid": uID};

//! Api Call
class ApiWrapper {
  static var headers = {
    'Content-Type': 'application/json',
    'Cookie': 'PHPSESSID=oonu3ro0agbeiik4t0l6egt8ab'
  };

  static doImageUpload(
      String endpoint, Map<String, String> params, List imgs) async {
    var request =
        http.MultipartRequest('POST', Uri.parse(Config.api_url + endpoint));
    request.fields.addAll(params);
    for (int i = 0; i < imgs.length; i++) {
      log(imgs[i].toString(), name: "Image name $i");
      request.files.add(await http.MultipartFile.fromPath('image$i', imgs[i]));
    }
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    var model = await response.stream.bytesToString();

    return jsonDecode(model);
  }

  static showToastMessage(message) {
    Fluttertoast.showToast(
        msg: message,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: buttonColor.withOpacity(0.9),
        textColor: Colors.white,
        fontSize: 14.0);
  }


//Method doesnt work uses an old url
  static dataPost(appUrl, method) async {
    print('la url sera $appUrl');
    print('fbghsjyhgfvjshgfbjshf:------------${method}');
    try {
      var url = Uri.parse(Config.api_url + appUrl);
      print(url);

      var request = await http.post(url, headers: headers, body: jsonEncode(method));
      var response = jsonDecode(request.body);
      print("response----- ${request.body}");

      if (request.statusCode == 200) {
        return response;
      } else {
        return response;
      }
    } catch (e) {
      return e;
      print("Exeption----- $e");
    }
  }

  static Future<dynamic> postData(String url, Map<String, dynamic> data) async {

     try {
    final String? token = await UserPreferences.getToken(); // Obtiene el token

    if (token == null || token.isEmpty) {
      print("Error: Token no encontrado.");
      return null;
    }

    var response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // Agrega el token
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error en POST (${response.statusCode}): ${response.body}");
      return null;
    }
  } catch (e) {
    print("Error en la solicitud de actualizacion: $e");
    return null;
  }
  }


static Future<http.Response?> patchData(String url, Map<String, dynamic> body) async {
  try {
    final String? token = await UserPreferences.getToken(); // Obtiene el token

    if (token == null || token.isEmpty) {
      print("Error: Token no encontrado.");
      return null;
    }

    var response = await http.patch(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // Agrega el token
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      print("Error en PATCH (${response.statusCode}): ${response.body}");
      return null;
    }
  } catch (e) {
    print("Error en la solicitud de actualizacion: $e");
    return null;
  }
}




  static finalticketdataPost(appUrl, method) async {
    try {
      var url = Uri.parse(Config.api_url + appUrl);
      print(url);
      var request =
          await http.post(url, headers: headers, body: jsonEncode(method));

      if (request.statusCode == 200) {
        print("response----- ${request.body}");
        return request.body;
      } else {
        return request.body;
      }
    } catch (e) {
      return e;
      print("Exeption----- $e");
    }
  }

  static dataPostjsonEncode(appUrl, method) async {
    try {
      var url = Uri.parse(Config.api_url + appUrl);
      print(url);
      var request =
          await http.post(url, headers: headers, body: jsonEncode(method));

      if (request.statusCode == 200) {
        return request.body;
      } else {
        return request.body;
      }
    } catch (e) {
      return e;
      print("Exeption----- $e");
    }
  }

  static dataGet(appUrl) async {
    try {
      var url = Uri.parse(Config.api_url + appUrl);
      var request = await http.get(url, headers: headers);
      var response = jsonDecode(request.body);
      if (request.statusCode == 200) {
        return response;
      } else {
        print(request.reasonPhrase);
      }
    } catch (e) {
      return e;

      print("Exeption----- $e");
    }
  }

  static dataGetLocation(appUrl) async {
    try {
      var request = await http.get(appUrl, headers: headers);
      var response = jsonDecode(request.body);
      if (request.statusCode == 200) {
        return response;
      } else {
        print(request.reasonPhrase);
      }
    } catch (e) {
      print("Exeption----- $e");
    }
  }
}

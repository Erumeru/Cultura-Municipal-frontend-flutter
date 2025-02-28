// ignore_for_file: file_names, unused_local_variable, avoid_print

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goevent2/Api/ApiWrapper.dart';
import 'package:goevent2/Bottombar.dart';
import 'package:goevent2/Controller/UserPreferences.dart';
import 'package:goevent2/utils/AppWidget.dart';
import 'package:http/http.dart' as http;

import '../login_signup/ForgetPass.dart';
import '../login_signup/Login.dart';
import '../login_signup/verification.dart';

const String endpoin = 'http://216.225.205.93:3000';

String? tokenUser;
//String? userId;
String? fechaExpiracion;

class AuthController extends GetxController {
  // UserData? userData;
  var countryCode = [];

  String? uID;

  //! user CountryCode
  cCodeApi() {
    countryCode.add(['+52', '+65', '+56', '+23', '+63']);
    /**ApiWrapper.dataGet(Config.cCode).then((val) {
      if ((val != null) && (val.isNotEmpty)) {
        if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
          val["CountryCode"].forEach((e) {
            countryCode.add(e['ccode']);
          });
          update();
        } else {
          ApiWrapper.showToastMessage(val["ResponseMsg"]);
        }
      }
    });**/
  }

  //! user Login Api
  userLogin(String? email, password) {
    /*
    var data = {"mobile": email, "password": password};
    log(data.toString(), name: "Login Api : ");
    ApiWrapper.dataPost(Config.loginuser, data).then((val) {
      log(val.toString(), name: "Login Api : ");
      if ((val != null) && (val.isNotEmpty)) {
        if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
          save("FirstUser", true);
          save("UserLogin", val["UserLogin"]);
          print(val["UserLogin"]);
          AuthService().singInAndStoreData(email: val["UserLogin"]["email"], uid: val["UserLogin"]["id"], proPicPath: val["UserLogin"]["pro_pic"]);
          Get.to(() => const Bottombar(), duration: Duration.zero);
          update();
          ApiWrapper.showToastMessage(val["ResponseMsg"]);
        } else {
          ApiWrapper.showToastMessage(val["ResponseMsg"]);
        }
      }
    });

     */
  }

  Future<void> registrarUsuario({
    required String email,
    required String nombreUsuario,
    required String nombre,
    required String apellido,
    required int? telefono,
    required String password,
  }) async {
    final Uri url = Uri.parse('http://216.225.205.93:3000/api/auth/register');

    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'email': email,
        'nombreUsuario': nombreUsuario,
        'nombre': nombre,
        'apellido': apellido,
        'telefono': telefono,
        'password': password,
        "status_register": 2,
        "status_active": true
      }),
    );

    if (response.statusCode == 200) {
      // Extracción de datos del cuerpo de la respuesta
      final Map<String, dynamic> responseData = json.decode(response.body);
      final bool rta = responseData['rta'];
      final String message = responseData['message'];

      if (rta) {
        final Map<String, dynamic> user = responseData['user'];
        final int id = user['id'];
        final String emailResponse = user['email'];
        final String nombreUsuarioResponse = user['nombreUsuario'];

        print('ID del usuario: $id');
        print('Email del usuario: $emailResponse');
        print('Nombre de usuario: $nombreUsuarioResponse');
        print('Mensaje: $message');

        // Puedes navegar a otra pantalla o realizar otras acciones aquí
        Get.to(() =>
            Verification(verID: id, email: emailResponse, isReset: false));
        //Get.to(() => const Bottombar(), duration: Duration.zero);
        // Si estás utilizando un controlador de estado, no olvides llamar a update() o setState()
        // update(); // Descomentar si es necesario
      } else {
        print('Error: $message');
      }
    } else {
      // Si la solicitud falla, imprime el mensaje de error
      print('Error: ${response.reasonPhrase}');
      print('Código de error: ${response.statusCode}');
    }
  }

  Future<void> crearEvento({
    required BuildContext context, // Contexto como parámetro
    required String tituloEvento,
    String? imagenEvento,
    String? imagenPortadaEvento,
    required String fechaInicio,
    required String fechaFin,
    required String horaInicio,
    required String horaFin,
    required String precio,
    required String descripcionBreve,
    required String descripcion,
    String? galeriaImagen1,
    String? galeriaImagen2,
    String? galeriaImagen3,
    String? organizador,
    String? telefono,
    String? correo,
    required String tituloDireccion,
    required String direccionEvento,
    required String latitud,
    required String longitud,
    int? idUsuario,
    required int idMunicipio,
    required int idCategoria,
    required int idPublicoObjetivo,
  }) async {
    // Muestra la pantalla de carga y obtiene el contexto
    BuildContext dialogContext = context; // Contexto de la pantalla de carga

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context; // Actualiza el contexto dentro del builder
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final token = await UserPreferences.getToken();
      final iduser = await UserPreferences.getUserId();
      final intiduserInt = int.parse(iduser!);
      final Map<String, dynamic> data = {
        'titulo_evento': tituloEvento,
        'imagen_evento': imagenEvento,
        'imagen_portada_evento': imagenPortadaEvento,
        'fecha_inicio': fechaInicio,
        'fecha_fin': fechaFin,
        'hora_inicio': horaInicio,
        'hora_fin': horaFin,
        'precio': precio,
        'descripcion_breve': descripcionBreve,
        'descripcion': descripcion,
        'galeria_imagen_1': galeriaImagen1,
        'galeria_imagen_2': galeriaImagen2,
        'galeria_imagen_3': galeriaImagen3,
        'organizador': iduser,
        'telefono': telefono,
        'correo': correo,
        'titulo_direccion': tituloDireccion,
        'direccion_evento': direccionEvento,
        'latitud': latitud,
        'longitud': longitud,
        'id_usuario': intiduserInt,
        'id_municipio': idMunicipio,
        'id_categoria': idCategoria,
        'id_publico_objetivo': idPublicoObjetivo,
      };

      final jsonData = jsonEncode(data);
      final Uri url = Uri.parse('$endpoin/api/eventos');
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonData,
      );

      Navigator.of(dialogContext).pop(); // Cierra la pantalla de carga

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final bool rta = responseData['rta'];
        final String message = responseData['message'];

        if (rta) {
          final Map<String, dynamic> evento = responseData['evento'];
          final int id = evento['id'];
          final String tituloEventoResponse = evento['titulo_evento'];

          print('__----------------Evento Registrado---------------__');
          print('ID del evento: $id');
          print('El titulo del evento es: $tituloEventoResponse');
          print('Mensaje: $message');
          ApiWrapper.showToastMessage(message);

          // Navega a la pantalla Bottombar
         Get.offAll(() => const Bottombar()); // Esto reemplaza toda la pila de navegación y va directamente a Bottombar
        } else {
          print('Error: $message');
        }
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String message = responseData['message'];
        print('Error: ${response.reasonPhrase}');
        print('message de error: $message');
        ApiWrapper.showToastMessage(
            "Algo salió mal. Inténtalo de nuevo más tarde.");
      }
    } catch (e) {
      Navigator.of(dialogContext)
          .pop(); // Asegúrate de cerrar la pantalla de carga en caso de error
      print('Error al crear el evento: $e');
      ApiWrapper.showToastMessage(
          "Algo salió mal. Inténtalo de nuevo más tarde.");
    }
  }

  Future<bool?> verificarCodigo(
      String codigoVerificacion, int usuarioId, bool isReseet) async {
    final Uri url = Uri.parse('$endpoin/api/verificar_codigo/');
    print(
        '--------------------------------------------------------------------------------------------------');
    print('el codigo_verificacion recibido es: $codigoVerificacion');
    print('el email usuario_id es: $usuarioId');
    print(
        '--------------------------------------------------------------------------------------------------');
    final response = await http.post(
      url,
      body: {
        'codigo_verificacion': codigoVerificacion,
        'usuario_id': usuarioId,
      },
    );

    if (response.statusCode == 200) {
      // Extracción del token del cuerpo de la respuesta
      final Map<String, dynamic> responseData = json.decode(response.body);
      final id = responseData['id'];
      final verificado = responseData['verificado'];
      final email = responseData['email'];
      print(
          '--------------------------------------------------------------------------------------------------');
      print('el id es: $id');
      print('el email es: $email');
      print('Verificado: $verificado');
      print(
          '--------------------------------------------------------------------------------------------------');
      String idStrin = id.toString();
      if (!isReseet) {
        Get.to(() => const Login());
      } else {
        Get.to(() => PasswordsetPage(verID: idStrin));
      }
      return true;
    } else {
      // Si la solicitud falla, imprime el mensaje de error
      print('Error: ${response.reasonPhrase}');
      return false;
    }
  }

  Future<void> iniciarSesion(String email, String password, bool status) async {
    final Uri url = Uri.parse('$endpoin/api/auth/login');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'usuario': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      //final Map<String, dynamic> responseData = json.decode(response.body);
      //final List<dynamic> message = responseData['message'];
      if (jsonResponse['rta'] == true) {
        var message = jsonResponse['message'];
        final user = message[0];
        final token = user['token'];
        final id = user['id_user'];
        final fechaExpiracion = user['fechaExpiracion'];

        print('ID del usuario: $id');
        print('Token recibido: $token');
        print('fechaExpiracion recibido: $fechaExpiracion');

        // Guardar token e ID del usuario usando UserPreferences
        await UserPreferences.setToken(token);
        tokenUser = token;
        //userId = id;
        await UserPreferences.setUserId(id.toString());
        await UserPreferences.setExpToken(fechaExpiracion);

        Get.to(() => const Bottombar(), duration: Duration.zero);
        return;
      } else {
        var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        var message = jsonResponse['message'];
        print('Error: ${response.reasonPhrase}');
        print('Código de error: ${response.statusCode}');
        ApiWrapper.showToastMessage('Error: ${message}');
      }
    } else {
      var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      var message = jsonResponse['message'];
      print('Error: ${response.reasonPhrase}');
      print('Código de error: ${response.statusCode}');
      ApiWrapper.showToastMessage('Error: ${jsonResponse[message]}');
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email) async {
    final Uri url = Uri.parse('$endpoin/api/auth/resetPassword');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['rta'] == true) {
        final user = responseData['user'];
        final id = user['id'];

        // Retornar un mapa con éxito y el ID del usuario
        return {'success': true, 'verID': id};
      } else {
        print('Mensaje: ${responseData['message']}');
        ApiWrapper.showToastMessage("${responseData['message']}");
        return {'success': false};
      }
    } else {
      print('Error: ${response.reasonPhrase}');
      print('Código de error: ${response.statusCode}');
      return {'success': false};
    }
  }

  Future<Map<String, dynamic>> upDatePassword(
      int id, String newPassword, String codigoVerificacion) async {
    final Uri url = Uri.parse('$endpoin/api/auth/updatePassword');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "idUser": id,
        "code": codigoVerificacion,
        "password": newPassword
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['rta'] == true) {
        ApiWrapper.showToastMessage("${responseData['message']}");
        return {'success': true};
      } else {
        print('Mensaje: ${responseData['message']}');
        ApiWrapper.showToastMessage("${responseData['message']}");
        return {'success': false};
      }
    } else {
      print('Error: ${response.reasonPhrase}');
      print('Código de error: ${response.statusCode}');
      return {'success': false};
    }
  }

  Future<bool> reSendCode(int idUser) async {
    final Uri url = Uri.parse('$endpoin/api/auth/reSendCode/$idUser');
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['rta'] == true) {
        ApiWrapper.showToastMessage("${responseData['message']}");
        return true;
      } else {
        print('Mensaje: ${responseData['message']}');
        ApiWrapper.showToastMessage("${responseData['message']}");
        return false;
      }
    } else {
      print('Error: ${response.reasonPhrase}');
      print('Código de error: ${response.statusCode}');
      return false;
    }
  }

  Future<Map<String, dynamic>> validarCode(
      int id, String codigoVerificacion) async {
    final Uri url = Uri.parse('$endpoin/api/auth/validCode');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, dynamic>{"idUser": id, "code": codigoVerificacion}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['rta'] == true) {
        ApiWrapper.showToastMessage("${responseData['message']}");
        return {'success': true};
      } else {
        print('Mensaje: ${responseData['message']}');
        ApiWrapper.showToastMessage("${responseData['message']}");
        return {'success': false};
      }
    } else {
      print('Error: ${response.reasonPhrase}');
      print('Código de error: ${response.statusCode}');
      return {'success': false};
    }
  }

  Future<bool> updatePassword(String id, String newPassword) async {
    final Uri url = Uri.parse('$endpoin/api/update_password/');
    final response = await http.post(
      url,
      body: {"id": id, "new_password": newPassword},
    );
    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      // Extracción del token del cuerpo de la respuesta

      final message = responseData['message'];
      Get.to(() => const Login());
      return true;
    } else {
      // Si la solicitud falla, imprime el mensaje de error
      final error = responseData['error'];
      print('Error: ${response.reasonPhrase}');
      print('Error Backend: $error');
      return false;
    }
  }

  //! user Register Api
  userRegister() {
    /*
    var name = getData.read("User")["UserName"];
    var email = getData.read("User")["UserEmail"];
    var mobile = getData.read("User")["Usernumber"];
    var ccode = getData.read("User")["Ccode"];
    var password = getData.read("User")["FPassword"];
    var rcode = getData.read("User")["ReferralCode"];

    var data = {
      "name": name,
      "email": email,
      "mobile": mobile,
      "ccode": ccode,
      "password": password,
      "refercode": rcode
    };

    ApiWrapper.dataPost(Config.reguser, data).then((val) {
      print('++++++++++++++++++++---------------*****+++$val');
      if ((val != null) && (val.isNotEmpty)) {
        log(val.toString(), name: "Api Register data::");
        if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
          save("UserLogin", val["UserLogin"]);
          AuthService().singUpAndStore(email: val["UserLogin"]["email"], uid: val["UserLogin"]["id"], proPicPath: val["UserLogin"]["pro_pic"]);
          Get.to(() => const Bottombar(), duration: Duration.zero);
          ApiWrapper.showToastMessage(val["ResponseMsg"]);
          update();
        } else{
          ApiWrapper.showToastMessage(val["ResponseMsg"]);
        }
      }
    });
    */
  }
}

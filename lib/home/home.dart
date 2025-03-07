// ignore_for_file: constant_identifier_names, non_constant_identifier_names, avoid_types_as_parameter_names, avoid_print, unused_local_variable, unused_import, unnecessary_null_comparison, prefer_final_fields, prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:goevent2/Controller/UserPreferences.dart';
import 'package:goevent2/home/Categoria.dart';
import 'package:goevent2/home/Evento.dart';

import '../Search/searchpage2.dart';
import '../utils/media.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;

import '../utils/colornotifire.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:goevent2/Api/Config.dart';
import 'package:provider/provider.dart';

import 'package:goevent2/home/seeall.dart';
import 'package:goevent2/spleshscreen.dart';
import 'package:goevent2/utils/color.dart';
import '../notification/notification.dart';
import 'package:geolocator/geolocator.dart';
import 'package:goevent2/utils/string.dart';
import 'package:like_button/like_button.dart';
import 'package:get_storage/get_storage.dart';
import 'package:goevent2/Api/ApiWrapper.dart';
import 'package:goevent2/utils/AppWidget.dart';
import 'package:goevent2/Search/SearchPage.dart';
import 'package:goevent2/home/EventDetails.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:goevent2/home/TrendingCatPage.dart';

import 'package:goevent2/Controller/AuthController.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_image_stack/flutter_image_stack.dart';
import 'package:goevent2/AppModel/Homedata/HomedataController.dart';

final getData = GetStorage();

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final x = Get.put(AuthController());
  //final hData = Get.put(HomeController());
  late ColorNotifire notifire;
  PackageInfo? packageInfo;
  String? appName;
  String? packageName;
  bool isChecked = false;
  String code = "0";
  //List<dynamic> categoriasList = [];
  List<Categoria> categoriasList = [];
  List<Evento> upcomingEvent = [];
  List<Evento> trendingEvent = [];
  List<dynamic> esFavoritos = [];

  //List<dynamic> upcomingEvent = [];
  List<Evento> nearbyEvent = [];
  List<Evento> thisMonthEvent = [];

  String? token;
  String? userId;
  String? fechaExpiracion;

  String base64Image =
      "data:image/png;base64,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";

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");

    if (previusstate == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }

  Future<void> _loadUserData() async {
    token = await UserPreferences.getToken();
    userId = await UserPreferences.getUserId();
    fechaExpiracion = await UserPreferences.getFechaExpiracion();
    setState(
        () {}); // Actualiza la interfaz de usuario con los datos recuperados
  }

/*
  void cargarCategorias() {
    // Decodifica la cadena JSON y guarda los eventos en la lista eventosList
    Map<String, dynamic> categoriasData = json.decode(categoriasJson);
    setState(() {
      categoriasList = categoriasData['categorias'];
      // Inicializa la lista de estados de los marcadores con `false` para indicar que ningún marcador está seleccionado inicialmente
    });
  }
*/
  void cargarCategoriasApi() async {
    // URL de tu API
    String apiUrl = 'http://216.225.205.93:3000/api/categorias';

    // Realiza una solicitud GET a la API
    http.Response response = await http.get(Uri.parse(apiUrl));

    // Verifica si la solicitud fue exitosa (código de estado 200)
    if (response.statusCode == 200) {
      // Decodifica la respuesta JSON con codificación UTF-8
      var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      print('todo bien');

      // Asegúrate de que jsonResponse es un mapa y contiene la clave 'categorias'
      if (jsonResponse is Map && jsonResponse['categorias'] is List) {
        setState(() {
          categoriasList = jsonResponse['categorias'];
          //print(categoriasList);
        });
      } else {
        print('Error: La respuesta no contiene una lista de categorías.');
      }
    } else {
      // Si la solicitud no fue exitosa, muestra un mensaje de error
      print('Error al cargar categorías: ${response.statusCode}');
    }
  }

  Future<List<Evento>> cargarUpcomingEvent() async {
    final String apiUrl =
        'http://216.225.205.93:3000/api/eventos/buscarEventos';

    try {
      final Map<String, dynamic> bodyData = {'id_categoria': 3};

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['rta'] == true) {
          List<dynamic> eventos = responseData['eventos'];

          for (var eventoJson in eventos) {
            upcomingEvent.add(Evento.fromJson(eventoJson));
          }
        } else {
          print('Error en la respuesta: ${responseData['message']}');
        }
      } else {
        print('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la conexión: $e');
    }

    return upcomingEvent;
  }

  Future<void> enviarCategoria(String nombre, String imagePath) async {
    try {
      // Cargar la imagen desde los assets y convertirla a base64
      ByteData bytes = await rootBundle.load(imagePath);
      String base64Image = base64Encode(bytes.buffer.asUint8List());

      // Preparar los datos para enviar
      Map<String, dynamic> data = {
        'nombre': nombre,
        'imagen': 'data:image/png;base64,$base64Image',
        'status_active': true,
      };

      // Convertir los datos a JSON
      String body = jsonEncode(data);

      // Token fijo
      String token =
          r'$2b$10$Tj1i1OIwucYbRsIFpt6Fm.7Us0HrBDIShd.TgiDpxKsn5QEoauhrm'; // Reemplaza esto con tu token

      // Realizar la solicitud POST con el token en los encabezados
      final Uri url = Uri.parse('http://216.225.205.93:3000/api/categorias');
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      // Procesar la respuesta
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responseData = json.decode(response.body);
        bool rta = responseData['rta'];
        if (rta) {
          print('Categoria creada correctamente: ${responseData['message']}');
          // Aquí puedes manejar la respuesta exitosa según sea necesario
        } else {
          print('Error al crear la categoría: ${responseData['message']}');
        }
      } else {
        print('Error de red: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error al enviar la categoría: $e');
    }
  }

  Future<void> cargarCategorias() async {
    CategoriaService service = CategoriaService();
    try {
      List<Categoria> categorias = await service.cargarCategoriasApi();
      setState(() {
        categoriasList = categorias;
      });
    } catch (e) {
      print('Error al cargar categorías: $e');
    }
  }

  Future<void> cargarEventos() async {
    EventosService service = EventosService();
    try {
      List<Evento> eventos = await service.cargarEventosEnUnaSemana();
      setState(() {
        upcomingEvent = eventos;
      });
    } catch (e) {
      print('Error al cargar los eventos: $e');
    }
  }

  Future<void> cargarEventosDelMes() async {
    EventosService service = EventosService();
    try {
      List<Evento> eventos = await service.cargarEventosDelMes();
      setState(() {
        thisMonthEvent = eventos;
      });
    } catch (e) {
      print('Error al cargar los eventos del mes: $e');
    }
  }

  Future<void> cargarEventosCercanos() async {
    EventosService service = EventosService();
    try {
      List<Evento> eventos = await service.cargarEventosCercanos(lat, long);
      setState(() {
        nearbyEvent = eventos;
      });
    } catch (e) {
      print('Error al cargar los eventos cercanos: $e');
    }
  }

  Future<void> cargarEventosFavoritos() async {
    EventosService service = EventosService();
    try {
      List<Evento> eventos = await service.obtenerEventosFavoritos();
      setState(() {
        trendingEvent = eventos;
      });
    } catch (e) {
      print('Error al cargar los eventos cercanos: $e');
    }
  }

  Future<void> cargarEventosFavoritosPorId() async {
    EventosService service = EventosService();
    token = await UserPreferences.getToken();
    userId = await UserPreferences.getUserId();
    fechaExpiracion = await UserPreferences.getFechaExpiracion();
    //status = await UserPreferences.getStatus();

    print('El id es: ${userId}');


//Simple check para ver la respuesta de la api al buscar usuario
// try{

//     var url = Uri.parse('http://216.225.205.93:3000/api/usuarios/{$userId}');
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       print("User Data: $data");
//     } else {
//       print("Failed to load user: ${response.statusCode}");
//       print(response.body);
//     }
//     }catch(e){
//       print('Error al cargar el usuario: $e');
//     }




    if (userId == null) {
      print(
          'El id de usuario es null, no se pueden cargar los eventos favoritos');

      return;
    }

    int? userIdInt = int.tryParse(userId!);
    if (userIdInt == null) {
      print('Error: El id de usuario no es un número válido');

      return;
    }

    try {
      List<dynamic> eventos = await service.obtenerFavoritos(userIdInt);
      print('Eventos favoritos: $eventos');
      setState(() {
        esFavoritos = eventos;
      });
    } catch (e) {
      setState(() {});
      print('Error al cargar los eventos favoritos: $e');
    }
  }

  bool esEventoFavorito(int idEvento) {
    for (var favorito in esFavoritos) {
      if (favorito['id_event'] == idEvento) {
        return true;
      }
    }
    return false;
  }

  Future<bool> agregarAFavoritos(int userId, int eventId) async {
    EventosService service = EventosService();
    bool resultado = await service.crearFavorito(userId, eventId);

    if (resultado) {
      print('Evento añadido a favoritos');
      // Opcional: Actualiza el estado local si es necesario
      return true;
    } else {
      print('No se pudo añadir el evento a favoritos');
      // Maneja el error o muestra un mensaje al usuario
      return false;
    }
  }

  Future<bool> eliminarFavorito(int userId, int eventId) async {
    EventosService service = EventosService();
    bool resultado = await service.eliminarFavorito(userId, eventId);

    if (resultado) {
      print('Evento eliminado de favoritos');
      // Opcional: Actualiza el estado local si es necesario
      return true;
    } else {
      print('No se pudo eliminar de favoritos');
      // Maneja el error o muestra un mensaje al usuario
      return false;
    }
  }

  Future<bool> onLikeButtonTapped(bool isLiked, int eventId) async {
    int userIdInt = int.parse(userId!);

    bool success;

    if (isLiked) {
      // Eliminar de favoritos
      success = await eliminarFavorito(userIdInt, eventId);
    } else {
      // Agregar a favoritos
      success = await agregarAFavoritos(userIdInt, eventId);
    }

    if (success) {
      // Actualiza el estado para reflejar el cambio
      setState(() {
        // Puedes realizar acciones adicionales si es necesario
        // Por ejemplo, recargar la lista de favoritos o eventos
        cargarEventosFavoritosPorId();
      });
    }

    return success; // Retorna el nuevo estado del botón
  }

  @override
  void initState() {
    super.initState();
    //walletrefar();
    getdarkmodepreviousstate();
    getUserLocation();
    //getPackage();
    /*getData.read("UserLogin") != null
        ? hData.homeDataApi(getData.read("UserLogin")["id"], lat, long)
        : null;*/
    cargarCategorias();
    //cargarCategoriasApi();
    cargarEventosFavoritos();
    cargarEventosFavoritosPorId();
    cargarEventos();
    cargarEventosDelMes();
    //cargarThisMonthEvent();
    cargarEventosCercanos();
    _loadUserData();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    OneSignal.initialize(Config.oneSignel);

    OneSignal.Notifications.addPermissionObserver((changes) {
      print("Accepted OSPermissionStateChanges : $changes");
    });
/*
    print("--------------__uID : ${getData.read("UserLogin")["id"]}");
    await OneSignal.User.addTagWithKey(
        "storeid", getData.read("UserLogin")["id"]);
        */
  }

  void getPackage() async {
    //! App details get
    packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo!.appName;
    packageName = packageInfo!.packageName;
  }

  getUserLocation() async {
    Position position = await getLatLong();

    lat = position.longitude.toString();
    long = position.latitude.toString();

    latD = position.latitude;
    longD = position.longitude;
    print('la latitud es:$latD');
    print('la longitud es:$longD');
    setState(() {});
  }

  Future<Position> getLatLong() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  //! ----- LikeButtonTapped -----
  Future<bool> onLikeButtonTappedd(isLiked, eid) async {
    var data = {"eid": eid, "uid": uID};
    ApiWrapper.dataPost(Config.ebookmark, data).then((val) {
      if ((val != null) && (val.isNotEmpty)) {
        if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
          //hData.homeDataReffressApi(getData.read("UserLogin")["id"], lat, long);
        } else {
          ApiWrapper.showToastMessage(val["ResponseMsg"]);
        }
      }
    });
    return !isLiked;
  }

  @override
  Widget build(BuildContext context) {
/*
    Future.delayed(const Duration(seconds: 0), () {
      setState(() {});
    });
*/
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    String base64String = base64Image.split(',').last;
    // Decodifica la cadena base64 en bytes
    Uint8List imageBytes = base64Decode(base64String);
    return Scaffold(
        backgroundColor: notifire.backgrounde,
        body: Column(
          children: [
            //! ------ Home AppBar ------
            homeAppbar(),
            SizedBox(height: height / 60),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //! --------- categoriesList ---------
                    /*
                    Text('Token: $token'),
                    Text('fecha Expiracion: $fechaExpiracion'),
                    Text('User ID: $userId'),
                    
                    ElevatedButton(
                      onPressed: () {
                        enviarCategoria('Museos y Exposiciones', 'image/Museos.png');
                      },
                      child: Text('Upload Image'),
                    ),

*/
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: SizedBox(
                        height: Get.height * 0.05,
                        child: ListView.builder(
                          itemCount: categoriasList.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, i) {
                            return treding(categoriasList,
                                i); // Llama a la función treding con categoriasList
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: Get.height * 0.03),

                    //! ---------- upcoming Events --------

                    //upcomingEvent.isNotEmpty?
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Text("Upcoming Events".tr,
                              style: TextStyle(
                                  fontFamily: 'Gilroy Bold',
                                  color: notifire.textcolor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              Get.to(
                                  () => All(
                                      title: "Upcoming Events".tr,
                                      eventList: upcomingEvent),
                                  duration: Duration.zero);
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Row(
                                children: [
                                  Text("See All".tr,
                                      style: TextStyle(
                                          fontFamily: 'Gilroy Medium',
                                          color: const Color(0xff747688),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400)),
                                  const Icon(Icons.arrow_forward_ios_rounded,
                                      size: 14, color: Color(0xff747688)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //: const SizedBox(),

                    SizedBox(height: height / 60),

                    //! ----------- Upcoming Events List -------------
                    Ink(
                      //height: Get.height * 0.01,
                      height: Get.height * 0.37,
                      child: ListView.builder(
                        itemCount: min(upcomingEvent.length, 10),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (ctx, i) {
                          return events(upcomingEvent[i], i);
                        },
                      ),
                    ),
                    SizedBox(height: height / 60),
                    //! -------- This Month Event  --------
                    //thisMonthEvent.isNotEmpty?
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Text("Event This Month".tr,
                              style: TextStyle(
                                  fontFamily: 'Gilroy Bold',
                                  color: notifire.textcolor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              Get.to(
                                  () => All(
                                      title: "Event This Month".tr,
                                      eventList: thisMonthEvent),
                                  duration: Duration.zero);
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Row(
                                children: [
                                  Text("See All".tr,
                                      style: TextStyle(
                                          fontFamily: 'Gilroy Medium',
                                          color: const Color(0xff747688),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400)),
                                  const Icon(Icons.arrow_forward_ios_rounded,
                                      size: 14, color: Color(0xff747688)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //: const SizedBox(),
                    //! monthly event Listview   --------
                    ListView.builder(
                      itemCount: min(thisMonthEvent.length, 3),
                      padding: const EdgeInsets.only(top: 8),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (ctx, i) {
                        return monthly(thisMonthEvent[i], i);
                      },
                    ),
                    SizedBox(height: Get.height * 0.03),

                    SizedBox(height: height / 60),
                    //! -------- Nearby You Listview  --------
                    //nearbyEvent.isNotEmpty?
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Text(
                            "Nearby You".tr,
                            style: TextStyle(
                                fontFamily: 'Gilroy Bold',
                                color: notifire.textcolor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              Get.to(
                                  () => All(
                                      title: "Nearby You".tr,
                                      eventList: nearbyEvent),
                                  duration: Duration.zero);
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Row(
                                children: [
                                  Text("See All".tr,
                                      style: TextStyle(
                                          fontFamily: 'Gilroy Medium',
                                          color: const Color(0xff747688),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400)),
                                  const Icon(Icons.arrow_forward_ios_rounded,
                                      size: 14, color: Color(0xff747688)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //: const SizedBox(),
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: min(nearbyEvent.length, 3),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (ctx, i) {
                        return conference(nearbyEvent[i], i);
                      },
                    ),
                    SizedBox(height: Get.height * 0.03),

                    //! --------- trndingList ---------
                    //trendingEvent.isNotEmpty?
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Text("Trending Events".tr,
                              style: TextStyle(
                                  fontFamily: 'Gilroy Bold',
                                  color: notifire.textcolor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              Get.to(
                                  () => All(
                                      title: "Trending Events".tr,
                                      eventList: trendingEvent),
                                  duration: Duration.zero);
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Row(
                                children: [
                                  Text("See All".tr,
                                      style: TextStyle(
                                          fontFamily: 'Gilroy Medium',
                                          color: const Color(0xff747688),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400)),
                                  const Icon(Icons.arrow_forward_ios_rounded,
                                      size: 14, color: Color(0xff747688)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //: const SizedBox(),
                    SizedBox(height: Get.height * 0.03),
                    //! --------- trndingList ---------
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        height: Get.height * 0.28,
                        child: ListView.builder(
                          itemCount: min(trendingEvent.length, 6),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, i) {
                            return tredingEvents(trendingEvent[i], i);
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: Get.height * 0.03),

                    SizedBox(height: height / 60),

                    //! --------- invite share -----------
                    InkWell(
                      onTap: share,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          decoration: BoxDecoration(
                              color: notifire.isDark
                                  ? notifire.containercolore
                                  : Color(0xffd6feff),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          height: height / 6,
                          width: double.infinity,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Invite your friends".tr,
                                      // .trPluralParams(),
                                      style: TextStyle(
                                          fontFamily: 'Gilroy Medium',
                                          color: notifire.textcolor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(height: Get.height * 0.01),
                                    /*
                                    Text(
                                      "Get \$20 for ticket".tr,
                                      style: TextStyle(
                                          fontFamily: 'Gilroy Medium',
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                     */
                                    SizedBox(height: Get.height * 0.01),
                                    GestureDetector(
                                      child: Container(
                                        height: height / 30,
                                        width: width / 6,
                                        decoration: BoxDecoration(
                                            color: notifire.getbluecolor,
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: Center(
                                          child: Text(
                                            "INVITE".tr,
                                            style: TextStyle(
                                                fontFamily: 'Gilroy Medium',
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Image.asset("image/invite.png",
                                  height: height / 6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height / 60),
                  ],
                ),
              ),
            )
          ],
        ));
  }

  Widget treding(List<Categoria> catList, int i) {
    //print('la imagen de la categoria es: ${catList[i].imagen}');

    return InkWell(
      onTap: () {
        Get.to(() => TrndingPage(idCategoria: catList[i].id));
        // Handle onTap action
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Container(
          decoration: BoxDecoration(
            color: notifire
                .backgrounde, // Reemplaza notifire.backgrounde con un color
            border: Border.all(
                color: notifire.bordercolore,
                width: 0.5), // Reemplaza notifire.bordercolore con un color
            borderRadius: BorderRadius.circular(25),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 4, right: 8, bottom: 10),
            child: Row(
              children: [
                Image.network(
                  'http://216.225.205.93:3000${catList[i].imagen}',
                  fit: BoxFit.cover,
                ),
                SizedBox(
                    width: 8.0), // Reemplaza Get.width * 0.02 con un valor fijo
                Text(
                  catList[i].nombre,
                  style: TextStyle(
                    fontFamily: 'Gilroy Medium',
                    color: notifire
                        .textcolor, // Reemplaza notifire.textcolor con un color
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

/*
  treding(catList, i) {
    return InkWell(
      onTap: () {
        Get.to(() => TrndingPage(catdata: catList[i]));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Container(
          decoration: BoxDecoration(
              color: notifire.getprimerycolor,
              border: Border.all(color: notifire.bordercolore, width: 0.5),
              borderRadius: BorderRadius.circular(25)),
          child: Padding(
            padding: const EdgeInsets.only(left: 4, right: 8),
            child: Row(
              children: [
                Image(
                    image:
                        NetworkImage(Config.base_url + catList[i]["cat_img"]),
                    height: 30),
                SizedBox(width: Get.width * 0.02),
                Text(catList[i]["title"],
                    style: TextStyle(
                        fontFamily: 'Gilroy Medium',
                        color: notifire.textcolor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

 */

  /*
  imgloading() {
    return Container(
      height: Get.height * 0.20,
      width: Get.width * 0.62,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
              image: AssetImage("image/skeleton.gif"), fit: BoxFit.fill)),
    );
  }

   */

  tredingEvents(Evento evento, int i) {
    return InkWell(
      onTap: () {
        Get.to(() => EventsDetails(eid: evento.id.toString(), evento: evento),
            duration: Duration.zero);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          width: Get.width * 0.60,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                child: SizedBox(
                  height: Get.height * 0.20,
                  width: Get.width * 0.62,
                  child: evento.imagenEvento != null
                      ? Image.network(
                          'http://216.225.205.93:3000${evento.imagenEvento}',
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color:
                              Colors.grey[200], // Color de marcador de posición
                          child: Icon(Icons.image,
                              color:
                                  Colors.grey), // Icono de marcador de posición
                        ),
                ),
              ),
              Positioned(
                top: 8,
                right: Get.width * 0.02,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100 / 2),
                  child: BackdropFilter(
                    blendMode: BlendMode.srcIn,
                    filter: ImageFilter.blur(
                      sigmaX: 10, // mess with this to update blur
                      sigmaY: 10,
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 3),
                        child: LikeButton(
                          isLiked:
                              esEventoFavorito(evento.id), // Estado inicial
                          onTap: (bool isLiked) async {
                            // Manejo asincrónico del estado
                            bool success =
                                await onLikeButtonTapped(isLiked, evento.id);
                            return !success;
                          },
                          likeBuilder: (bool isLiked) {
                            return !isLiked
                                ? const Icon(Icons.favorite_border,
                                    color: Colors.grey, size: 24)
                                : const Icon(Icons.favorite,
                                    color: Color(0xffF0635A), size: 24);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: Get.height * 0.15,
                  width: Get.width * 0.58,
                  decoration: BoxDecoration(
                    color: notifire.getprimerycolor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: notifire.bordercolore),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: Get.height * 0.01),
                        Ink(
                          width: Get.width * 0.50,
                          child: Text(
                            evento.tituloEvento,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Gilroy Medium',
                              color: notifire.textcolor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: Get.height * 0.006),
                        Expanded(
                          child: Row(
                            children: [
                              Image.asset("image/location.png",
                                  height: height / 50),
                              SizedBox(width: Get.width * 0.01),
                              Ink(
                                width: Get.width * 0.45,
                                child: Text(
                                  evento.direccionEvento,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Gilroy Medium',
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //SizedBox(height: Get.height * 0.001),
                        /*
                        Expanded(
                          child: Row(
                            children: [
                              tEvent[i]["sponsore_list"] != null
                                  ? CircleAvatar(
                                      radius: 16.0,
                                      backgroundImage: AssetImage(tEvent[i]
                                          ["sponsore_list"]["sponsore_img"]),
                                      backgroundColor: Colors.transparent,
                                    )
                                  : const SizedBox(),
                              SizedBox(width: Get.width * 0.01),
                              Text(
                                "Organizer".tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Gilroy Medium',
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),

                              //Spacer(),
                              /*
                            Container(
                              height: Get.height * 0.04,
                              width: Get.width * 0.20,
                              decoration: BoxDecoration(
                                color: buttonColor.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "Join".tr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Gilroy Bold',
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            */
                            ],
                          ),
                        ),
                        */
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(height: Get.height / 6),
                  Row(
                    children: [
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: notifire.getprimerycolor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                        ),
                        height: Get.height / 30,
                        width: Get.width / 4,
                        child: Center(
                          child: Text(
                            evento.fechaInicio.substring(0, 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xffF0635A),
                              fontSize: 11,
                              fontFamily: 'Gilroy ExtraBold',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  homeAppbar() {
    return Container(
      decoration: BoxDecoration(
          color: notifire.homecontainercolore,
          borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(30),
              bottomLeft: Radius.circular(30))),
      height: Get.height * 0.18,
      child: Column(
        children: [
          SizedBox(height: Get.height * 0.055),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  height: Get.height * 0.06,
                  color: Colors.transparent,
                  child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: Image.asset("image/CalendarioEvson.png")),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Current Location".tr,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Gilroy Medium',
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        getData.read("CurentAdd") ?? "",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Gilroy Medium',
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    //! ------ Notification Page -----
                    Get.to(() => const Note(), duration: Duration.zero);
                  },
                  child: Image.asset("image/bell.png", height: height / 20),
                ),
              ],
            ),
          ),
          SizedBox(height: Get.height * 0.015),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: InkWell(
              onTap: () {
                Get.to(() => const SearchPage2());
              },
              child: Row(
                children: [
                  Image.asset("image/search.png", height: height / 30),
                  SizedBox(width: width / 90),
                  Container(width: 1, height: height / 40, color: Colors.grey),
                  SizedBox(width: width / 90),
                  //! ------ Search TextField -------
                  Text(
                    "Search...".tr,
                    style: TextStyle(
                        fontFamily: 'Gilroy Medium',
                        color: const Color(0xffd2d2db),
                        fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _mImages = [];

  Widget monthly(Evento evento, int i) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: () {
          Get.to(() => EventsDetails(eid: evento.id.toString(), evento: evento),
              duration: Duration.zero);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
              color: notifire.containercolore,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: notifire.bordercolore)),
          height: height / 7,
          width: width,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 8, right: 6, bottom: 5, top: 5),
            child: Row(children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                child: SizedBox(
                  width: width / 5,
                  height: height / 8,
                  child: evento.imagenEvento != null
                      ? Image.network(
                          'http://216.225.205.93:3000${evento.imagenEvento}',
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color:
                              Colors.grey[200], // Color de marcador de posición
                          child: Icon(Icons.image,
                              color:
                                  Colors.grey), // Icono de marcador de posición
                        ),
                ),
                /*
                child: SizedBox(
                  width: width / 5,
                  height: height / 8,
                  child: FadeInImage.assetNetwork(
                      fadeInCurve: Curves.easeInCirc,
                      placeholder: "image/skeleton.gif",
                      fit: BoxFit.cover,
                      image: Config.base_url + nearby[i]["event_img"]),
                ),
                 */
              ),
              Column(children: [
                SizedBox(height: height / 500),
                Row(
                  children: [
                    SizedBox(width: width / 50),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: Get.width * 0.35,
                                child: Text(
                                  evento.fechaInicio.substring(0, 10),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontFamily: 'Gilroy Medium',
                                      color: Color(0xff4A43EC),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              SizedBox(width: width * 0.21),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100 / 2),
                                child: BackdropFilter(
                                  blendMode: BlendMode.srcIn,
                                  filter: ImageFilter.blur(
                                    sigmaX: 10, // mess with this to update blur
                                    sigmaY: 10,
                                  ),
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 3),
                                      child: LikeButton(
                                        isLiked: esEventoFavorito(
                                            evento.id), // Estado inicial
                                        onTap: (bool isLiked) async {
                                          // Manejo asincrónico del estado
                                          bool success =
                                              await onLikeButtonTapped(
                                                  isLiked, evento.id);
                                          return !success;
                                        },
                                        likeBuilder: (bool isLiked) {
                                          return !isLiked
                                              ? const Icon(
                                                  Icons.favorite_border,
                                                  color: Colors.grey,
                                                  size: 24)
                                              : const Icon(Icons.favorite,
                                                  color: Color(0xffF0635A),
                                                  size: 24);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: Get.width * 0.55,
                            child: Text(evento.tituloEvento,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: 'Gilroy Medium',
                                    color: notifire.textcolor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                          SizedBox(height: height / 300),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  "image/location.png",
                                  height: height / 50,
                                ),
                                SizedBox(width: Get.width * 0.01),
                                SizedBox(
                                  width: Get.width * 0.56,
                                  child: Text(
                                    evento.direccionEvento,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Gilroy Medium',
                                        color: Colors.grey,
                                        fontSize: 10),
                                  ),
                                ),
                              ]),
                        ]),
                  ],
                ),
              ])
            ]),
          ),
        ),
      ),
    );
  }

  Widget rights(se, name1, name, img, txtcolor, ce) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(img, height: height / 15),
        SizedBox(width: width / 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name1,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Gilroy Bold',
                  color: txtcolor),
            ),
            Text(
              name,
              style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Gilroy Normal',
                  color: Colors.grey),
            ),
          ],
        ),
        se,
        ce
      ],
    );
  }

  Widget conference(Evento evento, int i) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: () {
          //Get.to(() => EventsDetails(eid: nearby[i]["event_id"]), duration: Duration.zero);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
              color: notifire.containercolore,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: notifire.bordercolore)),
          height: height / 7,
          width: width,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 8, right: 6, bottom: 5, top: 5),
            child: Row(children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                child: SizedBox(
                  width: width / 5,
                  height: height / 8,
                  child: evento.imagenEvento != null
                      ? Image.network(
                          'http://216.225.205.93:3000${evento.imagenEvento}',
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color:
                              Colors.grey[200], // Color de marcador de posición
                          child: Icon(Icons.image,
                              color:
                                  Colors.grey), // Icono de marcador de posición
                        ),
                ),
                /*
                child: SizedBox(
                  width: width / 5,
                  height: height / 8,
                  child: FadeInImage.assetNetwork(
                      fadeInCurve: Curves.easeInCirc,
                      placeholder: "image/skeleton.gif",
                      fit: BoxFit.cover,
                      image: Config.base_url + nearby[i]["event_img"]),
                ),
                 */
              ),
              Column(children: [
                SizedBox(height: height / 500),
                Row(
                  children: [
                    SizedBox(width: width / 50),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: Get.width * 0.35,
                                child: Text(
                                  evento.fechaInicio,
                                  style: const TextStyle(
                                      fontFamily: 'Gilroy Medium',
                                      color: Color(0xff4A43EC),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              SizedBox(width: width * 0.21),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100 / 2),
                                child: BackdropFilter(
                                  blendMode: BlendMode.srcIn,
                                  filter: ImageFilter.blur(
                                    sigmaX: 10, // mess with this to update blur
                                    sigmaY: 10,
                                  ),
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 3),
                                      child: LikeButton(
                                        isLiked: esEventoFavorito(
                                            evento.id), // Estado inicial
                                        onTap: (bool isLiked) async {
                                          // Manejo asincrónico del estado
                                          bool success =
                                              await onLikeButtonTapped(
                                                  isLiked, evento.id);
                                          return !success;
                                        },
                                        likeBuilder: (bool isLiked) {
                                          return !isLiked
                                              ? const Icon(
                                                  Icons.favorite_border,
                                                  color: Colors.grey,
                                                  size: 24)
                                              : const Icon(Icons.favorite,
                                                  color: Color(0xffF0635A),
                                                  size: 24);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: Get.width * 0.55,
                            child: Text(evento.tituloEvento,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: 'Gilroy Medium',
                                    color: notifire.textcolor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                          SizedBox(height: height / 300),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  "image/location.png",
                                  height: height / 50,
                                ),
                                SizedBox(width: Get.width * 0.01),
                                SizedBox(
                                  width: Get.width * 0.56,
                                  child: Text(
                                    evento.direccionEvento,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Gilroy Medium',
                                        color: Colors.grey,
                                        fontSize: 10),
                                  ),
                                ),
                              ]),
                        ]),
                  ],
                ),
              ])
            ]),
          ),
        ),
      ),
    );
  }

  List<String> upMember = [];
  Widget events(Evento evento, int i) {
    //print('La imagen es: ${evento.imagenEvento}');

    return Stack(
      children: [
        InkWell(
          onTap: () {
            Get.to(
                () => EventsDetails(eid: evento.id.toString(), evento: evento),
                duration: Duration.zero);
          },
          child: Container(
            color: Colors.transparent,
            width: Get.width / 1.55,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: notifire.bordercolore),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: Get.height / 5.5,
                          width: Get.width / 1.7,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(16)),
                                child: SizedBox(
                                  height: Get.height * 0.20,
                                  width: Get.width * 0.62,
                                  child: evento.imagenEvento != null
                                      ? Image.network(
                                          'http://216.225.205.93:3000${evento.imagenEvento}',
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: Colors.grey[
                                              200], // Color de marcador de posición
                                          child: Icon(Icons.image,
                                              color: Colors
                                                  .grey), // Icono de marcador de posición
                                        ),
                                ),
                              ),
                              Column(
                                children: [
                                  SizedBox(height: Get.height / 70),
                                  Row(
                                    children: [
                                      SizedBox(width: Get.width / 70),
                                      const Spacer(),
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100 / 2),
                                        child: BackdropFilter(
                                          blendMode: BlendMode.srcIn,
                                          filter: ImageFilter.blur(
                                            sigmaX:
                                                10, // Ajustar para modificar el desenfoque
                                            sigmaY: 10,
                                          ),
                                          child: CircleAvatar(
                                            radius: 18,
                                            backgroundColor: Colors.transparent,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 3),
                                              child: LikeButton(
                                                isLiked: esEventoFavorito(evento
                                                    .id), // Estado inicial
                                                onTap: (bool isLiked) async {
                                                  // Manejo asincrónico del estado
                                                  bool success =
                                                      await onLikeButtonTapped(
                                                          isLiked, evento.id);
                                                  return !success;
                                                },
                                                likeBuilder: (bool isLiked) {
                                                  return !isLiked
                                                      ? const Icon(
                                                          Icons.favorite_border,
                                                          color: Colors.grey,
                                                          size: 24)
                                                      : const Icon(
                                                          Icons.favorite,
                                                          color:
                                                              Color(0xffF0635A),
                                                          size: 24);
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: Get.width / 50),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Get.height / 50),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          width: Get.width,
                          child: Text(
                            evento.tituloEvento,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Gilroy Medium',
                              color: notifire.textcolor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: Get.height / 80),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            children: [
                              Image.asset("image/location.png",
                                  height: Get.height / 50),
                              SizedBox(width: Get.width * 0.01),
                              SizedBox(
                                width: Get.width * 0.49,
                                child: Text(
                                  evento.direccionEvento,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Gilroy Medium',
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(height: Get.height / 6),
                        Row(
                          children: [
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                color: notifire.getprimerycolor,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                              ),
                              height: Get.height / 30,
                              width: Get.width / 4,
                              child: Center(
                                child: Text(
                                  evento.fechaInicio.substring(0, 10),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: const Color(0xffF0635A),
                                    fontSize: 11,
                                    fontFamily: 'Gilroy ExtraBold',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> share() async {
    await FlutterShare.share(
        title: 'EvSon App',
        text:
            '¡Descubre todo lo que la cultura local tiene para ofrecer con la aplicación oficial de Evson! Descárgala ahora y únete a nosotros para celebrar la riqueza y diversidad cultural de nuestra comunidad.',
        linkUrl: 'https://play.google.com/store/apps/details?id=$packageName',
        chooserTitle: 'Compartir EvSon');
  }

/*
  walletrefar() async {
    var data = {"uid": uID};

    ApiWrapper.dataPost(Config.refardata, data).then((val) {
      if ((val != null) && (val.isNotEmpty)) {
        if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
          setState(() {});
          code = val["code"];
        } else {
          setState(() {});
        }
      }
    });
  }
  */

/*
  tredingEvents(tEvent, i) {
    return InkWell(
      onTap: () {
        //Get.to(() => EventsDetails(eid: tEvent[i]["event_id"]), duration: Duration.zero);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          width: Get.width * 0.60,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                child: SizedBox(
                  height: Get.height * 0.20,
                  width: Get.width * 0.62,
                  child: FadeInImage.assetNetwork(
                      fadeInCurve: Curves.easeInCirc,
                      placeholder: "image/skeleton.gif",
                      fit: BoxFit.cover,
                      image: Config.base_url + tEvent[i]["event_img"]),
                ),
              ),
              Positioned(
                top: 8,
                right: Get.width * 0.02,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100/2),
                  child: BackdropFilter(
                    blendMode: BlendMode.srcIn,
                    filter: ImageFilter.blur(
                      sigmaX: 10, // mess with this to update blur
                      sigmaY: 10,
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 3),
                        child: LikeButton(
                          onTap: (val) {
                            return onLikeButtonTapped(val, tEvent[i]["event_id"]);
                          },
                          likeBuilder: (bool isLiked) {
                            return tEvent[i]["IS_BOOKMARK"] != 0
                                ? const Icon(Icons.favorite,
                                color: Color(0xffF0635A), size: 22)
                                : const Icon(Icons.favorite_border,
                                color: Color(0xffF0635A), size: 22);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: Get.height * 0.12,
                    width: Get.width * 0.56,
                    decoration: BoxDecoration(
                        color: notifire.getprimerycolor,
                        borderRadius: BorderRadius.circular(16)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                          border: Border.all(color: notifire.bordercolore),
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: Get.height * 0.01),
                          Ink(
                            width: Get.width * 0.50,
                            child: Text(tEvent[i]["event_title"],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: 'Gilroy Medium',
                                    color: notifire.textcolor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                          ),
                          SizedBox(height: Get.height * 0.006),
                          Row(
                            children: [
                              Image.asset("image/location.png",
                                  height: height / 50),
                              SizedBox(width: Get.width * 0.01),
                              Ink(
                                width: Get.width * 0.45,
                                child: Text(tEvent[i]["event_address"],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Gilroy Medium',
                                        color: Colors.grey,
                                        fontSize: 14)),
                              ),
                            ],
                          ),
                          SizedBox(height: Get.height * 0.008),
                          Row(
                            children: [
                              tEvent[i]["sponsore_list"] != null
                                  ? CircleAvatar(
                                radius: 16.0,
                                backgroundImage: NetworkImage(
                                    Config.base_url +
                                        tEvent[i]["sponsore_list"]
                                        ["sponsore_img"]),
                                backgroundColor: Colors.transparent,
                              )
                                  : const SizedBox(),
                              SizedBox(width: Get.width * 0.01),
                              Text(
                                "Sponser".tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: 'Gilroy Medium',
                                    color: Colors.grey,
                                    fontSize: 14),
                              ),
                              const Spacer(),
                              Container(
                                height: Get.height * 0.04,
                                width: Get.width * 0.20,
                                decoration: BoxDecoration(
                                    color: buttonColor.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: Text(
                                    "Join".tr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Gilroy Bold',
                                        color: Colors.white,
                                        fontSize: 14),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

 */
}

/*
              child: SingleChildScrollView(
                child: !hData.isLoading
                    ? Column(
                        children: [
                          SizedBox(height: height / 60),
                          //! ----- trending Event List ------
                          SizedBox(height: height / 80),
                          hData.catlist.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: SizedBox(
                                    height: Get.height * 0.05,
                                    child: ListView.builder(
                                      itemCount: hData.homeDataList["Catlist"].length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (ctx, i) {
                                        var catlist = hData.homeDataList["Catlist"];
                                        return treding(catlist, i);
                                      },
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          SizedBox(height: Get.height * 0.03),
                          hData.trendingEvent.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Row(
                                    children: [
                                      Text("Trending Events".tr,style: TextStyle(fontFamily: 'Gilroy Bold', color: notifire.textcolor, fontSize: 16, fontWeight: FontWeight.w600)),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(
                                              () => All(title: "Trending Events".tr, eventList: hData.trendingEvent), duration: Duration.zero);
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          child: Row(
                                            children: [
                                              Text("See All".tr,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Gilroy Medium',
                                                      color: const Color(
                                                          0xff747688),
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400)),
                                              const Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  size: 14,
                                                  color: Color(0xff747688)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(),
                          SizedBox(height: Get.height * 0.03),
                          //! --------- trndingList ---------
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: SizedBox(
                              height: Get.height * 0.28,
                              child: ListView.builder(
                                itemCount: hData.trendingEvent.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (ctx, i) {
                                  return tredingEvents(hData.trendingEvent, i);
                                },
                              ),
                            ),
                          ),

                          SizedBox(height: height / 60),
                          //! ---------- upcoming Events --------

                          hData.upcomingEvent.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Row(
                                    children: [
                                      Text("Upcoming Events".tr,
                                          style: TextStyle(
                                              fontFamily: 'Gilroy Bold',
                                              color: notifire.textcolor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(
                                              () => All(
                                                  title: "Upcoming Events".tr,
                                                  eventList:
                                                      hData.upcomingEvent),
                                              duration: Duration.zero);
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          child: Row(
                                            children: [
                                              Text("See All".tr,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Gilroy Medium',
                                                      color: const Color(
                                                          0xff747688),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                              const Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  size: 14,
                                                  color: Color(0xff747688)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(),

                          SizedBox(height: height / 60),

                          //! ----------- Upcoming Events List -------------
                          Ink(
                            height: Get.height * 0.37,
                            child: ListView.builder(
                              itemCount: hData.upcomingEvent.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (ctx, i) {
                                return events(hData.upcomingEvent[i], i);
                              },
                            ),
                          ),

                          SizedBox(height: height / 60),
                          //! --------- invite share -----------
                          InkWell(
                            onTap: share,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: notifire.isDark ? notifire.containercolore : Color(0xffd6feff),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10))),
                                height: height / 6,
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Invite your friends".tr,
                                            // .trPluralParams(),
                                            style: TextStyle(
                                                fontFamily: 'Gilroy Medium',
                                                color: notifire.textcolor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          SizedBox(height: Get.height * 0.01),
                                          Text(
                                            "Get \$20 for ticket".tr,
                                            style: TextStyle(
                                                fontFamily: 'Gilroy Medium',
                                                color: Colors.grey,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          SizedBox(height: Get.height * 0.01),
                                          GestureDetector(
                                            child: Container(
                                              height: height / 30,
                                              width: width / 6,
                                              decoration: BoxDecoration(
                                                  color: notifire.getbluecolor,
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              child: Center(
                                                child: Text(
                                                  "INVITE".tr,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Gilroy Medium',
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Image.asset("image/invite.png",
                                        height: height / 6),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: height / 60),
                          //! -------- Nearby You Listview  --------
                          hData.nearbyEvent.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Nearby You".tr,
                                        style: TextStyle(
                                            fontFamily: 'Gilroy Bold',
                                            color: notifire.textcolor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(
                                              () => All(
                                                  title: "Nearby You".tr,
                                                  eventList: hData.nearbyEvent),
                                              duration: Duration.zero);
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          child: Row(
                                            children: [
                                              Text("See All".tr,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Gilroy Medium',
                                                      color: const Color(
                                                          0xff747688),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                              const Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  size: 14,
                                                  color: Color(0xff747688)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(),
                          ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: hData.nearbyEvent.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (ctx, i) {
                              return conference(hData.nearbyEvent, i);
                            },
                          ),
                          hData.thisMonthEvent.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Row(
                                    children: [
                                      Text("Event This Month".tr,
                                          style: TextStyle(
                                              fontFamily: 'Gilroy Bold',
                                              color: notifire.getdarkscolor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(
                                              () => All(
                                                  title: "Event This Month".tr,
                                                  eventList:
                                                      hData.thisMonthEvent),
                                              duration: Duration.zero);
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          child: Row(
                                            children: [
                                              Text("See All".tr,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Gilroy Medium',
                                                      color: const Color(
                                                          0xff747688),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                              const Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  size: 14,
                                                  color: Color(0xff747688)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(),
                          //! monthly event
                          ListView.builder(
                            itemCount: hData.thisMonthEvent.length,
                            padding: const EdgeInsets.only(top: 8),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (ctx, i) {
                              return monthly(hData.thisMonthEvent, i);
                            },
                          ),
                        ],
                      )
                    : isLoadingCircular(),
              ),

 */

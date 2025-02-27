// ignore_for_file: file_names, avoid_print, prefer_const_constructors, prefer_is_empty, prefer_collection_literals

import 'dart:convert';
import 'dart:math' as mt;
import 'dart:ui' as ui;
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:goevent2/Api/ApiWrapper.dart';
import 'package:goevent2/Api/Config.dart';
import 'package:goevent2/AppModel/Homedata/HomedataController.dart';
import 'package:goevent2/home/EventDetails.dart';
import 'package:goevent2/home/Evento.dart';
import 'package:goevent2/spleshscreen.dart';
import 'package:goevent2/utils/colornotifire.dart';
import 'package:goevent2/utils/media.dart';
import 'package:latlong2/latlong.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';

const String eventosJson = '''
{
  "eventos": [
    {
      "id": "1",
      "latitud": 27.495248234833745,
      "longitud": -109.9470934931631,
      "imagen": "image/event.png",
      "fecha": "2024-03-20",
      "titulo": "Concierto en el Parque",
      "direccion": "Calle Principal #123, Ciudad, País"
    },
    {
      "id": "2",
      "latitud": 27.483391313852678,
      "longitud": -109.92820066731134,
      "imagen": "image/p10.png",
      "fecha": "2024-04-10",
      "titulo": "Festival de Arte",
      "direccion": "Avenida Central #456, Ciudad, País"
    },
    {
      "id": "3",
      "latitud": 27.47062003073426,
      "longitud": -109.92950991433156,
      "imagen": "image/logo.png",
      "fecha": "2024-05-15",
      "titulo": "Carrera 5k Solidaria",
      "direccion": "Plaza de la Constitución, Ciudad, País"
    },
    {
      "id": "4",
      "latitud": 27.496513339729418,
      "longitud": -109.96466535485848,
      "imagen": "image/protection.png",
      "fecha": "2024-05-15",
      "titulo": "Trote 10k Marrano",
      "direccion": "Plaza de la Constitución, Ciudad, País"
    }
  ]
}
''';

//! Done
class SearchPage extends StatefulWidget {
  final String? type;
  const SearchPage({Key? key, this.type}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late ColorNotifire notifire;

  List eventAllList = [];
  bool isLoading = false;
  bool isTapped = false;
  List<Evento> eventosList = []; // Lista para almacenar los eventos
  List<bool> isMarkerTappedList =
      []; // Lista para mantener el estado de cada marcador
  dynamic selectedConference;

  double _currentSliderValue = 7.0; // Distancia en kilómetros
  late MapController _mapController;
  double _circleRadius = 0.0; // Valor inicial de la distancia

  List<Evento> eventosListFiltrados = []; // Lista de eventos filtrados según la distancia
List<dynamic> eventosIdsList = []; // Lista de eventos con distancias obtenidas del servicio

  @override
  void initState() {
  super.initState();
  _mapController = MapController();

  // Esperar un pequeño retraso para asegurar que _mapController esté listo
  Future.delayed(Duration(milliseconds: 100), () {
    _updateCircleRadius(); // Inicializar el radio cuando se carga el mapa
  });

  eventSearchApi("a");
  cargarEventosCercanos(); // Cargar eventos cercanos al inicio
  getdarkmodepreviousstate();
}

  void _updateCircleRadius() {
  setState(() {
    _circleRadius = _calculateRadiusInPixels();
  });
}

double _calculateRadiusInPixels() {
  // Tamaño en metros por píxel en el nivel de zoom actual
  final metersPerPixel = 156543.03392 *
      mt.cos(latD * pi / 180) /
      mt.pow(2, _mapController.camera.zoom);
  return (_currentSliderValue * 1000) / metersPerPixel;
}

// Método para cargar eventos cercanos al inicio
Future<void> cargarEventosCercanos() async {
  EventosService service = EventosService();
  try {
    // Cargar todos los eventos cercanos sin distancias
    List<Evento> eventos = await service.cargarEventosCercanos(lat, long);
    
    // Cargar todos los eventos con distancias
    List<dynamic> eventosIds = await service.obtenerEventosCercanos(lat, long);

    // Guardar eventos y distancias en variables globales
    setState(() {
      eventosList = eventos;
      eventosIdsList = eventosIds;
    });

    // Actualizar los eventos filtrados según el slider inicial
    actualizarEventosFiltrados();

  } catch (e) {
    print('Error al cargar los eventos cercanos: $e');
  }
}

// Método para actualizar eventos según la distancia
void actualizarEventosFiltrados() {
  // Filtrar eventos que estén dentro de la distancia en kilómetros especificada
  final eventosFiltrados = eventosIdsList.where((evento) {
    return evento['distance'] <= _currentSliderValue;
  }).map((evento) => evento['id']).toList();

  setState(() {
    // Filtrar los eventos en eventosList basándote en las IDs filtradas
    eventosListFiltrados = eventosList.where((evento) {
      return eventosFiltrados.contains(evento.id);
    }).toList();

    isMarkerTappedList = List.generate(eventosListFiltrados.length, (index) => false);

    // Imprimir resultados filtrados
    print('Eventos filtrados por distancia:');
    for (var evento in eventosListFiltrados) {
      print('Evento ID: ${evento.id}');
    }
  });
}

// Método para manejar el cambio del valor del slider
void onSliderValueChanged(double newValue) {
  setState(() {
    _currentSliderValue = newValue;
    _updateCircleRadius();
    actualizarEventosFiltrados(); // Actualizar eventos filtrados según el nuevo valor del slider
  });
}




  // Método para cambiar el estado de selección de un marcador
  void toggleMarkerSelection(int index) {
    setState(() {
      // Cambia el estado de selección del marcador en el índice dado
      isMarkerTappedList[index] = !isMarkerTappedList[index];
      // Si se selecciona este marcador, deselecciona todos los demás
      if (isMarkerTappedList[index]) {
        isMarkerTappedList =
            List.generate(isMarkerTappedList.length, (idx) => idx == index);
      }
    });
  }

  // Función para mostrar la conferencia seleccionada
  Widget showSelectedConference() {
    if (selectedConference != null) {
      return conference(selectedConference);
    } else {
      return Container(); // En caso de que no haya conferencia seleccionada
    }
  }

  eventSearchApi(String? val) {
    isLoading = true;
    setState(() {});
    var data = {"title": val, "uid": uID};
    print(data);
    ApiWrapper.dataPost(Config.eventSearch, data).then((val) {
      if ((val != null) && (val.isNotEmpty)) {
        if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
          eventAllList = val["SearchData"];
          //getmarkers();
          isLoading = false;
          setState(() {});
          log(val.toString(), name: " Event Search Api :: ");
        } else {
          isLoading = false;
          setState(() {});
          // ApiWrapper.showToastMessage(val["ResponseMsg"]);
        }
      }
    });
  }

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    notifire.setIsDark = previusstate;
  }

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 0), () => setState(() {}));
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
        backgroundColor: notifire.backgrounde,
        body: Column(
          children: [
            Container(
              height: Get.height * 0.15,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: notifire.gettopcolor,
                  borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 08),
                child: Column(
                  children: [
                    SizedBox(height: Get.height * 0.05),
                    Padding(
                      padding: EdgeInsets.only(left: Get.width * 0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          widget.type == "0"
                              ? InkWell(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: const Icon(Icons.arrow_back,
                                      color: Colors.white, size: 26),
                                )
                              : const SizedBox(),
                          Text(
                            "Buscar evento".tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Gilroy Medium',
                            ),
                          ),
                          const SizedBox()
                        ],
                      ),
                    ),
                    SizedBox(height: Get.height * 0.008),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Image.asset("image/search.png", height: height / 30),
                          SizedBox(width: width / 90),
                          Container(
                              width: 1,
                              height: height / 40,
                              color: Colors.grey),
                          SizedBox(width: width / 90),
                          //! ------ Search TextField -------
                          Container(
                            color: Colors.transparent,
                            height: height / 20,
                            width: width / 1.7,
                            child: TextField(
                              onChanged: (val) {
                                val.length != 0
                                    ? eventSearchApi(val)
                                    : eventSearchApi("a");
                              },
                              style: TextStyle(
                                  fontFamily: 'Gilroy Medium',
                                  color: Colors.white,
                                  fontSize: 15),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                hintText: "Buscar...".tr,
                                hintStyle: TextStyle(
                                    fontFamily: 'Gilroy Medium',
                                    color: const Color(0xffd2d2db),
                                    fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //SizedBox(height: Get.height * 0.0001),
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    child: content(),
                  ),
                  Container(
                    child: showSelectedConference(),
                  ),
                  Container(
                    child: barraDistancia(),
                  ),
                ],
              ),
            )
          ],
        )
        //content(),
        );
  }

  Widget content() {
  return FlutterMap(
    mapController: _mapController,
    options: MapOptions(
      initialCenter: LatLng(latD, longD), // Cambiado a center para que el mapa se centre en la ubicación actual
      initialZoom: 12,
      onPositionChanged: (position, hasGesture) {
        _updateCircleRadius(); // Actualizar el radio cuando cambia la posición o el zoom
      },
    ),
    children: [
      openStreetMapTileLater,
      MarkerLayer(
        markers: [
          // Marcador para la ubicación actual
          Marker(
            point: LatLng(latD, longD),
            width: 50, // Tamaño del marcador
            height: 50,
            child: GestureDetector(
              onTap: () {
                // Acción al tocar el marcador de la ubicación actual
                print('Ubicación actual: $latD, $longD');
              },
              child: Image.asset('image/CurrentLocationPin.png'), // Asegúrate de tener una imagen para el marcador de ubicación actual
            ),
          ),
          // Otros marcadores de eventos filtrados
          ...List.generate(eventosListFiltrados.length, (index) {
            return Marker(
              point: LatLng(
                eventosListFiltrados[index].latitud,
                eventosListFiltrados[index].longitud,
              ),
              width: isMarkerTappedList[index] ? 70 : 50,
              height: isMarkerTappedList[index] ? 70 : 50,
              child: GestureDetector(
                onTap: () {
                  toggleMarkerSelection(index);
                  setState(() {
                    selectedConference = eventosListFiltrados[index];
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 900),
                  width: isMarkerTappedList[index] ? 70 : 50,
                  height: isMarkerTappedList[index] ? 70 : 50,
                  child: Image.asset('image/Pin.png'),
                ),
              ),
            );
          }),
        ],
      ),
      CircleLayer(
        circles: [
          CircleMarker(
            point: LatLng(latD, longD),
            radius: _circleRadius, // Radio en píxeles, se actualiza con el zoom
            color: Colors.blue.withOpacity(0.3), // Color del área del radio
            borderStrokeWidth: 2,
            borderColor: Colors.blue,
          ),
        ],
      ),
    ],
  );
}



  Widget barraDistancia() {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Text(
            'Distancia: ${_currentSliderValue.toStringAsFixed(1)} km',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              fontFamily: 'Gilroy Medium',
            ),
          ),
          Slider(
            value: _currentSliderValue,
            min: 1,
            max: 50, // Rango de kilómetros
            divisions: 100, // Número de divisiones (1 división = 1 km)
            label: _currentSliderValue.round().toString(),
            onChanged: (double value) {
              setState(() {
                onSliderValueChanged(value); // Recalcular el radio cuando cambia el valor del deslizador
              });
            },
          ),
        ],
      ),
    );
  }

  Widget conference(Evento selectedEvent) {
    return Positioned(
      left: 5,
      right: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
            Get.to(
                () => EventsDetails(
                    eid: selectedEvent.id.toString(), evento: selectedEvent),
                duration: Duration.zero);
            /*Future.delayed(Duration(seconds: 1), () {
            Get.to(
                () => EventsDetails(eid: selectedEvent.id.toString(), evento: selectedEvent),
                duration: Duration.zero);
            // Aquí puedes navegar a una nueva pantalla pasando los datos del evento seleccionado
            // En este ejemplo, simplemente imprimo los datos del evento seleccionado en la consola
            print("Evento seleccionado: ${selectedEvent.id}, ${selectedEvent.tituloEvento}, ${selectedEvent.direccionEvento}");
          });
          */
          },
          child: Container(
            width: width, // Ancho del contenedor
            height: height /
                5, // Altura del contenedor (puedes ajustarlo según tus necesidades)
            margin: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: notifire.containercolore,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: notifire.bordercolore),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 8, right: 6, bottom: 5, top: 10),
              child: Row(
                children: [
                  Container(
                    width: width / 5,
                    height: height / 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: Image.network(
                        'http://216.225.205.93:3000${selectedEvent.imagenEvento}',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedEvent.fechaInicio,
                          style: TextStyle(
                            fontFamily: 'Gilroy Medium',
                            color: const Color(0xff4A43EC),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          selectedEvent.tituloEvento,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Gilroy Medium',
                            color: notifire.textcolor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Image.asset("image/location.png", height: 20),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                selectedEvent.direccionEvento,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Gilroy Medium',
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PageController pageController = PageController();
  updateMapPosition({int? index}) {
    pageController.animateToPage(index ?? 0,
        duration: Duration(seconds: 1), curve: Curves.decelerate);
    setState(() {});
  }
}

TileLayer get openStreetMapTileLater => TileLayer(
    //urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png', //mapa blanco
    //urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',  //mapa negro
    //urlTemplate: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png', //mapa feo
    urlTemplate:
        'https://tile.openstreetmap.org/{z}/{x}/{y}.png', //mapa estandar
    userAgentPackageName: 'com.goevent');

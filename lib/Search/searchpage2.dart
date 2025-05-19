// ignore_for_file: file_names, avoid_print, prefer_const_constructors, prefer_is_empty

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goevent2/Api/ApiWrapper.dart';
import 'package:goevent2/Api/Config.dart';
import 'package:goevent2/AppModel/Homedata/HomedataController.dart';
import 'package:goevent2/home/EventDetails.dart';
import 'package:goevent2/home/Evento.dart';
import 'package:goevent2/utils/AppWidget.dart';
import 'package:goevent2/utils/MunicipiosComboBox.dart';
import 'package:goevent2/utils/colornotifire.dart';
import 'package:goevent2/utils/media.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

//! Done
class SearchPage2 extends StatefulWidget {
  final String? type;
  const SearchPage2({Key? key, this.type}) : super(key: key);

  @override
  State<SearchPage2> createState() => _SearchPage2State();
}

class _SearchPage2State extends State<SearchPage2> {
  late ColorNotifire notifire;

  List<Evento> allEvent = [];
  List<Evento> filteredEvent = [];
  bool isLoading = true;

  //Elements for LazyLoading
  ScrollController _scrollController = ScrollController();
  int _offset = 0;
  final int _limit = 10;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  //filters
  int? _selectedMunicipio;

  @override
  void initState() {
    super.initState();
    getdarkmodepreviousstate();
    cargarMasEventos();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        cargarMasEventos();
      }
    });
  }

  Future<void> cargarEventos() async {
    EventosService service = EventosService();
    try {
      List<Evento> eventos = await service.cargarEventos(limit: _limit);
      setState(() {
        allEvent = eventos
          ..sort((a, b) => a.tituloEvento.toLowerCase().compareTo(
              b.tituloEvento.toLowerCase())); // Ordena alfabéticamente
        filteredEvent = allEvent; // Inicialmente muestra todos los eventos
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar los eventos: $e');
    }
  }

  Future<void> cargarMasEventos() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      List<Evento> nuevosEventos = await EventosService().cargarEventos(
          offset: _offset, limit: _limit, idMunicipio: _selectedMunicipio);

      if (nuevosEventos.isEmpty) {
        _hasMore = false;
      } else {
        setState(() {
          print("Agregando más eventos");
          allEvent.addAll(nuevosEventos);
          filteredEvent.addAll(nuevosEventos);
        });
      }

      _offset += _limit; // Always increment
    } catch (e) {
      print('Error al cargar más eventos: $e');
    } finally {
      setState(() {
        _isLoadingMore = false;
        print("Terminó de cargar eventos");
      });
    }
  }

  void eventSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredEvent =
            allEvent; // Muestra todos los eventos si la búsqueda está vacía
      } else {
        filteredEvent = allEvent
            .where((evento) =>
                evento.tituloEvento.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void openFilterModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int? idSelectedMunicipio;

        return AlertDialog(
          backgroundColor: notifire.backgrounde,
          title: Text(
            'Filter events'.tr,
            style: TextStyle(color: notifire.textcolor),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: MunicipiosComboBox(
                    labelColor: Colors.grey,
                    textColor: notifire.getwhitecolor,
                    onChanged: (value) {
                      setState(() {
                        idSelectedMunicipio = int.parse(value);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel'.tr,
                style: TextStyle(color: notifire.textcolor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
              ),
              child: Text(
                'Apply'.tr,
                style: TextStyle(color: notifire.textcolor),
              ),
              onPressed: () {
                print('Selected municipio: $idSelectedMunicipio');
                // TODO: Update API query or filtering logic based on these values
                //Restart the offset and fetch events.
                _selectedMunicipio = idSelectedMunicipio;
                _offset = 0;
                _hasMore = true;
                allEvent.clear(); // Clear previous results
                filteredEvent.clear(); // Clear filtered list too
                isLoading = true;

                cargarMasEventos();

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    notifire.setIsDark = previusstate;
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.backgrounde,
      body: Column(
        children: [
          Container(
            height: Get.height * 0.15,
            width: double.infinity,
            decoration: BoxDecoration(
                color: notifire.homecontainercolore,
                borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
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
                          "Search".tr,
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
                            width: 1, height: height / 40, color: Colors.grey),
                        SizedBox(width: width / 90),
                        //! ------ Search TextField -------
                        Container(
                          color: Colors.transparent,
                          height: height / 20,
                          width: width / 1.7,
                          child: TextField(
                            onChanged: (val) {
                              eventSearch(val);
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
                              hintText: "Search...".tr,
                              hintStyle: TextStyle(
                                  fontFamily: 'Gilroy Medium',
                                  color: const Color(0xffd2d2db),
                                  fontSize: 15),
                            ),
                          ),
                        ),
                        //! Filter Button
                        IconButton(
                          icon: Icon(Icons.filter_alt_outlined,
                              color: Colors.white),
                          onPressed: () {
                            openFilterModal();
                          },
                        ),
                        if (_selectedMunicipio != null)
                        Expanded(
                          child: IconButton(
                            icon: Icon(Icons.clear, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _selectedMunicipio = null;
                                _offset = 0;
                                _hasMore = true;
                                allEvent.clear();
                                filteredEvent.clear();
                                isLoading = true;
                              });
                              cargarMasEventos();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: Get.height * 0.01),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              itemCount: filteredEvent.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i < filteredEvent.length) {
                  return conference(filteredEvent[i], i);
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget conference(Evento evento, int i) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          Future.delayed(Duration(seconds: 1), () {
            Get.to(
                () => EventsDetails(eid: evento.id.toString(), evento: evento),
                duration: Duration.zero);
          });
        },
        child: Container(
          width: width,
          margin: EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
              color: notifire.containercolore,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: notifire.bordercolore)),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 8, right: 6, bottom: 5, top: 5),
            child: Row(children: [
              Container(
                  width: width / 5,
                  height: height / 8,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: FadeInImage.assetNetwork(
                        fadeInCurve: Curves.easeInCirc,
                        placeholder: "image/skeleton.gif",
                        fit: BoxFit.cover,
                        image:
                            'http://216.225.205.93:3000${evento.imagenEvento}'),
                  )),
              Column(children: [
                SizedBox(height: height / 200),
                Row(
                  children: [
                    SizedBox(width: width / 50),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            evento.fechaInicio,
                            style: TextStyle(
                                fontFamily: 'Gilroy Medium',
                                color: const Color(0xff4A43EC),
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: Get.height * 0.01),
                          SizedBox(
                            width: Get.width * 0.60,
                            child: Text(
                              evento.tituloEvento,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: 'Gilroy Medium',
                                  color: notifire.textcolor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(height: Get.height * 0.01),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset("image/location.png",
                                    height: height / 50),
                                SizedBox(width: Get.width * 0.01),
                                SizedBox(
                                  width: Get.width * 0.55,
                                  child: Text(
                                    evento.direccionEvento,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Gilroy Medium',
                                        color: Colors.grey,
                                        fontSize: 13),
                                  ),
                                ),
                              ]),
                        ]),
                  ],
                ),
                SizedBox(height: height / 80),
              ])
            ]),
          ),
        ),
      ),
    );
  }
}

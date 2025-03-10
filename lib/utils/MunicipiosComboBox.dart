import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'colornotifire.dart';
import 'ctextfield.dart';

class MunicipiosComboBox extends StatefulWidget {
  final Function(String)? onChanged;
  final Color labelColor;
  final Color textColor;

  const MunicipiosComboBox({
    Key? key,
    this.onChanged,
    required this.labelColor,
    required this.textColor,
  }) : super(key: key);

  @override
  _MunicipiosBoxState createState() => _MunicipiosBoxState();
}

class _MunicipiosBoxState extends State<MunicipiosComboBox> {
  String? _selectedmunicipiosId;
  List<dynamic> _municipiosList = [];
  late ColorNotifire notifire;

  @override
  void initState() {
    super.initState();
    cargarMunicipiosApi();
    getdarkmodepreviousstate();
  }

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    notifire.setIsDark = previusstate;
  }

  void cargarMunicipiosApi() async {
    String apiUrl = 'http://216.225.205.93:3000/api/municipios';

    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      print('todo bien');

      if (jsonResponse is Map && jsonResponse['municipios'] is List) {
        setState(() {
          _municipiosList = jsonResponse['municipios'];
          print(_municipiosList);

          //Commented if to stop autocompleting the municipality list

          // if (_municipiosList.isNotEmpty) {
          //   _selectedmunicipiosId = _municipiosList.first['id'].toString();
          // }
        });
      } else {
        print('Error: La respuesta no contiene una lista de Municipios.');
      }
    } else {
      print('Error al cargar Municipios: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Municipality".tr,
          style: TextStyle(
            color: widget.labelColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        DropdownButtonFormField<String>(
          value: _selectedmunicipiosId,
          hint: Text(
            "Select municipality".tr,
          ),
          onChanged: (value) {
            setState(() {
              _selectedmunicipiosId = value;
              if (widget.onChanged != null) {
                widget.onChanged!(value!);
              }
            });
          },
          dropdownColor: notifire.getcardcolor,
          decoration: const InputDecoration(),
          items: _municipiosList.map<DropdownMenuItem<String>>((municipio) {
            
            return DropdownMenuItem<String>(
              value: municipio['id'].toString(),
              child: SizedBox(
                width: 300,
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        municipio['nombre'] ?? '',
                        style: TextStyle(color: widget.textColor),
                        overflow: TextOverflow.visible,
                        maxLines: null,
                      ),
                    ),
                  ],
                ),
              ),
              
            );
          }).toList(),
        ),
      ],
    );
  }
}

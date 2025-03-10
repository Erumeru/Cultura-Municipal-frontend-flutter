import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'colornotifire.dart';
import 'ctextfield.dart';

class CustomComboBox extends StatefulWidget {
  final Function(String)? onChanged;
  final Color labelColor;
  final Color textColor;

  const CustomComboBox({
    Key? key,
    this.onChanged,
    required this.labelColor,
    required this.textColor,
  }) : super(key: key);

  @override
  _CustomComboBoxState createState() => _CustomComboBoxState();
}

class _CustomComboBoxState extends State<CustomComboBox> {
  String? _selectedCategoriaId;
  List<dynamic> _categoriasList = [];
  late ColorNotifire notifire;

  @override
  void initState() {
    super.initState();
    cargarCategoriasApi();
    getdarkmodepreviousstate();
  }

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    notifire.setIsDark = previusstate;
  }

  void cargarCategoriasApi() async {
    String apiUrl = 'http://216.225.205.93:3000/api/categorias';
    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(utf8.decode(response.bodyBytes));

      if (jsonResponse is Map && jsonResponse['categorias'] is List) {
        setState(() {
          _categoriasList = jsonResponse['categorias'];

          //Commented if to stop autocompleting the categories list

          // if (_categoriasList.isNotEmpty) {
          //   _selectedCategoriaId = _categoriasList.first['id'].toString();
          // }
        });
      } else {
        print('Error: La respuesta no contiene una lista de categorías.');
      }
    } else {
      print('Error al cargar categorías: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Category list".tr,
          style: TextStyle(
            color: widget.labelColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        DropdownButtonFormField<String>(
          value: _selectedCategoriaId,
          onChanged: (value) {
            setState(() {
              _selectedCategoriaId = value;
              if (widget.onChanged != null) {
                widget.onChanged!(value!);
              }
            });
          },
          hint: Text(
            "Select category".tr,
          ),
          dropdownColor: notifire.getcardcolor,
          decoration: const InputDecoration(),
          items: _categoriasList.map<DropdownMenuItem<String>>((categoria) {
            return DropdownMenuItem<String>(
              value: categoria['id'].toString(),
              child: SizedBox(
                width: 300,
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        categoria['nombre'] ?? '',
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

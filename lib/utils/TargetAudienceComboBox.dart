import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'colornotifire.dart';
import 'ctextfield.dart';

class TargetAudienceComboBox extends StatefulWidget {
  final Function(String)? onChanged;
  final Color labelColor;
  final Color textColor;

  const TargetAudienceComboBox({
    Key? key,
    this.onChanged,
    required this.labelColor,
    required this.textColor,
  }) : super(key: key);

  @override
  _TargetAudienceBoxState createState() => _TargetAudienceBoxState();
}

class _TargetAudienceBoxState extends State<TargetAudienceComboBox> {
  String? _selectedAudienceId;
  List<dynamic> _audienceList = [];
  late ColorNotifire notifire;

  @override
  void initState() {
    super.initState();
    cargarTargetAudienceApi();
    getdarkmodepreviousstate();
  }

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    notifire.setIsDark = previusstate;
  }

  void cargarTargetAudienceApi() async {
    String apiUrl = 'http://216.225.205.93:3000/api/publico-objetivo';

    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      print('todo bien');

      if (jsonResponse is Map && jsonResponse['publicosObjetivos'] is List) {
        setState(() {
          _audienceList = jsonResponse['publicosObjetivos'];
          print(_audienceList);

          //Commented if to stop autocompleting the Target audience list

          // if (_audienceList.isNotEmpty) {
          //   _selectedAudienceId = _audienceList.first['id'].toString();
          // }
        });
      } else {
        print('Error: La respuesta no contiene una lista de publico.');
      }
    } else {
      print('Error al cargar publico: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Target audience".tr,
          style: TextStyle(
            color: widget.labelColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        DropdownButtonFormField<String>(
          value: _selectedAudienceId,
          onChanged: (value) {
            setState(() {
              _selectedAudienceId = value;
              if (widget.onChanged != null) {
                widget.onChanged!(value!);
              }
            });
          },
          dropdownColor: notifire.getcardcolor,
          decoration: const InputDecoration(),
          hint: Text(
            "Select target audience".tr,
          ),
          items: _audienceList.map<DropdownMenuItem<String>>((audiencia) {
            return DropdownMenuItem<String>(
              value: audiencia['id'].toString(),
              child: SizedBox(
                width: 300,
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        audiencia['nombre'] ?? '',
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



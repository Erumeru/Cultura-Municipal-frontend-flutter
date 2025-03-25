import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'colornotifire.dart';

class CustomDatePickerTextField extends StatelessWidget {
  final TextEditingController controller;
  final String name1;
  final Color labelclr;
  final Color textcolor;
  final String iconImagePath; // Ruta de la imagen del icono
  final Function(String)? onChanged;

  const CustomDatePickerTextField({
    Key? key,
    required this.controller,
    required this.name1,
    required this.labelclr,
    required this.textcolor,
    required this.iconImagePath,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifire = Provider.of<ColorNotifire>(context, listen: true);
    return GestureDetector(
      onTap: () {
        _selectDate(context);
      },
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: notifire.bordercolore, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset( // Utilizar Image.asset para mostrar la imagen
                iconImagePath,
                //color: labelclr, // Puedes aplicar el color si es necesario
                width: 24, // Ajusta el ancho según sea necesario
                height: 24, // Ajusta la altura según sea necesario
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    controller.text.isNotEmpty ? controller.text : name1,
                    style: TextStyle(color: textcolor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {


    final DateTime? pickedDate = await showDatePicker(
      locale: Get.locale,
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

      // Actualizar el valor del controlador
      controller.text = formattedDate;

      // Llamar a la función onChanged si está definida
      if (onChanged != null) {
        onChanged!(formattedDate);
      }
    }
  }
}



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'colornotifire.dart';

class CustomTimePickerTextField extends StatelessWidget {
  final TextEditingController controller;
  final String name1;
  final Color labelclr;
  final Color textcolor;
  final String iconImagePath;
  final Function(String)? onChanged;

  const CustomTimePickerTextField({
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

    return Container(
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: notifire.bordercolore, width: 1),
      ),
      child: InkWell(
        onTap: () {
          _selectTime(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                // Utilizar Image.asset para mostrar la imagen
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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
      return Localizations.override(
        context: context,
        locale:  Locale(Get.locale!.languageCode , 'US') ?? Locale('en', 'US'), // ✅ Apply the correct locale
        child: MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false), child: child!),
      );
    },
    );

    if (pickedTime != null) {
      String formattedTime = DateFormat.Hm().format(DateTime(
        2022, // Año, puedes cambiarlo según tus necesidades
        1, // Mes
        1, // Día
        pickedTime.hour,
        pickedTime.minute,
      ));

      // Actualizar el valor del controlador
      controller.text = formattedTime;

      // Llamar a la función onChanged si está definida
      if (onChanged != null) {
        onChanged!(formattedTime);
      }
    }
  }
}

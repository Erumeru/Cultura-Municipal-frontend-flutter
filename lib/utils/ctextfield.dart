import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'colornotifire.dart';


late ColorNotifire notifire;

class Customtextfild {
  static Widget textField({
    required context,
    TextEditingController? controller,
    String? name1,
    Color? labelclr,
    Color? textcolor,
    Color? imagecolor,
    String? Function(String?)? validator,
    Widget? prefixIcon,
    Function(String)? onChanged,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool readOnly = false,
  }) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Container(
      color: Colors.transparent,
      // Elimina la altura fija
      // height: 45,
      child: TextFormField(
        
        controller: controller,
        onChanged: onChanged,
        validator: validator,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        readOnly: readOnly,
        style: TextStyle(color: textcolor),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          disabledBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          labelText: name1,
          labelStyle: TextStyle(color: labelclr),
          prefixIcon: prefixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: notifire.bordercolore, width: 1),
              borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xff5669FF), width: 1),
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

class CustomTextArea {
  static Widget textArea({
    required BuildContext context,
    TextEditingController? controller,
    String? name1,
    Color? labelclr,
    Color? textcolor,
    Color? imagecolor,
    String? Function(String?)? validator,
    Widget? prefixIcon,
    Function(String)? onChanged,
    bool readOnly = false,
  }) {
    ColorNotifire notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: notifire.bordercolore, width: 1),
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          TextFormField(
            controller: controller,
            onChanged: onChanged,
            validator: validator,
            maxLines: null, // Permite múltiples líneas
            maxLength: 1000, // Límite de 70 caracteres
            keyboardType: TextInputType.multiline,
            readOnly: readOnly,
            style: TextStyle(color: textcolor),
            decoration: InputDecoration(
              hintText: name1,
              hintStyle: TextStyle(color: labelclr),
              border: InputBorder.none, // Sin bordes
              prefixIcon: prefixIcon,
            ),
          ),

        ],
      ),
    );
  }
}

class CustomShortTextArea {
  static Widget textArea({
    required BuildContext context,
    TextEditingController? controller,
    String? name1,
    Color? labelclr,
    Color? textcolor,
    Color? imagecolor,
    String? Function(String?)? validator,
    Widget? prefixIcon,
    Function(String)? onChanged,
    bool readOnly = false,
  }) {
    ColorNotifire notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: notifire.bordercolore, width: 1),
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          TextFormField(
            controller: controller,
            onChanged: onChanged,
            validator: validator,
            maxLines: null, // Permite múltiples líneas
            maxLength: 100, // Límite de 70 caracteres
            keyboardType: TextInputType.multiline,
            readOnly: readOnly,
            style: TextStyle(color: textcolor),
            decoration: InputDecoration(
              hintText: name1,
              hintStyle: TextStyle(color: labelclr),
              border: InputBorder.none, // Sin bordes
              prefixIcon: prefixIcon,
            ),
          ),

        ],
      ),
    );
  }
}


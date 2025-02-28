import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class CustomImageGallery extends StatefulWidget {
  final List<String?> imagePaths;
  final Color labelclr;
  final Color textcolor;
  final String iconImagePath;
  final BuildContext context;

  const CustomImageGallery({
    Key? key,
    required this.imagePaths,
    required this.labelclr,
    required this.textcolor,
    required this.iconImagePath,
    required this.context,
  }) : super(key: key);

  @override
  _CustomImageGalleryState createState() => _CustomImageGalleryState();
}

class _CustomImageGalleryState extends State<CustomImageGallery> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image Gallery'.tr,
          style: TextStyle(
            color: widget.labelclr,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10.0),
        Row(
          children: List.generate(
            widget.imagePaths.length < 3 ? widget.imagePaths.length + 1 : 3,
            (index) {
              if (index == widget.imagePaths.length) {
                return GestureDetector(
                  onTap: () {
                    _selectImage(context);
                  },
                  child: Container(
                    width: 80.0,
                    height: 80.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 40.0,
                      color: widget.labelclr,
                    ),
                  ),
                );
              } else {
                return Stack(
                  children: [
                    Container(
                      width: 80.0,
                      height: 80.0,
                      margin: const EdgeInsets.only(right: 10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: widget.imagePaths[index] != null
                          ? Image.memory(
                              base64Decode(widget.imagePaths[index]!.split(',')[1]),
                              fit: BoxFit.cover,
                            )
                          : Container(), // Empty container for null images
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            widget.imagePaths.removeAt(index);
                          });
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> _selectImage(BuildContext context) async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image != null) {
        // Redimensionar la imagen a un tamaño más pequeño
        img.Image resizedImage = img.copyResize(image, width: 500); // Ajusta el tamaño según sea necesario
        final resizedBytes = img.encodePng(resizedImage, level: 9); // Usa nivel de compresión máximo
        final base64Image = 'data:image/png;base64,${base64Encode(resizedBytes)}';

        setState(() {
          if (widget.imagePaths.length < 4) {
            widget.imagePaths.add(base64Image);
          }
        });
      }
    }
    while (widget.imagePaths.length < 4) {
      widget.imagePaths.add(null);
    }
  }

}


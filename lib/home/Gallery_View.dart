// ignore_for_file: file_names, avoid_print, must_be_immutable, avoid_function_literals_in_foreach_calls, use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/colornotifire.dart';

class GalleryView extends StatefulWidget {
  List? list;
  GalleryView({this.list, Key? key}) : super(key: key);

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  List eventList = [];
  late ColorNotifire notifire;

  @override
  void initState() {
    eventList = widget.list ?? [];

    print("!!!!!!!!!!!!!!!!$eventList");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.backgrounde,
      appBar: AppBar(
          centerTitle: true,
          leading: BackButton(color: notifire.textcolor),
          elevation: 0,
          backgroundColor: notifire.backgrounde,
          title: Text(
            "Gallery",
            style: TextStyle(
                fontFamily: "Gilroy Bold", fontSize: 16, color: notifire.textcolor),
          )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 150,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: eventList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return FullScreenImage(
                            imageUrl: eventList[index], // Usar directamente la ruta de la imagen estática
                            tag: "imagen $index",
                          );
                        }));
                      },

                      /*
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return FullScreenImage(
                            imageUrl: Config.base_url + eventList[index],
                            tag: "generate_a_unique_tag",
                          );
                        }));
                      },

                       */
                      child: Hero(
                        tag: "generate_a_unique_tag",
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: 


                          Image.network(
                            'http://216.225.205.93:3000${eventList[index]}',
                            fit: BoxFit.cover,
                          ),

                        ),
                      ),
                      /*
                      child: Hero(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            Config.base_url + eventList[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                        tag: "generate_a_unique_tag",
                      ),

                       */
                    );
                  },
                ))
          ],
        ),
      ),
    );
  }
}


class FullScreenImage extends StatelessWidget {
  final String? imageUrl;
  final String? tag;

  const FullScreenImage({required this.imageUrl, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: tag!,
            child: Image.network(
              'http://216.225.205.93:3000${imageUrl!}',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.contain,
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}




/*
class FullScreenImage extends StatelessWidget {
  String? imageUrl;
  String? tag;

  FullScreenImage({this.imageUrl, this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: tag!,
            child: CachedNetworkImage(
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.contain,
              imageUrl: imageUrl!,
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

 */

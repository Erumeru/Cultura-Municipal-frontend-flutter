import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goevent2/Api/ApiWrapper.dart';
import 'package:goevent2/Controller/AuthController.dart';
import 'package:goevent2/home/EventDetails.dart';
import 'package:goevent2/home/Evento.dart';
import 'package:goevent2/spleshscreen.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async'; // for StreamSubscription

class DeepLinkHandler extends StatefulWidget {
  @override
  _DeepLinkHandlerState createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    initUniLinks();
  }

  Future<void> initUniLinks() async {
    // Handle app started from a deep link (cold start)
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      print('Failed to get initial link: $e');
    }

    // Handle app opened from background
    _sub = linkStream.listen((String? link) {
      if (link != null) {
        _handleDeepLink(link);
      }
    }, onError: (err) {
      print('Error listening to linkStream: $err');
    });
  }

  void _handleDeepLink(String link) async {
    print('Deep link received: $link');

    Uri uri = Uri.parse(link);

    if (uri.host == "assetsjosntest.web.app") {
      if (await AuthController().isSessionOpen()) {
        if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == "evento") {
          int? eventId = int.tryParse(uri.pathSegments[1]);
          if (eventId != null) {
            try {
              Evento event = await EventosService().buscarEventoPorId(eventId);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventsDetails(
                    eid: event.id.toString(),
                    evento: event,
                  ),
                ),
              );
            } on Exception catch (_) {
              ApiWrapper.showToastMessage("The event doesn't exists".tr);
            }
          } else {
            ApiWrapper.showToastMessage('Invalid event ID'.tr);
          }
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Spleshscreen(),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Listening for links...')),
    );
  }
}

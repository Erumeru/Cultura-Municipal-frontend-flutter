// deepLinkHandler.dart
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goevent2/Api/ApiWrapper.dart';
import 'package:goevent2/Controller/AuthController.dart';
import 'package:goevent2/home/EventDetails.dart';
import 'package:goevent2/home/Evento.dart';
import 'package:goevent2/spleshscreen.dart';
import 'package:goevent2/utils/globals.dart';

class DeepLinkHandler extends StatefulWidget {
  const DeepLinkHandler({Key? key}) : super(key: key);

  @override
  _DeepLinkHandlerState createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  late AppLinks _appLinks;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initDeepLinking();
  }

  Future<void> _initDeepLinking() async {
    if (_isInitialized) return;

    _appLinks = AppLinks();

    // Handle app start from deep link
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }

      // Handle deep links while app is running
      _appLinks.uriLinkStream.listen(
        (Uri? uri) {
          if (uri != null) {
            _handleDeepLink(uri);
          }
        },
        onError: (err) {
          debugPrint('Deep link error: $err');
        },
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('Deep linking initialization error: $e');
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    debugPrint('Deep link received: $uri');

    try {
      if (uri.host == "assetsjosntest.web.app") {
        if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == "evento") {
          // Check authentication
          final bool isAuthenticated = await AuthController().isSessionOpen();
          
          if (!isAuthenticated) {
            Get.offAll(() => const Spleshscreen());
            return;
          }

          // Handle event deep link
          if (uri.pathSegments.length > 1) {
            final String eventIdStr = uri.pathSegments[1];
            final int? eventId = int.tryParse(eventIdStr);

            if (eventId != null) {
              try {
                final Evento event = await EventosService().buscarEventoPorId(eventId);
                deepLinkHandled= true;
                Get.to(
                  () => EventsDetails(
                    eid: event.id.toString(),
                    evento: event,
                  ),
                );
              } catch (e) {
                ApiWrapper.showToastMessage("The event doesn't exist".tr);
                debugPrint('Error fetching event: $e');
              }
            } else {
              ApiWrapper.showToastMessage('Invalid event ID'.tr);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error handling deep link: $e');
      ApiWrapper.showToastMessage('Error processing the link'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

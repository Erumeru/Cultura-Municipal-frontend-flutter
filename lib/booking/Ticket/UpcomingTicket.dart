// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables, file_names, prefer_const_constructors

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goevent2/Api/ApiWrapper.dart';
import 'package:goevent2/Api/Config.dart';
import 'package:goevent2/AppModel/Homedata/HomedataController.dart';
import 'package:goevent2/Bottombar.dart';
import 'package:goevent2/Controller/AuthController.dart';
import 'package:goevent2/booking/Ticket/TicketDetails.dart';
import 'package:goevent2/utils/AppWidget.dart';
import 'package:goevent2/utils/CustomImageGallery.dart';
import 'package:goevent2/utils/color.dart';
import 'package:goevent2/utils/colornotifire.dart';
import 'package:goevent2/utils/media.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/CustomComboBox.dart';
import '../../utils/CustomDatePickerTextField.dart';
import '../../utils/CustomImagePicker.dart';
import '../../utils/CustomTimePickerTextField.dart';
import '../../utils/CustomPriceInput.dart';
import '../../utils/MunicipiosComboBox.dart';
import '../../utils/TargetAudienceComboBox.dart';
import 'SelectLocation.dart';

import '../../profile/loream.dart';
import '../../utils/botton.dart';
import '../../utils/ctextfield.dart';

// Done
class UpcomingTicket extends StatefulWidget {
  const UpcomingTicket({Key? key}) : super(key: key);

  @override
  _UpcomingTicketState createState() => _UpcomingTicketState();
}

class _UpcomingTicketState extends State<UpcomingTicket> {
  final evento = Get.put(AuthController());
  var selectedRadioTile;
  final note = TextEditingController();
  String? rejectmsg = '';
  List orderdata = [];
  List<String> event_gallery = [];
  List<dynamic> event_sponsore = [];
  bool isLoading = false;

  bool verificar = false;

  List<String> pathEventImage = [];
  List<String> pathCoverImage = [];

  late ColorNotifire notifire;
  final event_title = TextEditingController();

  final cid = TextEditingController();

  final event_address_title = TextEditingController();

  final event_address = TextEditingController();

  late TextEditingController end_dateController;

  late String end_date;

  late TextEditingController start_dateController;
  late String start_date;

  final start_time = TextEditingController();
  final end_time = TextEditingController();
  final event_about = TextEditingController();
  final event_about_short = TextEditingController();
  final price = TextEditingController();
  final lat = TextEditingController();
  final long = TextEditingController();
  final target_audience = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final municipio = TextEditingController();

  final Event_sponsore = TextEditingController();
  final Event_gallery = TextEditingController();

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    notifire.setIsDark = previusstate;
  }

  @override
  void initState() {
    super.initState();
    ticketStatusApi();
    getdarkmodepreviousstate();
    start_dateController = TextEditingController();
    start_date = ''; // Inicializa la fecha vacía
    end_dateController = TextEditingController();
    end_date = '';
    bool verificar = false; // Inicializa la fecha vacía
  }

  @override
  void dispose() {
    start_dateController.dispose();
    end_dateController.dispose();
    super.dispose();
  }

  ticketStatusApi() {
    setState(() {
      isLoading = true;
    });
    var data = {"uid": uID, "status": "Booked"};
    print("Api Call type price: :$data");
    ApiWrapper.dataPost(Config.ticketStatus, data).then((val) {
      print("Api Call type price: :$val");

      setState(() {});
      if ((val != null) && (val.isNotEmpty)) {
        if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
          setState(() {});
          print(val);
          orderdata = val["order_data"];
          setState(() {
            isLoading = false;
          });
        } else {
          setState(() {
            orderdata = [];
            isLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.backgrounde,
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height / 40),
                CustomComboBox(
                  labelColor: Colors.grey,
                  textColor: notifire.getwhitecolor,
                  onChanged: (value) {
                    setState(() {
                      cid.text = value;
                    });
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 40),
                TargetAudienceComboBox(
                  labelColor: Colors.grey,
                  textColor: notifire.getwhitecolor,
                  onChanged: (value) {
                    setState(() {
                      target_audience.text = value;
                    });
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 40),
                Customtextfild.textField(
                  controller: event_title,
                  name1: "Event title".tr,
                  labelclr: Colors.grey,
                  textcolor: notifire.getwhitecolor,
                  prefixIcon: Image.asset(
                    "image/evento.png",
                    scale: 3.5,
                  ),
                  context: context,
                ),

                buildEmptyFieldWarning(event_title, verificar),

                SizedBox(height: MediaQuery.of(context).size.height / 40),

                CustomShortTextArea.textArea(
                  controller: event_about_short,
                  name1: "Short description".tr,
                  labelclr: Colors.grey,
                  textcolor: notifire.getwhitecolor,
                  prefixIcon: Image.asset(
                    "image/descripcion.png",
                    scale: 3.5,
                    //color: notifire.textcolor
                  ),
                  context: context,
                ),
                buildEmptyFieldWarning(event_about_short, verificar),
                SizedBox(
                    height: MediaQuery.of(context).size.height /
                        40), // Ajustar altura según necesidad
                CustomTextArea.textArea(
                  controller: event_about,
                  name1: "Description".tr,
                  labelclr: Colors.grey,
                  textcolor: notifire.getwhitecolor,
                  prefixIcon: Image.asset(
                    "image/descripcion.png",
                    scale: 3.5,
                    //color: notifire.textcolor
                  ),
                  context: context,
                ),
                buildEmptyFieldWarning(event_about, verificar),
                SizedBox(
                    height: MediaQuery.of(context).size.height /
                        40), // Ajustar altura según necesidad

                CustomDatePickerTextField(
                  controller: start_dateController,
                  name1: "Start date".tr,
                  labelclr: Colors.grey,
                  textcolor: notifire.getwhitecolor,
                  iconImagePath: 'image/Calendar.png',
                  onChanged: (value) {
                    setState(() {
                      start_dateController.text = value;
                    });
                  },
                ),
                buildEmptyFieldWarning(start_dateController, verificar),

                SizedBox(height: MediaQuery.of(context).size.height / 40),
                CustomDatePickerTextField(
                  controller: end_dateController,
                  name1: "End date".tr,
                  labelclr: Colors.grey,
                  textcolor: notifire.getwhitecolor,
                  iconImagePath: 'image/Calendar.png',
                  onChanged: (value) {
                    setState(() {
                      end_dateController.text = value;
                    });
                  },
                ),
                buildEmptyFieldWarning(end_dateController, verificar),
                SizedBox(height: MediaQuery.of(context).size.height / 40),
                CustomTimePickerTextField(
                  controller: start_time,
                  name1: "Start Time".tr,
                  labelclr: Colors.grey,
                  textcolor: notifire.getwhitecolor,
                  iconImagePath: "image/time.png",
                  onChanged: (value) {
                    setState(() {
                      start_time.text = value;
                    });
                  },
                ),
                buildEmptyFieldWarning(start_time, verificar),

                SizedBox(height: MediaQuery.of(context).size.height / 40),
                CustomTimePickerTextField(
                  controller: end_time,
                  name1: "End Time".tr,
                  labelclr: Colors.grey,
                  textcolor: notifire.getwhitecolor,
                  iconImagePath: "image/time.png",
                  onChanged: (value) {
                    setState(() {
                      end_time.text = value;
                    });
                  },
                ),
                buildEmptyFieldWarning(end_time, verificar),
                SizedBox(height: MediaQuery.of(context).size.height / 40),
                CustomPriceInput(
                  controller: price,
                  name: "Price".tr,
                  labelclr: Colors.grey,
                  textcolor: notifire.getwhitecolor,
                  iconImagePath: "image/dolar.png",
                  context: context,
                ),
                buildEmptyFieldWarning(price, verificar),
                SizedBox(height: MediaQuery.of(context).size.height / 40),

                CustomImagePicker(
                  imagePaths:
                      pathCoverImage, // Lista de rutas de imágenes, puedes inicializarla con las imágenes existentes
                  name: "Event Cover".tr,
                  labelclr: Colors.grey,
                  textcolor: notifire.getwhitecolor,
                  iconImagePath: "image/imagen_icon.png",
                  context: context,
                ),

                SizedBox(height: MediaQuery.of(context).size.height / 60),

                CustomImagePicker(
                  imagePaths:
                      pathEventImage, // Lista de rutas de imágenes, puedes inicializarla con las imágenes existentes
                  name: "Event Image".tr,
                  labelclr: Colors.grey,
                  textcolor: notifire.getwhitecolor,
                  iconImagePath: "image/imagen_icon.png",
                  context: context,
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 60),
                CustomImageGallery(
                  imagePaths:
                      event_gallery, // Lista de rutas de imágenes, puedes inicializarla con las imágenes existentes
                  labelclr: Colors.grey,
                  textcolor: notifire.getwhitecolor,
                  iconImagePath: "image/galeria.png",
                  context: context,
                ),

                SizedBox(height: MediaQuery.of(context).size.height / 40),
                Customtextfild.textField(
                  controller: phone,
                  name1: "Phone (optional)".tr,
                  keyboardType: TextInputType.phone,
                  labelclr: Colors.grey,
                  textcolor: notifire.getwhitecolor,
                  prefixIcon: Image.asset(
                    "image/llamada.png",
                    scale: 3.5,
                    //color: notifire.textcolor
                  ),
                  context: context,
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 40),
                Customtextfild.textField(
                  controller: email,
                  name1: "Email (optional)".tr,
                  keyboardType: TextInputType.emailAddress,
                  labelclr: Colors.grey,
                  textcolor: notifire.getwhitecolor,
                  prefixIcon: Image.asset(
                    "image/email.png",
                    scale: 3.5,
                    //color: notifire.textcolor
                  ),
                  context: context,
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 40),

                Customtextfild.textField(
                  controller: event_address_title,
                  name1: "Event address title, (Example: Plaza Lázaro Cárdenas)"
                      .tr
                      .tr,
                  labelclr: Colors.grey,
                  textcolor: notifire.getwhitecolor,
                  prefixIcon: Image.asset(
                    "image/direction.png",
                    scale: 3.5,
                    //color: notifire.textcolor
                  ),
                  context: context,
                ),
                buildEmptyFieldWarning(event_address_title, verificar),
                SizedBox(
                    height: MediaQuery.of(context).size.height /
                        40), // Ajustar altura según necesidad
                Customtextfild.textField(
                  controller: event_address,
                  name1: "Event address".tr,
                  keyboardType: TextInputType.streetAddress,
                  labelclr: Colors.grey,
                  textcolor: notifire.getwhitecolor,
                  prefixIcon: Image.asset(
                    "image/direction.png",
                    scale: 3.5,
                    //color: notifire.textcolor
                  ),
                  context: context,
                ),
                buildEmptyFieldWarning(event_address, verificar),
                SizedBox(height: MediaQuery.of(context).size.height / 40),

                MunicipiosComboBox(
                  labelColor: Colors.grey,
                  textColor: notifire.getwhitecolor,
                  onChanged: (value) {
                    setState(() {
                      municipio.text = value;
                    });
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 40),

                GestureDetector(
                  onTap: () async {
                    List<double>? location =
                        await Get.to(() => SelectLocation());
                    lat.text = location![0].toString();
                    long.text = location[1].toString();
                  },
                  child: SizedBox(
                    height: 30,
                    width: 200,
                    child: Custombutton.button2(
                      notifire.getbuttonscolor,
                      "Select location".tr,
                      SizedBox(width: width / 4),
                      SizedBox(width: width / 5),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 100),
                // Customtextfild.textField(
                //     controller: lat,
                //     name1: "Latitude".tr,
                //     labelclr: Colors.grey,
                //     textcolor: notifire.getwhitecolor,
                //     prefixIcon: Image.asset("image/direction.png",
                //         scale: 3.5, color: notifire.textcolor),
                //     readOnly: true,
                //     context: context,
                //     keyboardType: TextInputType.none),
                // buildEmptyFieldWarning(lat, verificar),
                SizedBox(height: MediaQuery.of(context).size.height / 40),
                // Customtextfild.textField(
                //     controller: long,
                //     name1: "Longitude".tr,
                //     labelclr: Colors.grey,
                //     textcolor: notifire.getwhitecolor,
                //     prefixIcon: Image.asset("image/direction.png",
                //         scale: 3.5, color: notifire.textcolor),
                //     readOnly: true,
                //     context: context,
                //     keyboardType: TextInputType.none),
                // buildEmptyFieldWarning(long, verificar),
                SizedBox(height: MediaQuery.of(context).size.height / 40),

                Center(
                  child: RichText(
                    text: TextSpan(
                        text: "By continuing, ".tr,
                        style: TextStyle(
                            color: notifire.getwhitecolor, fontSize: 12),
                        children: <TextSpan>[
                          TextSpan(text: "You agree to GoEvent's \n".tr),
                          TextSpan(
                              text: 'Terms of Use '.tr,
                              style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 2.5),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.to(() => Loream("Terms & Conditions".tr));
                                }),
                          const TextSpan(text: "and "),
                          TextSpan(
                              text: 'Privacy Policy.'.tr,
                              style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 2.5),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.to(() => Loream("Terms & Conditions".tr));
                                }),
                        ]),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 40),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      verificar = true;
                      // Actualizar el estado según si el campo está vacío o no
                      //isTitleEmpty = isFieldEmpty(event_title);
                    });
                    checkAllFieldsAndRegisterEvent(context);

                    //authSignUp();
                  },
                  child: SizedBox(
                    height: 45,
                    child: Custombutton.button1(
                      notifire.getbuttonscolor,
                      "Register event".tr,
                      SizedBox(width: width / 4),
                      SizedBox(width: width / 5),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  // Función para verificar si un campo de texto está vacío
  bool isFieldEmpty(TextEditingController controller) {
    return controller.text.isEmpty;
  }

  Future<void> checkAllFieldsAndRegisterEvent(BuildContext context) async {
  // Check for missing fields and display specific messages
  String? missingField = _validateFields();
  
  if (missingField != null) {
    // If a field is missing, show an error message and exit
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(missingField),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  try {
    int idMunicipio = int.parse(municipio.text);
    int idCategoria = int.parse(cid.text);
    int idPublicoObjetivo = int.parse(target_audience.text);

    await evento.crearEvento(
      context: context,
      tituloEvento: event_title.text,
      imagenEvento: pathEventImage[0],
      imagenPortadaEvento: pathCoverImage[0],
      fechaInicio: start_dateController.text,
      fechaFin: end_dateController.text,
      horaInicio: start_time.text,
      horaFin: end_time.text,
      precio: price.text,
      descripcionBreve: event_about_short.text,
      descripcion: event_about.text,
      galeriaImagen1: event_gallery.isNotEmpty ? event_gallery[0] : null,
      galeriaImagen2: event_gallery.length > 1 ? event_gallery[1] : null,
      galeriaImagen3: event_gallery.length > 2 ? event_gallery[2] : null,
      telefono: phone.text,
      correo: email.text,
      tituloDireccion: event_address_title.text,
      direccionEvento: event_address.text,
      latitud: lat.text,
      longitud: long.text,
      idMunicipio: idMunicipio,
      idCategoria: idCategoria,
      idPublicoObjetivo: idPublicoObjetivo,
    );

    ApiWrapper.showToastMessage("Evento Registrado Correctamente");
  } catch (e) {
    print('Error de formato: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Por favor, introduce valores válidos.')),
    );
  }
}

// Helper method to validate all required fields
String? _validateFields() {
  if (event_title.text.isEmpty) return 'Event title is required'.tr;
  if (event_about_short.text.isEmpty) return 'Short description is required'.tr;
  if (event_about.text.isEmpty) return 'Event description is required'.tr;
  if (start_dateController.text.isEmpty) return 'Start date is required'.tr;
  if (end_dateController.text.isEmpty) return 'End date is required'.tr;
  if (start_time.text.isEmpty) return 'Start time is required'.tr;
  if (end_time.text.isEmpty) return 'End time is required'.tr;
  if (price.text.isEmpty) return 'Price is required'.tr;
  if (event_address_title.text.isEmpty) return 'Event address title is required'.tr;
  if (event_address.text.isEmpty) return 'Event address is required'.tr;
  if (lat.text.isEmpty) return 'Location is required'.tr;
  if (long.text.isEmpty) return 'Location is required'.tr;
  if (municipio.text == '') return 'Municipality is required'.tr;
  if (cid.text == '') return 'Category is required'.tr;
  if (target_audience.text == '') return 'Target audience is required'.tr;
  if (pathCoverImage.isEmpty) return 'Event cover image is required'.tr;
  if (pathEventImage.isEmpty) return 'Event image is required'.tr;

  return null; // All fields are filled
}



  Visibility buildEmptyFieldWarning(
    TextEditingController controller,
    bool condition,
  ) {
    return Visibility(
      visible: condition && controller.text.isEmpty,
      child: Text(
        "Please enter this field".tr,
        style: TextStyle(
          color: Colors.red,
          fontSize: 12.0,
        ),
      ),
    );
  }

  Widget bookticket(user, i) {
    return InkWell(
      onTap: () {
        Get.to(() => TicketDetailPage(eID: user[i]["ticket_id"]));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
            border: Border.all(color: notifire.bordercolore),
            borderRadius: BorderRadius.circular(15),
            color: notifire.containercolore),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: height / 7,
                  width: width * 0.32,
                  decoration: const BoxDecoration(
                      // color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: FadeInImage.assetNetwork(
                            fadeInCurve: Curves.easeInCirc,
                            placeholder: "image/skeleton.gif",
                            fit: BoxFit.cover,
                            width: width,
                            height: height,
                            image: Config.base_url + user[i]["event_img"]),
                      ),
                      SizedBox(height: height / 70),
                    ],
                  ),
                ),
                SizedBox(
                  height: height / 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Ink(
                        width: Get.width * 0.54,
                        child: Text(user[i]["event_title"],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: notifire.textcolor,
                                fontSize: 16,
                                fontFamily: 'Gilroy Medium',
                                fontWeight: FontWeight.w600)),
                      ),
                      Ink(
                        width: Get.width * 0.54,
                        child: Text(user[i]["event_sdate"],
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: darktextColor,
                              fontSize: 12,
                              fontFamily: 'Gilroy Medium',
                            )),
                      ),
                      Row(
                        children: [
                          Image.asset("image/location.png",
                              height: height / 40),
                          SizedBox(width: Get.width * 0.01),
                          Ink(
                            width: Get.width * 0.46,
                            child: Text(
                              user[i]["event_address"],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'Gilroy Medium',
                                  fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: Get.height * 0.015),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ticketbutton(
                  title: "Cancel Booking".tr,
                  bgColor: notifire.getprimerycolor,
                  titleColor: buttonColor,
                  ontap: () {
                    ticketCancell(user[i]["ticket_id"]);
                  },
                ),
                ticketbutton(
                  title: "View E-Ticket".tr,
                  bgColor: buttonColor,
                  titleColor: Colors.white,
                  ontap: () {
                    Get.to(() => TicketDetailPage(eID: user[i]["ticket_id"]));
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  ticketbutton({Function()? ontap, String? title, Color? bgColor, titleColor}) {
    return InkWell(
      onTap: ontap,
      child: Container(
        height: Get.height * 0.04,
        width: Get.width * 0.40,
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: (BorderRadius.circular(18)),
            border: Border.all(color: buttonColor, width: 1)),
        child: Center(
          child: Text(title!,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: titleColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  fontFamily: 'Gilroy Medium')),
        ),
      ),
    );
  }

  ticketCancell(ticketid) {
    showModalBottomSheet(
        isDismissible: false,
        isScrollControlled: true,
        backgroundColor: notifire.containercolore,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: Get.height * 0.02),
                    Container(
                        height: 6,
                        width: 80,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(25))),
                    SizedBox(height: Get.height * 0.02),
                    Text(
                      "Cancel Booking".tr,
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Gilroy Bold',
                          color: const Color(0xffF0635A)),
                    ),
                    SizedBox(height: Get.height * 0.02),
                    Text(
                      "Please select the reason for cancellation:".tr,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Gilroy Medium',
                          color: notifire.textcolor),
                    ),
                    SizedBox(height: Get.height * 0.02),
                    ListView.builder(
                      itemCount: cancelList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (ctx, i) {
                        return Theme(
                          data: ThemeData(
                              unselectedWidgetColor: notifire.textcolor),
                          child: RadioListTile(
                            dense: true,
                            value: i,
                            activeColor: buttonColor,

                            // tileColor: notifire.textcolor,
                            selected: true,
                            groupValue: selectedRadioTile,
                            title: Text(
                              cancelList[i]["title"],
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Gilroy Medium',
                                  color: notifire.textcolor),
                            ),
                            onChanged: (val) {
                              setState(() {});
                              selectedRadioTile = val;
                              rejectmsg = cancelList[i]["title"];
                            },
                          ),
                        );
                      },
                    ),
                    rejectmsg == "Others"
                        ? SizedBox(
                            height: 50,
                            width: Get.width * 0.85,
                            child: TextField(
                              controller: note,
                              decoration: InputDecoration(
                                  isDense: true,
                                  enabledBorder: myinputborder(
                                      borderColor: notifire.gettextcolor),
                                  focusedBorder: myinputborder(
                                      borderColor: notifire.gettextcolor),
                                  hintText: 'Enter reason'.tr,
                                  hintStyle: TextStyle(
                                      fontFamily: 'Gilroy Medium',
                                      fontSize: height / 55,
                                      color: Colors.grey)),
                            ),
                          )
                        : const SizedBox(),
                    SizedBox(height: Get.height * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: Get.width * 0.35,
                          height: Get.height * 0.05,
                          child: ticketbutton(
                            title: "Cancel".tr,
                            bgColor: buttonColor,
                            titleColor: Colors.white,
                            ontap: () {
                              Get.back();
                            },
                          ),
                        ),
                        SizedBox(
                          width: Get.width * 0.35,
                          height: Get.height * 0.05,
                          child: ticketbutton(
                            title: "Confirm".tr,
                            bgColor: buttonColor,
                            titleColor: Colors.white,
                            ontap: () {
                              cancelticketApi(ticketid);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Get.height * 0.04),
                  ],
                ),
              ),
            );
          });
        });
  }

  List cancelList = [
    {"id": 1, "title": "I have another event, so it collides"},
    {"id": 2, "title": "Imsick. can't come"},
    {"id": 3, "title": "have an urgent need"},
    {"id": 4, "title": "have ne transportation to come"},
    {"id": 5, "title": "thave no friends to come"},
    {"id": 6, "title": "want to book another event"},
    {"id": 7, "title": "just want to cancel"},
    {"id": 8, "title": "Others"},
  ];

  cancelticketApi(ticketid) {
    var addMsg = rejectmsg == "Other" ? note.text : rejectmsg;
    var data = {"uid": uID, "tid": ticketid, "cancle_comment": addMsg};
    print("Api Call type price: :$data");
    ApiWrapper.dataPost(Config.ticketCancel, data).then((val) {
      print("Api Call type price: :$val");

      setState(() {});
      if ((val != null) && (val.isNotEmpty)) {
        if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
          setState(() {});
          ticketStatusApi();
          Get.back();
        } else {
          setState(() {});
          ApiWrapper.showToastMessage(val["ResponseMsg"]);
        }
      }
    });
  }
}

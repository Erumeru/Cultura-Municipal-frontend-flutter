// ignore_for_file: prefer_final_fields, body_might_complete_normally_nullable, unnecessary_string_interpolations, unnecessary_brace_in_string_interps, deprecated_member_use, avoid_print

//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goevent2/Api/ApiWrapper.dart';
import 'package:goevent2/login_signup/login.dart';
import 'package:goevent2/profile/loream.dart';
import 'package:goevent2/utils/AppWidget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Controller/AuthController.dart';
import '../home/home.dart';
import '../utils/botton.dart';
import '../utils/colornotifire.dart';
import '../utils/ctextfield.dart';
import '../utils/itextfield.dart';
import '../utils/media.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool status = false;
  bool verificar = false;
  //final auth = FirebaseAuth.instance;
  late ColorNotifire notifire;
  final name = TextEditingController();
  final userName = TextEditingController();
  final lastname = TextEditingController();
  final number = TextEditingController();
  final email = TextEditingController();
  final semail = TextEditingController();
  final fpassword = TextEditingController();
  final spassword = TextEditingController();
  final referral = TextEditingController();
  final age = TextEditingController();
  bool isLoading = false;
  String? _selectedCountryCode = '+52';
  final login = Get.put(AuthController());
  final x = Get.put(AuthController());
  String? gender;
  bool? genderSelected;

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    notifire.setIsDark = previusstate;
  }

  bool _obscureText = true;
  bool obscureText_ = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void toggle() {
    setState(() {
      obscureText_ = !obscureText_;
    });
  }

  @override
  void initState() {
    super.initState();
    //_selectedCountryCode = login.countryCode.first;
    getdarkmodepreviousstate();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.backgrounde,
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: height / 20),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child:
                        Icon(Icons.arrow_back, color: notifire.getwhitecolor),
                  ),
                ],
              ),
              SizedBox(height: height / 40),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: !isLoading
                        ? Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Registrate".tr,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Gilroy Medium',
                                        color: notifire.getwhitecolor),
                                  ),
                                ],
                              ),
                              SizedBox(height: height / 40),
                              Customtextfild.textField(
                                controller: email,
                                name1: "Email".tr,
                                labelclr: Colors.grey,
                                textcolor: notifire.getwhitecolor,
                                prefixIcon: Image.asset("image/Message.png",
                                    scale: 3.5, color: notifire.textcolor),
                                context: context,
                              ),

                              buildEmptyFieldWarning(email, verificar),
                              SizedBox(height: height / 100),

                              Customtextfild.textField(
                                controller: semail,
                                name1: "Confirm email".tr,
                                labelclr: Colors.grey,
                                textcolor: notifire.getwhitecolor,
                                prefixIcon: Image.asset("image/Message.png",
                                    scale: 3.5, color: notifire.textcolor),
                                context: context,
                              ),
                              buildEmptyFieldWarning(semail, verificar),
                              buildNoMatchEmailFieldWarning(
                                  email, semail, verificar),
                              SizedBox(height: height / 100),

                              Customtextfild.textField(
                                controller: name,
                                name1: "Nombre".tr,
                                labelclr: Colors.grey,
                                textcolor: notifire.getwhitecolor,
                                prefixIcon: Image.asset("image/Profile.png",
                                    scale: 3.5, color: notifire.textcolor),
                                context: context,
                              ),
                              buildEmptyFieldWarning(name, verificar),
                              SizedBox(height: height / 100),

                              Customtextfild.textField(
                                controller: lastname,
                                name1: "Last name".tr,
                                labelclr: Colors.grey,
                                textcolor: notifire.getwhitecolor,
                                keyboardType: TextInputType.text,
                                prefixIcon: Image.asset("image/Profile.png",
                                    scale: 3.5, color: notifire.textcolor),
                                context: context,
                              ),
                              buildEmptyFieldWarning(lastname, verificar),
                              SizedBox(height: height / 100),

                              Row(
                                children: [
                                  Expanded(
                                      flex: 4,
                                      child: Column(
                                        children: [
                                          Customtextfild.textField(
                                            controller: userName,
                                            name1: "User name".tr,
                                            labelclr: Colors.grey,
                                            textcolor: notifire.getwhitecolor,
                                            prefixIcon: Image.asset(
                                                "image/Profile.png",
                                                scale: 3.5,
                                                color: notifire.textcolor),
                                            context: context,
                                          ),
                                        ],
                                      )),
                                  Expanded(
                                    flex: 1,
                                    child: IconButton(
                                        onPressed: () => {
                                              setState(() {
                                                genderSelected = true;

                                                gender = "Male";
                                              })
                                            },
                                        icon: Icon(
                                          Icons.male,
                                          color: gender == "Male"
                                              ? Colors.blue
                                              : Colors.grey,
                                        )),
                                    //     if (gender == "Female") Text("!".tr)
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: IconButton(
                                        onPressed: () => {
                                              setState(() {
                                                genderSelected = true;
                                                gender = "Female";
                                              })
                                            },
                                        icon: Icon(
                                          Icons.female,
                                          color: gender == "Female"
                                              ? Colors.pink
                                              : Colors.grey,
                                        )),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          genderSelected = true;
                                          gender = "Other";
                                        });
                                      },
                                      icon: Icon(
                                        Icons.transgender,
                                        color: gender == "Other"
                                            ? Colors.purple
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: buildEmptyFieldWarning(
                                        userName, verificar),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: genderSelected == false
                                        ? Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "!".tr,
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          )
                                        : SizedBox(),
                                  )
                                ],
                              ),
                              SizedBox(height: height / 100),

                              Customtextfild.textField(
                                controller: age,
                                name1: "Age".tr,
                                labelclr: Colors.grey,
                                keyboardType: TextInputType.number,
                                textcolor: notifire.getwhitecolor,
                                prefixIcon: Image.asset("image/calender.png",
                                    scale: 3.5, color: notifire.textcolor),
                                context: context,
                              ),
                              buildEmptyFieldWarning(age, verificar),
                              SizedBox(height: height / 100),

                              Ink(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      height: 45,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              width: 1,
                                              color: notifire.bordercolore)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(width: 12),
                                          Image.asset("image/Call1.png",
                                              scale: 3.5,
                                              color: notifire.textcolor),
                                          cpicker(),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Customtextfild.textField(
                                        controller: number,
                                        name1: "Phone (optional)".tr,
                                        keyboardType: TextInputType.phone,
                                        labelclr: Colors.grey,
                                        textcolor: notifire.getwhitecolor,
                                        context: context,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //buildEmptyFieldWarning(number, verificar),
                              SizedBox(height: height / 100),
                              Customtextfild2.textField(
                                fpassword,
                                _obscureText,
                                "Contraseña".tr,
                                Colors.grey,
                                notifire.getwhitecolor,
                                "image/Lock.png",
                                GestureDetector(
                                    onTap: () {
                                      _toggle();
                                    },
                                    child: _obscureText
                                        ? Image.asset(
                                            "image/Hide.png",
                                            scale: 3.5,
                                            color: notifire.textcolor,
                                          )
                                        : Image.asset("image/Show.png",
                                            scale: 3.5,
                                            color: notifire.textcolor)),
                                context: context,
                              ),
                              buildEmptyFieldWarning(fpassword, verificar),
                              SizedBox(height: height / 100),
                              Customtextfild2.textField(
                                spassword,
                                obscureText_,
                                "Confirmar contraseña".tr,
                                Colors.grey,
                                notifire.getwhitecolor,
                                "image/Lock.png",
                                GestureDetector(
                                    onTap: () {
                                      toggle();
                                    },
                                    child: obscureText_
                                        ? Image.asset("image/Hide.png",
                                            height: 22,
                                            color: notifire.textcolor)
                                        : Image.asset("image/Show.png",
                                            height: 22,
                                            color: notifire.textcolor)),
                                context: context,
                              ),
                              buildEmptyFieldWarning(spassword, verificar),
                              buildNoMatchPasswordFieldWarning(
                                  fpassword, spassword, verificar),
                              SizedBox(height: height / 100),
                              SizedBox(height: Get.height * 0.02),
                              Row(
                                children: [
                                  Ink(
                                    width: Get.width * 0.12,
                                    child: Transform.scale(
                                      scale: 0.7,
                                      child: CupertinoSwitch(
                                        activeColor: notifire.getbuttonscolor,
                                        value: status,
                                        onChanged: (value) {
                                          setState(() {});
                                          status = value;
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: Get.width * 0.015),
                                  Center(
                                    child: RichText(
                                      text: TextSpan(
                                          text: "By continuing, ".tr,
                                          style: TextStyle(
                                              color: notifire.getwhitecolor,
                                              fontSize: 12),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text:
                                                    "You agree to GoEvent's \n"
                                                        .tr),
                                            TextSpan(
                                                text: 'Terms of Use '.tr,
                                                style: const TextStyle(
                                                    decoration: TextDecoration
                                                        .underline,
                                                    decorationThickness: 2.5),
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () {
                                                        Get.to(() => Loream(
                                                            "Terms & Conditions"
                                                                .tr));
                                                      }),
                                            TextSpan(text: "and ".tr),
                                            TextSpan(
                                                text: 'Privacy Policy.'.tr,
                                                style: const TextStyle(
                                                    decoration: TextDecoration
                                                        .underline,
                                                    decorationThickness: 2.5),
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () {
                                                        Get.to(() => Loream(
                                                            "Terms & Conditions"
                                                                .tr));
                                                      }),
                                          ]),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: Get.height * 0.10),
                              GestureDetector(
                                onTap: () {
                                  authSignUp();
                                  // print('hahahaha');
                                },
                                child: SizedBox(
                                  height: 45,
                                  child: Custombutton.button1(
                                    notifire.getbuttonscolor,
                                    "Registrase".tr,
                                    SizedBox(width: width / 4),
                                    SizedBox(width: width / 5),
                                  ),
                                ),
                              ),
                              SizedBox(height: Get.height / 60),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ".tr,
                                    style: TextStyle(
                                        color: notifire.getwhitecolor,
                                        fontSize: 14,
                                        fontFamily: 'Gilroy Medium'),
                                  ),
                                  Text(" "),
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(() => const Login(),
                                          duration: Duration.zero);
                                    },
                                    child: Text(
                                      "Sign in".tr,
                                      style: const TextStyle(
                                          color: Color(0xff5669FF),
                                          fontFamily: 'Gilroy Medium'),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )
                        : Column(
                            children: [
                              isLoadingCircular(),
                            ],
                          ),
                  ),
                ),
              )
            ],
          )),
    );
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

  ValueListenableBuilder buildNoMatchPasswordFieldWarning(
    TextEditingController controller1,
    TextEditingController controller2,
    bool condition,
  ) {
    return ValueListenableBuilder(
      valueListenable: controller1,
      builder: (context, value, child) {
        return ValueListenableBuilder(
          valueListenable: controller2,
          builder: (context, value, child) {
            return Visibility(
              visible: controller1.text != controller2.text && condition,
              child: Text(
                "Password no match".tr,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12.0,
                ),
              ),
            );
          },
        );
      },
    );
  }

  ValueListenableBuilder buildNoMatchEmailFieldWarning(
    TextEditingController controller1,
    TextEditingController controller2,
    bool condition,
  ) {
    return ValueListenableBuilder(
      valueListenable: controller1,
      builder: (context, value, child) {
        return ValueListenableBuilder(
          valueListenable: controller2,
          builder: (context, value, child) {
            return Visibility(
              visible: controller1.text != controller2.text && condition,
              child: Text(
                "Email no match".tr,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12.0,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget log(clr, name, img, clr2) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Get.to(() => const Home(), duration: Duration.zero);
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: clr),
          height: height / 15,
          width: width / 1.5,
          child: Row(
            children: [
              SizedBox(width: width / 10),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Image.asset(img)),
              SizedBox(width: width / 20),
              Text(
                name,
                style: TextStyle(
                    color: clr2,
                    fontFamily: 'Gilroy Medium',
                    fontSize: 15,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  cpicker() {
    var countryCode = ['+52', '+1'];
    var countryDropDown = Ink(
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton(
            value: _selectedCountryCode,
            items: countryCode.map((value) {
              return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value,
                      style:
                          const TextStyle(fontSize: 14.0, color: Colors.grey)));
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _selectedCountryCode = value;
              });
            },
            //style: Theme.of(context).textTheme.headline6
          ),
        ),
      ),
    );
    return countryDropDown;
  }

  //
  authSignUp() {
    print('uhuhuhuhu');
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      verificar = true;
      // Actualizar el estado según si el campo está vacío o no
      //isTitleEmpty = isFieldEmpty(event_title);
    });

    if (name.text.isNotEmpty &&
            lastname.text.isNotEmpty &&
            userName.text.isNotEmpty &&
            email.text.isNotEmpty &&
            semail.text.isNotEmpty &&
            //number.text.isNotEmpty &&
            fpassword.text.isNotEmpty &&
            spassword.text.isNotEmpty &&
            age.text.isNotEmpty &&
            (gender != null && 
                genderSelected != false)
        // &&        referral.text.isNotEmpty
        ) {
      if ((RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+\.[a-zA-Z]+")
          .hasMatch(email.text))) {
        if (email.text == semail.text) {
          if (fpassword.text == spassword.text) {
            if (status == true) {
              setState(() {
                isLoading = true;
              });
              var register = {
                "UserName": name.text.trim(),
                "Usernumber": number.text.trim(),
                "UserEmail": email.text.trim(),
                //"Ccode": _selectedCountryCode,
                "FPassword": fpassword.text.trim(),
                "SPassword": spassword.text.trim(),
                //"ReferralCode": referral.text.trim(),
              };
              save("User", register);
              print('email: ${email.text}');
              print('Nombre: ${name.text}');
              print('Apellidos: ${lastname.text}');
              print('Nombre usuario: ${userName.text}');
              print('Telefono: ${number.text}');
              print('contrasna: ${fpassword.text}');
              print('edad: ${age.text}');
              print('genero: ${gender}');

              try {
                int? telefono;
                int? edad;
                if (number.text.isNotEmpty) {
                  telefono = int.parse(number.text);
                } else {
                  telefono =
                      null; // O el valor predeterminado que prefieras, como 0.
                }
                if (age.text.isNotEmpty) {
                  edad = int.parse(age.text);
                } else {
                  edad = null;
                }

                login.registrarUsuario(
                    email: email.text,
                    nombreUsuario: userName.text,
                    nombre: name.text,
                    telefono: telefono,
                    apellido: lastname.text,
                    password: fpassword.text,
                    edad: edad,
                    gender: gender);
              } catch (e) {
                ApiWrapper.showToastMessage(
                    'Error al registrar el usuario. Por favor, verifica los datos ingresados o intentelo de nuevo mas tarde.');
              }

              print('Chingon');
            } else {
              ApiWrapper.showToastMessage(
                  "Accept terms & Condition is required".tr);
            }
          } else {
            ApiWrapper.showToastMessage("Password not match".tr);
          }
        } else {
          ApiWrapper.showToastMessage("Email not match".tr);
        }
      } else {
        ApiWrapper.showToastMessage('Please enter valid email address'.tr);
      }
    } else {
      if (gender == null) {
        print("calando ${gender}");
        ApiWrapper.showToastMessage('Please select gender'.tr);
        genderSelected = false;
      }
      print("aca ${gender} ${genderSelected}");
      ApiWrapper.showToastMessage("Please fill required field!".tr);
    }
  }

/*
  Future<void> verifyPhone(String number) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: number,
      timeout: const Duration(seconds: 30),
      verificationCompleted: (PhoneAuthCredential credential) {
        ApiWrapper.showToastMessage("Auth Completed!");
        setState(() {
          isLoading = false;
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        ApiWrapper.showToastMessage("Auth Failed!");
        setState(() {
          isLoading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        ApiWrapper.showToastMessage("OTP Sent!");
        setState(() {
          isLoading = false;
        });
        Get.to(() => Verification(verID: verificationId, email: number,isReset: false));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        ApiWrapper.showToastMessage("Timeout!");
        setState(() {
          isLoading = false;
        });
      },
    );
  }

 */
}



//15900 + 5700 = 21600



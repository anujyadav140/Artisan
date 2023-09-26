import 'package:artisan/attendance/homescreen.dart';
import 'package:artisan/attendance/registerscreen.dart';
import 'package:artisan/pages/home.dart';
import 'package:artisan/services/authentication/auth_gate_mobile.dart';
import 'package:artisan/services/authentication/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController idController = TextEditingController();
  TextEditingController passController = TextEditingController();

  double screenHeight = 0;
  double screenWidth = 0;

  Color primary = Colors.blueAccent;

  late SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible =
        KeyboardVisibilityProvider.isKeyboardVisible(context);
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            isKeyboardVisible
                ? SizedBox(
                    height: screenHeight / 16,
                  )
                : Container(
                    height: screenHeight / 2.5,
                    width: screenWidth,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(70),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: screenWidth / 5,
                      ),
                    ),
                  ),
            Container(
              margin: EdgeInsets.only(
                top: screenHeight / 15,
                bottom: screenHeight / 20,
              ),
              child: Text(
                "Login",
                style: TextStyle(
                  fontSize: screenWidth / 18,
                  fontFamily: "NexaBold",
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(
                horizontal: screenWidth / 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  fieldTitle("Employee ID"),
                  customField("Enter your employee id", idController, false),
                  fieldTitle("Password"),
                  customField("Enter your password", passController, true),
                  GestureDetector(
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      String id = idController.text.trim();
                      String password = passController.text.trim();

                      //get the auth service
                      final authService =
                          Provider.of<AuthService>(context, listen: false);
                      try {
                        await authService.loginWithEmailAndPassword(
                            id, password);
                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AuthGateMobile()),
                        );
                      } catch (e) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Trying to sign you in...")));
                      }

                      if (id.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Employee id is still empty!"),
                        ));
                      } else if (password.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Password is still empty!"),
                        ));
                      } else {
                        QuerySnapshot snap = await FirebaseFirestore.instance
                            .collection("Employee")
                            .where('id', isEqualTo: id)
                            .get();

                        try {
                          if (password == snap.docs[0]['password']) {
                            sharedPreferences =
                                await SharedPreferences.getInstance();

                            sharedPreferences
                                .setString('employeeId', id)
                                .then((_) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const HomeScreen()));
                            });
                          } else {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Password is not correct!"),
                            ));
                          }
                        } catch (e) {
                          String error = " ";

                          if (e.toString() ==
                              "RangeError (index): Invalid value: Valid value range is empty: 0") {
                            setState(() {
                              error = "Trying to sign you in...";
                            });
                          } else {
                            setState(() {
                              error = "Error occurred!";
                            });
                          }

                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(error),
                          ));
                        }
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          height: 60,
                          width: screenWidth,
                          margin: EdgeInsets.only(top: screenHeight / 40),
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(30)),
                          ),
                          child: Center(
                            child: Text(
                              "LOGIN",
                              style: TextStyle(
                                fontFamily: "NexaBold",
                                fontSize: screenWidth / 26,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ));
                          },
                          child: Container(
                            height: 30,
                            width: screenWidth,
                            margin: EdgeInsets.only(top: screenHeight / 40),
                            child: Center(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Don't have an account? ",
                                      style: TextStyle(
                                        fontFamily: "NexaBold",
                                        fontSize: screenWidth / 25,
                                        color: Colors.black,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Register",
                                      style: TextStyle(
                                        fontFamily: "NexaBold",
                                        fontSize: screenWidth / 20,
                                        color: Colors
                                            .blueAccent, // Set the color to blue
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget fieldTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth / 26,
          fontFamily: "NexaBold",
        ),
      ),
    );
  }

  Widget customField(
      String hint, TextEditingController controller, bool obscure) {
    return Container(
      width: screenWidth,
      margin: EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: screenWidth / 6,
            child: Icon(
              Icons.person,
              color: primary,
              size: screenWidth / 15,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: screenWidth / 12),
              child: TextFormField(
                controller: controller,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight / 35,
                  ),
                  border: InputBorder.none,
                  hintText: hint,
                ),
                maxLines: 1,
                obscureText: obscure,
              ),
            ),
          )
        ],
      ),
    );
  }
}

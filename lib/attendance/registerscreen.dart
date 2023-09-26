import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController idController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  double screenHeight = 0;
  double screenWidth = 0;

  Color primary = Colors.blueAccent;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(screenWidth / 12),
              child: Column(
                children: [
                  fieldTitle("Employee ID"),
                  customField("Enter your employee ID", idController, false),
                  fieldTitle("Password"),
                  customField("Enter your password", passwordController, true),
                  fieldTitle("Confirm Password"),
                  customField(
                      "Confirm your password", confirmPasswordController, true),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                String id = idController.text.trim();
                String password = passwordController.text.trim();
                String confirmPassword = confirmPasswordController.text.trim();

                if (id.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("All fields are required!"),
                  ));
                } else if (password != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Passwords do not match!"),
                  ));
                } else {
                  // Registration logic
                  try {
                    await FirebaseFirestore.instance
                        .collection("Employee")
                        .add({
                      "id": id,
                      "password": password,
                    });

                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Registration successful!"),
                    ));

                    // Clear text fields after successful registration
                    idController.clear();
                    passwordController.clear();
                    confirmPasswordController.clear();

                    // Navigate back to the login screen
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  } catch (e) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Registration failed. Try again later."),
                    ));
                  }
                }
              },
              child: Container(
                height: 60,
                width: screenWidth,
                margin: EdgeInsets.only(top: screenHeight / 40),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                ),
                child: Center(
                  child: Text(
                    "REGISTER",
                    style: TextStyle(
                      fontFamily: "NexaBold",
                      fontSize: screenWidth / 26,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
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
      margin: const EdgeInsets.only(bottom: 12),
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

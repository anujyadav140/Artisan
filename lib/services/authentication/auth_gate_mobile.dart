import 'package:artisan/main.dart';
import 'package:artisan/pages/home.dart';
import 'package:artisan/services/authentication/auth_gate.dart';
import 'package:artisan/services/authentication/login_or_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:month_year_picker/month_year_picker.dart';

class AuthGateMobile extends StatelessWidget {
  const AuthGateMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          // Check if the snapshot has data and if the user is logged in
          if (snapshot.hasData && snapshot.data != null) {
            return const MyHomePage(
              title: 'Artisan Home Page',
            );
          }
          // User is not logged in or snapshot is null
          else {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Artisan',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: const KeyboardVisibilityProvider(
                child: kIsWeb ? AuthGate() : AuthCheck(),
              ),
              localizationsDelegates: const [
                MonthYearPickerLocalizations.delegate,
              ],
            );
            ;
          }
        },
      ),
    );
  }
}

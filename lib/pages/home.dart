import 'package:artisan/attendance/loginscreen.dart';
import 'package:artisan/main.dart';
import 'package:artisan/pages/add_services.dart';
import 'package:artisan/pages/attendance.dart';
import 'package:artisan/pages/billing.dart';
import 'package:artisan/pages/client.dart';
import 'package:artisan/services/authentication/auth_gate.dart';
import 'package:artisan/services/authentication/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //logout user
  void logout() {
    //get auth service
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15), // Rounded bottom edges
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                logout();
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              // launchWhatsAppUri();
              // Navigate to the client page here
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ClientPage(),
              ));
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey),
                ),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 30.0,
                    backgroundImage: AssetImage('your_avatar_image.png'),
                  ),
                  SizedBox(width: 16.0),
                  Text(
                    'Clients \n ',
                    style: TextStyle(fontSize: 24.0),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const Billing(),
              ));
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey),
                ),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 30.0,
                    backgroundImage: AssetImage('your_avatar_image.png'),
                  ),
                  SizedBox(width: 16.0),
                  Text(
                    'Billing',
                    style: TextStyle(fontSize: 24.0),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const Attendance(),
              ));
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey),
                ),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 30.0,
                    backgroundImage: AssetImage('your_avatar_image.png'),
                  ),
                  SizedBox(width: 16.0),
                  Text(
                    'Staff Attendance \n - attendance for today is 90%',
                    style: TextStyle(fontSize: 24.0),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Navigate to the services page here
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const AddServices(),
              ));
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey),
                ),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 30.0,
                    backgroundImage: AssetImage('your_avatar_image.png'),
                  ),
                  SizedBox(width: 16.0),
                  Text(
                    'Add Services',
                    style: TextStyle(fontSize: 24.0),
                  ),
                ],
              ),
            ),
          ),
          // GestureDetector(
          //   onTap: () {
          //     // Navigate to the client page here
          //   },
          //   child: Container(
          //     padding: const EdgeInsets.all(16.0),
          //     decoration: const BoxDecoration(
          //       border: Border(
          //         bottom: BorderSide(color: Colors.grey),
          //       ),
          //     ),
          //     child: const Row(
          //       children: [
          //         CircleAvatar(
          //           radius: 30.0,
          //           backgroundImage: AssetImage('your_avatar_image.png'),
          //         ),
          //         SizedBox(width: 16.0),
          //         Text(
          //           'Client Appointments \n - 3 appointments for today',
          //           style: TextStyle(fontSize: 24.0),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

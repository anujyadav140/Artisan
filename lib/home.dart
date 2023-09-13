import 'package:artisan/client.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

launchWhatsAppUri() async {
  const link = WhatsAppUnilink(
    phoneNumber: '+91-9892919001',
    text: "TEST 123 AAAA",
  );
  await launchUrl(link.asUri());
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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
              // Navigate to the client page here
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
                    'Product Stock \n - current product stock is 100',
                    style: TextStyle(fontSize: 24.0),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Navigate to the client page here
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
              // Navigate to the client page here
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
                    'Work Allotments to Staff \n - 5 tasks alloted to staff',
                    style: TextStyle(fontSize: 24.0),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Navigate to the client page here
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
                    'Client Appointments \n - 3 appointments for today',
                    style: TextStyle(fontSize: 24.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

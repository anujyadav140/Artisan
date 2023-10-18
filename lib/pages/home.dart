import 'package:artisan/attendance/loginscreen.dart';
import 'package:artisan/components/artisan_list.dart';
import 'package:artisan/main.dart';
import 'package:artisan/pages/add_services.dart';
import 'package:artisan/pages/attendance.dart';
import 'package:artisan/pages/attendance_today.dart';
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
    double w = MediaQuery.of(context).size.width;
    bool isLessThan960() {
      if (w < 960) {
        return true;
      } else {
        return false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
              fontFamily: "NexaBold",
              color: Colors.white,
              fontSize: kIsWeb
                  ? isLessThan960()
                      ? w / 20
                      : 24
                  : w / 20),
        ),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            ArtisanListItem(
              onNavigate: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ClientPage(),
                ));
              },
              asset: 'assets/images/client.jpg',
              artisanListItemName: 'Clients \n ',
            ),
            ArtisanListItem(
              onNavigate: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const Billing(),
                ));
              },
              asset: 'assets/images/billing.jpg',
              artisanListItemName: 'Billing',
            ),
            ArtisanListItem(
              onNavigate: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AttendanceForTheDay(),
                ));
              },
              asset: 'assets/images/attendance_day.jpeg',
              artisanListItemName: 'Attendance for the day',
            ),
            ArtisanListItem(
              onNavigate: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const Attendance(),
                ));
              },
              asset: 'assets/images/attendance.jpg',
              artisanListItemName: 'Employee Attendance History',
            ),
            ArtisanListItem(
              onNavigate: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AddServices(),
                ));
              },
              asset: 'assets/images/services.jpeg',
              artisanListItemName: 'Add Services',
            ),
          ],
        ),
      ),
    );
  }
}

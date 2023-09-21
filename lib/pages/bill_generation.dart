import 'dart:math';
import 'package:artisan/services/authentication/auth_service.dart';
import 'package:artisan/services/client_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:typed_data';
import 'dart:io';

class BillingGeneration extends StatefulWidget {
  const BillingGeneration(
      {super.key, required this.discount, required this.servicePrices});
  final Map<String, double> servicePrices;
  final double discount;
  @override
  State<BillingGeneration> createState() => _BillingGenerationState();
}

class _BillingGenerationState extends State<BillingGeneration> {
  // Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Function to capture and save the screenshot to Firebase Storage
  Future<void> captureAndSaveScreenshot() async {
    try {
      // Capture the screenshot
      Uint8List? screenshot = await screenshotController.capture();

      if (screenshot != null) {
        // Get a reference to the Firebase Storage bucket
        final firebase_storage.Reference storageRef = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('screenshots');

        // Generate a unique filename for the screenshot
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        String fileName = 'screenshot_$timestamp.png';

        // Upload the screenshot to Firebase Storage
        await storageRef.child(fileName).putData(screenshot);

        // Get the download URL of the uploaded screenshot
        String downloadURL = await storageRef.child(fileName).getDownloadURL();

        // You can now use the downloadURL as needed, e.g., save it to Firestore or display it to the user
        print('Screenshot uploaded to Firebase Storage: $downloadURL');
      }
    } catch (e) {
      print('Error capturing and saving screenshot: $e');
    }
  }

  double calculateTotal(
      Map<String, double> servicePrices, double discount, double tax) {
    double total = 0;
    for (var entry in servicePrices.entries) {
      total += entry.value;
    }
    total = total - discount + (total * tax / 100);
    return total;
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height; // Remove height calculation

    // Map<String, double> servicePrices = {
    //   'Haircut': 10.0,
    //   'Hair Color': 20.0,
    //   'Manicure': 15.0,
    //   'Pedicure': 25.0,
    //   'Facial': 30.0,
    //   'Massage': 20.0,
    // };

    // Add discount and tax
    // double discount = 10; // Change this to your discount amount
    double tax = 5; // Change this to your tax rate

    bool isWeb(BuildContext context) {
      if (kIsWeb) {
        // Check screen size
        if (MediaQuery.of(context).size.width < 960) {
          return false;
        } else {
          return true;
        }
      } else {
        return false;
      }
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Billing Generation"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(scaffoldKey.currentContext!);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              // Capture and save the screenshot
              captureAndSaveScreenshot();
            },
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(
          "Generate Bill",
          style: TextStyle(
              color: Colors.black, fontSize: isWeb(context) ? w / 100 : w / 30),
          textAlign: TextAlign.center,
          textScaleFactor: 1.2,
        ),
        onPressed: () {},
        icon: const Icon(Icons.request_page_outlined),
      ),
      body: SingleChildScrollView(
        child: Screenshot(
          controller: screenshotController,
          child: Center(
            child: Container(
              width: isWeb(context) ? w / 3 : w / 1,
              // Reduce the height here to make it shorter
              height: isWeb(context) ? h / 1 : h / 1,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                // Wrap your content with SingleChildScrollView
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Image.asset(
                            'assets/images/artisan_logo.png',
                            width: 100,
                            height: 100,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 25),
                      child: const Text(
                          'Nirmal Galaxy, Lal Bahadur Shastri Marg,\nopp. Johnson & Johnson Ltd,\nMulund (W), Mumbai, Maharashtra 400080'),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Bill No: ${Random().nextInt(100000)}',
                      style: TextStyle(
                          fontSize: isWeb(context) ? w / 100 : w / 30,
                          fontWeight: FontWeight.bold),
                    ),
                    // DataTable widget for services and costs
                    SizedBox(
                      width: isWeb(context) ? w / 3 : w / 1,
                      // Reduce the height here to make it shorter
                      height: isWeb(context) ? h / 2 : h / 1,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Service')),
                          DataColumn(label: Text('Price')),
                        ],
                        rows: widget.servicePrices.entries
                            .map((entry) => DataRow(
                                  cells: [
                                    DataCell(Text(entry.key)),
                                    DataCell(Text(entry.value.toString())),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                    SizedBox(
                      width: isWeb(context) ? w / 3 : w / 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Divider(
                                color: Colors.black,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    'Discount: \$${widget.discount.toStringAsFixed(2)}'),
                                Text(
                                    'Tax: \$${(tax / 100 * calculateTotal(widget.servicePrices, widget.discount, tax)).toStringAsFixed(2)}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total: \$${calculateTotal(widget.servicePrices, widget.discount, tax).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

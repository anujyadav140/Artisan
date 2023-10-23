import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class BillingGeneration extends StatefulWidget {
  const BillingGeneration(
      {super.key,
      required this.discount,
      required this.servicePrices,
      required this.phoneNumber,
      required this.name});
  final Map<String, double> servicePrices;
  final double discount;
  final String name;
  final String phoneNumber;
  @override
  State<BillingGeneration> createState() => _BillingGenerationState();
}

class _BillingGenerationState extends State<BillingGeneration> {
  // Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String downloadURL = '';

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
        downloadURL = await storageRef.child(fileName).getDownloadURL();

        final phoneNumber = "+91-${widget.phoneNumber}";
        final message =
            "Hi ${widget.name},\n\nPlease find your bill here:\n $downloadURL\n\nThank you for choosing us!\n\nRegards,\nArtisan";

        final link = WhatsAppUnilink(
          phoneNumber: phoneNumber,
          text: message,
        );

        await launchUrl(link.asUri());
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
    double h = MediaQuery.of(context).size.height;

    double tax = 0;

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
        title: Text(
          "Billing Generation",
          style: TextStyle(
            fontFamily: "NexaBold",
            fontSize: isWeb(context) ? w / 80 : w / 20,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(scaffoldKey.currentContext!);
          },
        ),
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
        onPressed: () async {
          captureAndSaveScreenshot();
        },
        icon: const Icon(Icons.request_page_outlined),
      ),
      body: SingleChildScrollView(
        child: Screenshot(
          controller: screenshotController,
          child: Container(
            width: isWeb(context) ? w / 3 : w / 1,
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
                    height: h * 0.5,
                    child: Expanded(
                      child: DataTable(
                        columns: const [
                          DataColumn(
                              label: Text(
                            'Service',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                          DataColumn(
                              label: Text(
                            'Price',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )),
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
                                  'Discount: ${widget.discount.toStringAsFixed(2)}%'),
                              Text(
                                  'Tax: ₹${(tax / 100 * calculateTotal(widget.servicePrices, widget.discount, tax)).toStringAsFixed(2)}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total: ₹${calculateTotal(widget.servicePrices, widget.discount, tax).toStringAsFixed(2)}',
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
    );
  }
}

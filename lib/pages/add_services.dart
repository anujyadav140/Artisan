import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddServices extends StatefulWidget {
  const AddServices({super.key});

  @override
  State<AddServices> createState() => _AddServicesState();
}

class _AddServicesState extends State<AddServices> {
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _servicePriceController = TextEditingController();

  @override
  void dispose() {
    _serviceNameController.dispose();
    _servicePriceController.dispose();
    super.dispose();
  }

  void _addServiceToFirestore() {
    final String serviceName = _serviceNameController.text.trim();
    final String servicePriceString = _servicePriceController.text.trim();

    // Regular expression pattern to match a valid number
    final RegExp numberPattern = RegExp(r'^\d+(\.\d+)?$');

    if (serviceName.isNotEmpty && numberPattern.hasMatch(servicePriceString)) {
      final double servicePrice = double.parse(servicePriceString);

      FirebaseFirestore.instance.collection('Services').add({
        'serviceName': serviceName,
        'servicePrice': servicePrice,
      });

      _serviceNameController.clear();
      _servicePriceController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Service added to Firestore',
            style: TextStyle(
                fontFamily: "NexaBold",
                fontSize: kIsWeb ? 18 : MediaQuery.of(context).size.width / 25,
                color: Colors.blue),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid service name and price.',
            style: TextStyle(
                fontFamily: "NexaBold",
                fontSize: kIsWeb ? 18 : MediaQuery.of(context).size.width / 25,
                color: Colors.blue),
          ),
        ),
      );
    }
  }

  void _editServiceInFirestore(
      String docId, String newServiceName, double newServicePrice) {
    FirebaseFirestore.instance.collection('Services').doc(docId).update({
      'serviceName': newServiceName,
      'servicePrice': newServicePrice,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Service updated in Firestore',
          style: TextStyle(
              fontFamily: "NexaBold",
              fontSize: kIsWeb ? 18 : MediaQuery.of(context).size.width / 25,
              color: Colors.blue),
        ),
      ),
    );
  }

  void _deleteServiceInFirestore(String docId) {
    FirebaseFirestore.instance.collection('Services').doc(docId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Service deleted from Firestore',
          style: TextStyle(
              fontFamily: "NexaBold",
              fontSize: kIsWeb ? 18 : MediaQuery.of(context).size.width / 25,
              color: Colors.blue),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Services',
          style: TextStyle(
              fontFamily: "NexaBold",
              fontSize: kIsWeb ? 30 : screenWidth / 18,
              color: Colors.white),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15), // Rounded bottom edges
          ),
        ),
      ),
      body: SizedBox(
        width: kIsWeb ? 600 : double.infinity,
        child: Column(
          children: <Widget>[
            Card(
              elevation: 4.0,
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _serviceNameController,
                      decoration: InputDecoration(
                        labelText: 'Service Name',
                        labelStyle: TextStyle(
                            fontFamily: "NexaBold",
                            fontSize: kIsWeb ? 24 : screenWidth / 18,
                            color: Colors.grey),
                      ),
                    ),
                    TextField(
                      controller: _servicePriceController,
                      decoration: InputDecoration(
                        labelText: 'Service Price',
                        labelStyle: TextStyle(
                            fontFamily: "NexaBold",
                            fontSize: kIsWeb ? 24 : screenWidth / 18,
                            color: Colors.grey),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _addServiceToFirestore,
                      child: Text(
                        'Add Service',
                        style: TextStyle(
                            fontFamily: "NexaBold",
                            fontSize: kIsWeb ? 18 : screenWidth / 25,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Services')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final services = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service =
                          services[index].data() as Map<String, dynamic>;
                      final docId = services[index].id;
                      final serviceName = service['serviceName'] ?? '';
                      final servicePrice = service['servicePrice'] ?? 0.0;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          title: Text(
                            '$serviceName',
                            style: TextStyle(
                                fontFamily: "NexaBold",
                                fontSize: kIsWeb ? 18 : screenWidth / 22,
                                color: Colors.black),
                          ),
                          subtitle: Text(
                            '₹${servicePrice.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontFamily: "NexaBold",
                                fontSize: kIsWeb ? 18 : screenWidth / 22,
                                color: Colors.black),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      TextEditingController
                                          editedNameController =
                                          TextEditingController(
                                              text: serviceName);
                                      TextEditingController
                                          editedPriceController =
                                          TextEditingController(
                                              text: servicePrice
                                                  .toStringAsFixed(2));

                                      return AlertDialog(
                                        title: Text(
                                          'Edit Service',
                                          style: TextStyle(
                                              fontFamily: "NexaBold",
                                              fontSize: kIsWeb
                                                  ? 18
                                                  : screenWidth / 18,
                                              color: Colors.blue),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            TextField(
                                              controller: editedNameController,
                                              decoration: InputDecoration(
                                                labelText: 'New Service Name',
                                                labelStyle: TextStyle(
                                                    fontFamily: "NexaBold",
                                                    fontSize: kIsWeb
                                                        ? 18
                                                        : screenWidth / 18,
                                                    color: Colors.grey),
                                              ),
                                            ),
                                            TextField(
                                              controller: editedPriceController,
                                              decoration: InputDecoration(
                                                labelText: 'New Service Price',
                                                labelStyle: TextStyle(
                                                    fontFamily: "NexaBold",
                                                    fontSize: kIsWeb
                                                        ? 18
                                                        : screenWidth / 18,
                                                    color: Colors.grey),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            },
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                  fontFamily: "NexaBold",
                                                  fontSize: kIsWeb
                                                      ? 18
                                                      : screenWidth / 25,
                                                  color: Colors.blue),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              String newServiceName =
                                                  editedNameController.text
                                                      .trim();
                                              double newServicePrice =
                                                  double.tryParse(
                                                          editedPriceController
                                                              .text
                                                              .trim()) ??
                                                      0.0;

                                              if (newServiceName.isNotEmpty &&
                                                  newServicePrice > 0) {
                                                _editServiceInFirestore(
                                                    docId,
                                                    newServiceName,
                                                    newServicePrice);
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Please enter valid values.',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              "NexaBold",
                                                          fontSize: kIsWeb
                                                              ? 18
                                                              : screenWidth /
                                                                  25,
                                                          color: Colors.blue),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Text(
                                              'Save',
                                              style: TextStyle(
                                                  fontFamily: "NexaBold",
                                                  fontSize: kIsWeb
                                                      ? 18
                                                      : screenWidth / 25,
                                                  color: Colors.blue),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          'Delete Service',
                                          style: TextStyle(
                                              fontFamily: "NexaBold",
                                              fontSize: kIsWeb
                                                  ? 18
                                                  : screenWidth / 18,
                                              color: Colors.blue),
                                        ),
                                        content: Text(
                                          'Are you sure you want to delete this service?',
                                          style: TextStyle(
                                              fontFamily: "NexaBold",
                                              fontSize: kIsWeb
                                                  ? 18
                                                  : screenWidth / 22,
                                              color: Colors.black),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            },
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                  fontFamily: "NexaBold",
                                                  fontSize: kIsWeb
                                                      ? 18
                                                      : screenWidth / 25,
                                                  color: Colors.blue),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              _deleteServiceInFirestore(docId);
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            },
                                            child: Text(
                                              'Delete',
                                              style: TextStyle(
                                                  fontFamily: "NexaBold",
                                                  fontSize: kIsWeb
                                                      ? 18
                                                      : screenWidth / 25,
                                                  color: Colors.blue),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

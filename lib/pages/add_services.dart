import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddServices extends StatefulWidget {
  const AddServices({Key? key});

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
    final double servicePrice =
        double.tryParse(_servicePriceController.text.trim()) ?? 0.0;

    if (serviceName.isNotEmpty && servicePrice > 0) {
      FirebaseFirestore.instance.collection('Services').add({
        'serviceName': serviceName,
        'servicePrice': servicePrice,
      });

      _serviceNameController.clear();
      _servicePriceController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service added to Firestore'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid service name and price.'),
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
      const SnackBar(
        content: Text('Service updated in Firestore'),
      ),
    );
  }

  void _deleteServiceInFirestore(String docId) {
    FirebaseFirestore.instance.collection('Services').doc(docId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Service deleted from Firestore'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Services'),
      ),
      body: Column(
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
                    decoration: InputDecoration(labelText: 'Service Name'),
                  ),
                  TextField(
                    controller: _servicePriceController,
                    decoration: InputDecoration(labelText: 'Service Price'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _addServiceToFirestore,
                    child: Text('Add Service'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('Services').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
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
                        title: Text('Service Name: $serviceName'),
                        subtitle: Text(
                            'Service Price: \$${servicePrice.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    TextEditingController editedNameController =
                                        TextEditingController(
                                            text: serviceName);
                                    TextEditingController
                                        editedPriceController =
                                        TextEditingController(
                                            text: servicePrice
                                                .toStringAsFixed(2));

                                    return AlertDialog(
                                      title: Text('Edit Service'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          TextField(
                                            controller: editedNameController,
                                            decoration: InputDecoration(
                                                labelText: 'New Service Name'),
                                          ),
                                          TextField(
                                            controller: editedPriceController,
                                            decoration: InputDecoration(
                                                labelText: 'New Service Price'),
                                            keyboardType: TextInputType.number,
                                          ),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          child: Text('Cancel'),
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
                                                const SnackBar(
                                                  content: Text(
                                                      'Please enter valid values.'),
                                                ),
                                              );
                                            }
                                          },
                                          child: Text('Save'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Delete Service'),
                                      content: Text(
                                          'Are you sure you want to delete this service?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _deleteServiceInFirestore(docId);
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          child: Text('Delete'),
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
    );
  }
}

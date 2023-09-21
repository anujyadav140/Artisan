import 'package:artisan/pages/bill_generation.dart';
import 'package:artisan/services/authentication/auth_service.dart';
import 'package:artisan/services/client_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MySearchDelegate extends SearchDelegate {
  final Function(String) onSuggestionClicked; // Callback function
  final VoidCallback clearClientData; // Callback function to clear _clientData

  MySearchDelegate(
      {required this.onSuggestionClicked, required this.clearClientData});
  @override
  Widget? buildLeading(BuildContext context) => IconButton(
      onPressed: () {
        clearClientData(); // Call the callback to clear _clientData
        Provider.of<AuthService>(context, listen: false).searchResult = false;
        Provider.of<AuthService>(context, listen: false).searchQuery = "";
        close(context, null);
      },
      icon: Icon(Icons.arrow_back));

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
            onPressed: () {
              if (query.isEmpty) {
                close(context, null);
              }
              query = '';
            },
            icon: Icon(Icons.clear))
      ];

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Clients').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final suggestions = <String>[];
        // Iterate through the documents in the collection
        for (final doc in snapshot.data!.docs) {
          final phoneNumber =
              doc['phoneNumber']; // Assuming the field name is 'phone'
          if (phoneNumber != null && phoneNumber is String) {
            suggestions.add(phoneNumber);
          }
        }

        // Filter the suggestions based on the current query
        final filteredSuggestions = query.isEmpty
            ? []
            : suggestions.where((suggestion) {
                return suggestion.toLowerCase().contains(query.toLowerCase());
              }).toList();

        return ListView.builder(
          itemCount: filteredSuggestions.length,
          itemBuilder: (context, index) {
            final suggestion = filteredSuggestions[index];
            return ListTile(
              title: Text(suggestion),
              onTap: () {
                query = suggestion;
                onSuggestionClicked(
                    suggestion); // Call the callback when suggestion is tapped
                context.read<AuthService>().searchQuery = query;
                context.read<AuthService>().searchResult = true;
                close(context, null);
              },
            );
          },
        );
      },
    );
  }
}

class ClientData {
  final String name;
  final String phoneNumber;

  ClientData({
    required this.name,
    required this.phoneNumber,
  });
}

class Billing extends StatefulWidget {
  const Billing({super.key});

  @override
  State<Billing> createState() => _BillingState();
}

class _BillingState extends State<Billing> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ClientData? _clientData; // Create a variable to store client data
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  String name = "";
  String phoneNumber = "";
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

  List<String> selectedItems = []; // List to store selected checkbox items
  List<String> allItems = []; // List to store all available items
  List<String> filteredItems = [];
  // Define a map to store service prices
  Map<String, double> servicePrices = {
    'Haircut': 10.0, // Replace with actual prices for your services
    'Hair Color': 20.0,
    'Manicure': 15.0,
    'Pedicure': 25.0,
    'Facial': 30.0,
    'Massage': 20.0,
  };

  double discountPercentage = 0.0;
  TextEditingController discountController = TextEditingController();

  // Function to calculate the total
  double calculateTotal() {
    double total = 0.0;

    // Calculate the total of selected services
    for (final item in selectedItems) {
      if (servicePrices.containsKey(item)) {
        total += servicePrices[item]!;
      }
    }

    // Apply the discount
    total = total - discountPercentage;

    return total;
  }

  @override
  void initState() {
    super.initState();

    // Initialize the list of allItems (e.g., load data from a source)
    allItems = [
      'Haircut',
      'Hair Color',
      'Manicure',
      'Pedicure',
      'Facial',
      'Massage',
    ];
    filteredItems = allItems; // List to store filtered items
  }

  @override
  void dispose() {
    // Dispose of the discountController when the widget is disposed
    discountController.dispose();
    super.dispose();
  }

  void _onSearchQueryChanged(bool result, String query) async {
    if (result && query.isNotEmpty) {
      try {
        final ClientData clientData =
            await ClientService().getClientDataByPhoneNumber(query);

        setState(() {
          _clientData = clientData;
        });
      } catch (error) {
        print("Error: $error");
      }
    } else {
      setState(() {
        _clientData = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: _clientData != null
            ? Text('Billing for Client ${_clientData!.name}')
            : const Text('Choose a client through search'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(
              Icons.arrow_back), // You can change this icon as needed
          onPressed: () {
            context.read<AuthService>().searchResult = false;
            context.read<AuthService>().searchQuery = "";
            Navigator.pop(scaffoldKey.currentContext!);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              name = '';
              phoneNumber = '';
              showSearch(
                context: context,
                delegate: MySearchDelegate(
                  onSuggestionClicked: (selectedSuggestion) async {
                    phoneNumber = selectedSuggestion;
                    final querySnapshot = await FirebaseFirestore.instance
                        .collection('Clients')
                        .where('phoneNumber', isEqualTo: selectedSuggestion)
                        .get();
                    if (querySnapshot.docs.isNotEmpty) {
                      name = querySnapshot.docs.first['name'];
                      setState(() {
                        _clientData = ClientData(
                            name: name, phoneNumber: selectedSuggestion);
                      });
                      _onSearchQueryChanged(true, selectedSuggestion);
                    } else {
                      print(
                          'No matching document found for phone number: $selectedSuggestion');
                    }
                  },
                  clearClientData: () {
                    setState(() {
                      _clientData = null; // Clear _clientData
                    });
                  },
                ),
              );
            },
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),
      body: context.watch<AuthService>().searchResult || name.isNotEmpty
          ? SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.watch<AuthService>().searchResult
                                ? 'Client Name: ${_clientData!.name}'
                                : 'Client Name: $name',
                            style: TextStyle(
                                fontSize: isWeb(context) ? w / 80 : w / 20),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            context.watch<AuthService>().searchResult
                                ? 'Phone Number: ${_clientData!.phoneNumber}'
                                : 'Phone Number: $phoneNumber',
                            style: TextStyle(
                                fontSize: isWeb(context) ? w / 80 : w / 20),
                          ),
                          // Display other client information as needed
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Select Services',
                            style: TextStyle(
                                fontSize: isWeb(context) ? w / 80 : w / 20),
                          ),
                          TextField(
                            onChanged: (query) {
                              setState(() {
                                // Filter the available items based on the query
                                filteredItems = allItems.where((item) {
                                  return item
                                      .toLowerCase()
                                      .contains(query.toLowerCase());
                                }).toList();
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Search Services',
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),

                          const SizedBox(height: 10),
                          // Display the list of available items
                          for (final item in filteredItems)
                            CheckboxListTile(
                              title: Text(item),
                              value: selectedItems.contains(item),
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    selectedItems.add(item);
                                  } else {
                                    selectedItems.remove(item);
                                  }
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Row(
                      children: [
                        //discount given with a percentage icon
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: discountController,
                              keyboardType: TextInputType
                                  .number, // Allow only numeric input
                              onChanged: (value) {
                                setState(() {
                                  // Update the discountPercentage when the TextField changes
                                  discountPercentage =
                                      double.tryParse(value) ?? 0.0;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Discount Percentage',
                                labelStyle: TextStyle(
                                  fontSize: isWeb(context) ? w / 80 : w / 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.percent),
                        ),
                      ],
                    ),
                  ),
                  // Display the total
                  Text(
                    'Total: \$${calculateTotal().toStringAsFixed(2)}', // Format to 2 decimal places
                    style: TextStyle(
                      fontSize: isWeb(context) ? w / 80 : w / 20,
                    ),
                  ),
                ],
              ),
            )
          : const Center(
              child: Text(
                'Billing Page',
                style: TextStyle(fontSize: 24),
              ),
            ),
      floatingActionButton:
          !context.watch<AuthService>().searchResult && name.isEmpty
              ? FloatingActionButton(
                  onPressed: () {
                    nameController.clear();
                    phoneNumberController.clear();
                    _showAddClientDialog();
                  },
                  child: const Icon(Icons.add),
                )
              : FloatingActionButton(
                  onPressed: () {
                    final visitDate = DateTime.now();
                    final selectedServicesMap = <String, double>{};

                    // Populate the selected services map with their prices
                    for (final serviceName in selectedItems) {
                      if (servicePrices.containsKey(serviceName)) {
                        selectedServicesMap[serviceName] =
                            servicePrices[serviceName]!;
                      }
                    }
                    print("_________________________");
                    print(phoneNumber);
                    print(name);
                    print(visitDate);
                    print(selectedItems);
                    print(calculateTotal().toStringAsFixed(2));
                    print("_________________________");
                    ClientService().clientEngagement(
                      phoneNumber,
                      name,
                      visitDate,
                      selectedItems,
                      calculateTotal().toStringAsFixed(2),
                    );

                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => BillingGeneration(
                        discount: discountPercentage,
                        servicePrices: selectedServicesMap,
                      ),
                    ));
                  },
                  child: const Icon(Icons.arrow_forward),
                ),
    );
  }

  Future<void> _showAddClientDialog() async {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    await showDialog(
      context: scaffoldKey.currentContext!,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInsideDialog) {
            return AlertDialog(
              title: Text(
                'Add Client',
                style: TextStyle(
                  fontSize: isWeb(context) ? w / 80 : w / 20,
                ),
              ),
              content: SizedBox(
                width: w * 0.2,
                height: h * 0.2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(
                          fontSize: isWeb(context) ? w / 80 : w / 20,
                        ),
                      ),
                    ),
                    TextField(
                      controller: phoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(
                          fontSize: isWeb(context) ? w / 80 : w / 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(scaffoldKey.currentContext!);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: isWeb(context) ? w / 80 : w / 20,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Create a new client
                    setState(() {
                      name = nameController.text;
                      phoneNumber = phoneNumberController.text;
                    });
                    Navigator.pop(scaffoldKey.currentContext!);
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(
                      fontSize: isWeb(context) ? w / 80 : w / 20,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

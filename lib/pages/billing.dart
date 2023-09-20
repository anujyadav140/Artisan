import 'package:artisan/services/authentication/auth_service.dart';
import 'package:artisan/services/client_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MySearchDelegate extends SearchDelegate {
  final Function(String) onSuggestionClicked; // Callback function

  MySearchDelegate({required this.onSuggestionClicked});
  @override
  Widget? buildLeading(BuildContext context) => IconButton(
      onPressed: () {
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
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MySearchDelegate(
                  onSuggestionClicked: (selectedSuggestion) {
                    _onSearchQueryChanged(true,
                        selectedSuggestion); // Call the method with the selected suggestion
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
      body: _clientData != null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
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
                        'Client Name: ${_clientData!.name}',
                        style: TextStyle(
                            fontSize: isWeb(context) ? w / 80 : w / 20),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Phone Number: ${_clientData!.phoneNumber}',
                        style: TextStyle(
                            fontSize: isWeb(context) ? w / 80 : w / 20),
                      ),
                      // Display other client information as needed
                    ],
                  ),
                ),
              ),
            )
          : const Center(
              child: Text(
                'Billing Page',
                style: TextStyle(fontSize: 24),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          nameController.clear();
          phoneNumberController.clear();

          _showAddClientDialog();
        },
        child: const Icon(Icons.add),
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
                    Navigator.of(scaffoldKey.currentContext!)
                        .pop(); // Close the dialog
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
                    final name = nameController.text;
                    final phoneNumber = phoneNumberController.text;

                    // Add a new client
                    final visitDate = DateTime.now().toString();
                    ClientService()
                        .clientEngagement(phoneNumber, name, visitDate, [], "");

                    Navigator.of(scaffoldKey.currentContext!)
                        .pop(); // Close the dialog
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

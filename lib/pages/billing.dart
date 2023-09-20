import 'package:artisan/pages/client.dart';
import 'package:artisan/services/authentication/auth_service.dart';
import 'package:artisan/services/client_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    context.read<AuthService>().addListener(_onSearchQueryChanged);
  }

  @override
  void dispose() {
    super.dispose();
    context.read<AuthService>().removeListener(_onSearchQueryChanged);
  }

  void _onSearchQueryChanged() async {
    final authService = context.read<AuthService>();
    if (authService.searchResult && authService.searchQuery.isNotEmpty) {
      try {
        final ClientData clientData =
            await ClientService().getClientDataByPhoneNumber(
          authService.searchQuery,
        );

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
      appBar: AppBar(
        title: _clientData != null
            ? Text('Billing for Client ${_clientData!.name}')
            : const Text('Choose a client through search'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MySearchDelegate(),
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
      context: context,
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
                    if (mounted) {
                      Navigator.of(context).pop(); // Close the dialog
                    }
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
                    if (mounted) {
                      // Create a new client
                      final name = nameController.text;
                      final phoneNumber = phoneNumberController.text;

                      // Add a new client
                      final visitDate = DateTime.now().toString();
                      ClientService().clientEngagement(
                          phoneNumber, name, visitDate, [], "");

                      Navigator.of(context).pop(); // Close the dialog
                    }
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

import 'package:flutter/material.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({Key? key}) : super(key: key);

  @override
  _ClientPageState createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  List<Client> clients = [];
  // Sample list of salon services
  static List<String> salonServices = [
    'Haircut',
    'Hair Color',
    'Manicure',
    'Pedicure',
    'Facial',
    'Massage',
  ];

  // Map to store the checked state of each service
  Map<String, bool> serviceCheckboxes = {};

  // Text editing controllers for the name and phone number fields
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  // Index of the client being edited
  int editingIndex = -1;

  @override
  void initState() {
    super.initState();
    // Initialize all services as unchecked
    for (String service in salonServices) {
      serviceCheckboxes[service] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Page'),
      ),
      body: ListView.builder(
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final client = clients[index];
          return _buildClientListItem(client, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Reset the editing index and clear text fields
          editingIndex = -1;
          nameController.clear();
          phoneNumberController.clear();
          // Reset service checkboxes
          setState(() {
            for (String service in salonServices) {
              serviceCheckboxes[service] = false;
            }
          });
          _showAddClientDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildClientListItem(Client client, int index) {
    return ListTile(
      title: Text(client.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Phone Number: ${client.phoneNumber}'),
          Text('Last Visit Date: ${client.lastVisitDate}'),
          Text('Services: ${client.services.join(", ")}'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              // Handle client history button click here
            },
            child: Text('Client History'),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              // Set editing index and populate the text fields
              editingIndex = index;
              nameController.text = client.name;
              phoneNumberController.text = client.phoneNumber;
              // Check the appropriate service checkboxes
              for (String service in salonServices) {
                serviceCheckboxes[service] = client.services.contains(service);
              }
              _showAddClientDialog();
            },
            child: Text('Edit'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddClientDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInsideDialog) {
            return AlertDialog(
              title: Text(editingIndex == -1 ? 'Add Client' : 'Edit Client'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: phoneNumberController,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                  ),
                  // Add checkboxes for services
                  for (String service in salonServices)
                    CheckboxListTile(
                      title: Text(service),
                      value: serviceCheckboxes[service] ?? false,
                      onChanged: (bool? value) {
                        setStateInsideDialog(() {
                          serviceCheckboxes[service] = value ?? false;
                        });
                      },
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Create a new client or update the existing one
                    final name = nameController.text;
                    final phoneNumber = phoneNumberController.text;
                    final lastVisitDate =
                        DateTime.now().toString(); // Replace with actual logic
                    final selectedServiceList = <String>[];
                    // Collect the selected services
                    for (String service in salonServices) {
                      if (serviceCheckboxes[service] ?? false) {
                        selectedServiceList.add(service);
                      }
                    }

                    if (editingIndex == -1) {
                      // Add a new client
                      setState(() {
                        clients.add(Client(
                          name,
                          phoneNumber,
                          lastVisitDate,
                          selectedServiceList,
                        ));
                      });
                    } else {
                      // Edit an existing client
                      setState(() {
                        clients[editingIndex] = Client(
                          name,
                          phoneNumber,
                          lastVisitDate,
                          selectedServiceList,
                        );
                      });
                    }

                    // Reset editing index and text fields
                    editingIndex = -1;
                    nameController.clear();
                    phoneNumberController.clear();
                    // Reset service checkboxes
                    for (String service in salonServices) {
                      serviceCheckboxes[service] = false;
                    }

                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text(editingIndex == -1 ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class Client {
  final String name;
  final String phoneNumber;
  final String lastVisitDate;
  final List<String> services;

  Client(this.name, this.phoneNumber, this.lastVisitDate, this.services);
}

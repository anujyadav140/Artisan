import 'package:flutter/material.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  _ClientPageState createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  List<Client> clients = [];

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
          return _buildClientListItem(client);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClientDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildClientListItem(Client client) {
    return ListTile(
      title: Text(client.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Phone Number: ${client.phoneNumber}'),
          Text('Last Visit Date: ${client.lastVisitDate}'),
        ],
      ),
      trailing: ElevatedButton(
        onPressed: () {
          // Handle client history button click here
        },
        child: Text('Client History'),
      ),
    );
  }

  Future<void> _showAddClientDialog() async {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneNumberController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Client'),
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
                // Add the new client to the list
                final name = nameController.text;
                final phoneNumber = phoneNumberController.text;
                final lastVisitDate = DateTime.now()
                    .toString(); // You can replace this with the actual last visit date logic
                setState(() {
                  clients.add(Client(name, phoneNumber, lastVisitDate));
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class Client {
  final String name;
  final String phoneNumber;
  final String lastVisitDate;

  Client(this.name, this.phoneNumber, this.lastVisitDate);
}

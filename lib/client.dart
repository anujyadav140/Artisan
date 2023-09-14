import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
  List<List<String>> pastServices = [];
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
          Text('Last Visit Date: ${client.visitDates}'),
          Text('Services: ${client.pastServices.join(", ")}'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              _showClientHistoryDialog(client); // Show client history dialog
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
                serviceCheckboxes[service] =
                    client.pastServices.contains(service);
              }
              _showAddClientDialog();
            },
            child: Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _showClientHistoryDialog(Client client) {
    showDialog(
      context: context,
      builder: (context) {
        double w = MediaQuery.of(context).size.width;
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Client History'),
              ElevatedButton(
                onPressed: () {
                  // Show the statistics popup
                  Navigator.of(context)
                      .pop(); // Close the client history dialog
                  _showStatisticsDialog(client);
                },
                child: Text('Statistics'),
              ),
            ],
          ),
          content: Container(
            width: w * 0.4,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (int i = 0; i < client.visitDates.length; i++)
                    _buildVisitCard(
                        client.visitDates[i], client.pastServices[i]),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showStatisticsDialog(Client client) {
    // Calculate and display statistics here
    // You can customize this dialog as needed for your statistics
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Statistics'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Client Name: ${client.name}'),
              Text('Total Visits: ${client.visitDates.length}'),
              SizedBox(
                height: 200,
                width: 300,
                child: PieChart(
                  PieChartData(
                    sections: _generatePieChartSections(client),
                  ),
                  swapAnimationDuration:
                      Duration(milliseconds: 150), // Optional
                  swapAnimationCurve: Curves.linear, // Optional
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // List<PieChartSectionData> _generatePieChartSections(Client client) {
  //   // Calculate data for PieChart sections
  //   // You can customize this as per your statistics logic
  //   final totalVisits = client.visitDates.length;
  //   final pastServicesCount = client.pastServices.length;

  //   // For simplicity, we'll create two sections: Visits and Past Services
  //   final List<PieChartSectionData> sections = [
  //     PieChartSectionData(
  //       title: 'Visits',
  //       value: totalVisits.toDouble(),
  //       color: Colors.blue,
  //       radius: 40,
  //     ),
  //     PieChartSectionData(
  //       title: 'Past Services',
  //       value: pastServicesCount.toDouble(),
  //       color: Colors.green,
  //       radius: 40,
  //     ),
  //   ];

  //   return sections;
  // }

  List<PieChartSectionData> _generatePieChartSections(Client client) {
    // Calculate data for PieChart sections based on most frequently taken services
    // You can customize this as per your statistics logic

    // Create a map to count the frequency of each service
    final Map<String, int> serviceFrequency = {};

    // Iterate through each visit's past services and count their frequency
    for (final visitServices in client.pastServices) {
      for (final service in visitServices) {
        serviceFrequency[service] = (serviceFrequency[service] ?? 0) + 1;
      }
    }

    // Sort services by frequency in descending order
    final sortedServices = serviceFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Create PieChart sections based on the most frequently taken services
    final List<PieChartSectionData> sections = [];
    final List<Color> sectionColors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      // Add more colors as needed
    ];

    // Add the most frequently taken services to PieChart sections
    for (int i = 0;
        i < sortedServices.length && i < sectionColors.length;
        i++) {
      final service = sortedServices[i].key;
      final frequency = sortedServices[i].value;
      sections.add(
        PieChartSectionData(
          title: service,
          value: frequency.toDouble(),
          color: sectionColors[i],
          radius: 40,
        ),
      );
    }

    return sections;
  }

  Widget _buildVisitCard(String visitDate, List<String> pastServices) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Visit Date: $visitDate'),
            Text('Past Services: ${pastServices.join(", ")}'),
          ],
        ),
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
                        final visitDate = DateTime.now().toString();
                        clients.add(Client(
                          name,
                          phoneNumber,
                          [visitDate], // Add the new visit date
                          [selectedServiceList],
                        ));
                      });
                    } else {
                      // Edit an existing client
                      final visitDate = DateTime.now().toString();
                      clients[editingIndex]
                          .visitDates
                          .add(visitDate); // Add the new visit date

                      // If there are past services, add them to the existing ones
                      if (clients[editingIndex].pastServices != null) {
                        clients[editingIndex]
                            .pastServices
                            .add(selectedServiceList);
                      } else {
                        clients[editingIndex].pastServices = [
                          selectedServiceList
                        ];
                      }

                      setState(() {
                        // No need to recreate the entire Client object, just update visitDates and pastServices
                        clients[editingIndex].visitDates =
                            clients[editingIndex].visitDates;
                        clients[editingIndex].pastServices =
                            clients[editingIndex].pastServices;
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
  List<dynamic> visitDates; // Updated to store all visit dates
  List<List<String>> pastServices; // Updated to store past services

  Client(this.name, this.phoneNumber, this.visitDates, this.pastServices);
}

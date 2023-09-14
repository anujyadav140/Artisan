import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({Key? key}) : super(key: key);

  @override
  _ClientPageState createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  List<Client> clients = [];
  var money = '';
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
          Text('Amount Last Spent: ${client.pastAmounts}'),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    _showClientHistoryDialog(
                        client); // Show client history dialog
                  },
                  child: Text('Client History'),
                ),
              ),
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
                child: Text('Update'),
              ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Add your reminder functionality here
              // This can open a dialog or navigate to a reminder setup page, for example.
            },
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
                    _buildVisitCard(client.visitDates[i],
                        client.pastServices[i], client.pastAmounts[i]),
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
    List<dynamic> _generateLineChartData(List<dynamic> pastAmounts) {
      final List<dynamic> data = [];
      for (int i = 0; i < pastAmounts.length; i++) {
        final double y = double.parse(pastAmounts[i].toString());
        final String x = client.visitDates[i];
        data.add({'date': x, 'amount': y});
      }
      return data;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Statistics'),
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
                  swapAnimationDuration: const Duration(milliseconds: 150),
                  swapAnimationCurve: Curves.linear,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 200,
                width: 300,
                child: SfCartesianChart(
                  title: ChartTitle(text: 'Client Spending Over Time'),
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(
                    title: AxisTitle(text: 'Amount Spent'),
                  ),
                  series: <ChartSeries>[
                    LineSeries<dynamic, String>(
                      dataSource: _generateLineChartData(client.pastAmounts),
                      xValueMapper: (dynamic data, _) => data['date'],
                      yValueMapper: (dynamic data, _) => data['amount'],
                    ),
                  ],
                ),
              )
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

  List<FlSpot> _generateLineChartSpots(List<dynamic> pastAmounts) {
    // Generate FlSpot data for the LineChart from pastAmounts
    final List<FlSpot> spots = [];

    for (int i = 0; i < pastAmounts.length; i++) {
      final double x = i.toDouble();
      final double y = double.parse(pastAmounts[i].toString());
      spots.add(FlSpot(x, y));
    }

    return spots;
  }

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

  Widget _buildVisitCard(
      String visitDate, List<String> pastServices, String pastAmounts) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Visit Date: $visitDate'),
            Text('Past Services: ${pastServices.join(", ")}'),
            Text('Amount Spent: $pastAmounts'),
          ],
        ),
      ),
    );
  }

  double calculateTotalSpend(List<String> selectedServices) {
    // Define the prices for each service
    final Map<String, double> servicePrices = {
      'Haircut': 20.0,
      'Hair Color': 50.0,
      'Manicure': 15.0,
      'Pedicure': 20.0,
      'Facial': 30.0,
      'Massage': 40.0,
    };

    double totalSpend = 0.0;

    for (String service in selectedServices) {
      if (servicePrices.containsKey(service)) {
        totalSpend += servicePrices[service]!;
      }
    }

    return totalSpend;
  }

  Future<void> _showAddClientDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInsideDialog) {
            money = calculateTotalSpend(serviceCheckboxes.keys
                    .where((key) => serviceCheckboxes[key]!)
                    .toList())
                .toStringAsFixed(2);
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
                  Text(
                    'Total Spend: \$${calculateTotalSpend(serviceCheckboxes.keys.where((key) => serviceCheckboxes[key]!).toList()).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
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
                          [money],
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
                      if (clients[editingIndex].pastAmounts != null) {
                        clients[editingIndex].pastAmounts.add(money);
                      } else {
                        clients[editingIndex].pastAmounts = [money];
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
  List<dynamic> pastAmounts;
  Client(this.name, this.phoneNumber, this.visitDates, this.pastServices,
      this.pastAmounts);
}

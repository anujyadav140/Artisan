import 'package:artisan/services/authentication/auth_service.dart';
import 'package:artisan/services/client_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
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
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Clients').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Loading indicator while data is being fetched.
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text('No data available'); // Handle empty data.
            }
            var clientData = snapshot.data!.docs;

            return ListView.builder(
              itemCount: clientData.length,
              itemBuilder: (context, index) {
                var clientData = snapshot.data!.docs;
                return Column(children: [
                  _buildClientListItem(clientData, index),
                  const Divider(),
                ]);
              },
            );
          }),
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

  Widget _buildClientListItem(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> clientData, int index) {
    var client = clientData[index].data();
    Map<String, dynamic> visits = client['visits'];

// Variables to store the extracted data
    List<String> visitDates = [];
    List<Map<String, dynamic>> visitDataList = [];

    // Sort the visits Map by date
    List<MapEntry<String, dynamic>> sortedVisits = visits.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

// Clear existing data in visitDates and visitDataList
    visitDates.clear();
    visitDataList.clear();

// Populate visitDates and visitDataList with sorted data
    for (var entry in sortedVisits) {
      visitDates.add(entry.key);
      visitDataList.add(Map<String, dynamic>.from(entry.value));
    }

    String name = client['name'];
    String phoneNumber = client['phoneNumber'];
    String latestDate = visitDates.last;

    List<String> amounts = [];
    List<List<String>> servicesList = [];

    for (Map<String, dynamic> visitData in visitDataList) {
      String amount = visitData['amount'];
      List<String> services = List<String>.from(visitData['services']);

      amounts.add(amount);
      servicesList.add(services);
    }
    print(amounts);
    print(servicesList);
    String latestSpentAmount = amounts.last;
    List<String> latestServicesAvailed = servicesList.last;
    return ListTile(
      title: Text(name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Phone Number: $phoneNumber'),
          Text('Last Visit Date: $latestDate'),
          Text('Services: ${latestServicesAvailed.join(", ")}'),
          Text('Amount Last Spent: $latestSpentAmount'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    _showClientHistoryDialog(name, visitDates, servicesList,
                        amounts); // Show client history dialog
                  },
                  child: Text('Client History'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Set editing index and populate the text fields
                  editingIndex = index;
                  nameController.text = name;
                  phoneNumberController.text = phoneNumber;
                  // Check the appropriate service checkboxes
                  for (String service in salonServices) {
                    serviceCheckboxes[service] = false;
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
            icon: Icon(
              Icons.access_alarm_outlined,
              color: Colors.deepPurple,
            ),
            onPressed: () {
              // Add your reminder functionality here
              // This can open a dialog or navigate to a reminder setup page, for example.
            },
          ),
        ],
      ),
    );
  }

  void _showClientHistoryDialog(String name, List<String> visitDates,
      List<List<String>> servicesList, List<String> amounts) {
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
                  _showStatisticsDialog(
                      name, visitDates, amounts, servicesList);
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
                  for (int i = 0; i < visitDates.length; i++)
                    _buildVisitCard(visitDates[i], servicesList[i], amounts[i]),
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

  void _showStatisticsDialog(String name, List<String> visitDates,
      List<String> pastAmounts, List<List<String>> servicesList) {
    List<dynamic> _generateLineChartData(List<dynamic> pastAmounts) {
      final List<dynamic> data = [];
      for (int i = 0; i < pastAmounts.length; i++) {
        final double y = double.parse(pastAmounts[i].toString());
        final dynamic x = (i + 1).toString();
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
              Text('Client Name: $name'),
              Text('Total Visits: ${visitDates.length}'),
              SizedBox(
                height: 200,
                width: 300,
                child: PieChart(
                  PieChartData(
                    sections: _generatePieChartSections(servicesList),
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
                  borderColor: Colors.deepPurple,
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(
                    title: AxisTitle(text: 'Amount Spent'),
                  ),
                  series: <ChartSeries>[
                    LineSeries<dynamic, String>(
                      dataSource: _generateLineChartData(pastAmounts),
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

  List<PieChartSectionData> _generatePieChartSections(
      List<List<String>> pastServices) {
    // Calculate data for PieChart sections based on most frequently taken services
    // You can customize this as per your statistics logic

    // Create a map to count the frequency of each service
    final Map<String, int> serviceFrequency = {};

    // Iterate through each visit's past services and count their frequency
    for (final visitServices in pastServices) {
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
      const Color.fromRGBO(179, 157, 219, 1),
      const Color.fromRGBO(126, 87, 194, 1),
      const Color.fromRGBO(94, 53, 177, 1),
      const Color.fromRGBO(69, 39, 160, 1),
      const Color.fromRGBO(49, 27, 146, 1),
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
                      final visitDate = DateTime.now().toString();
                      ClientService().clientEngagement(phoneNumber, name,
                          visitDate, selectedServiceList, money);
                    } else {
                      // Edit an existing client
                      final visitDate = DateTime.now().toString();
                      ClientService().clientEngagement(phoneNumber, name,
                          visitDate, selectedServiceList, money);
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
  List<dynamic> visitDates;
  List<List<String>> pastServices;
  List<dynamic> pastAmounts;
  Client(this.name, this.phoneNumber, this.visitDates, this.pastServices,
      this.pastAmounts);
}

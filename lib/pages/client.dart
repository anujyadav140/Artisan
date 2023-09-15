import 'package:artisan/services/authentication/auth_service.dart';
import 'package:artisan/services/client_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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

  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'Client Page',
          style: TextStyle(
            fontSize: _ClientPageState().isWeb(context) ? w / 80 : w / 20,
          ),
        ),
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
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    var client = clientData[index].data();
    DateTime dateTime = DateTime(now.year, now.month, now.day);
    Map<String, dynamic> visits = client['visits'];
    Future<DateTime?> pickDate() => showDatePicker(
        context: context,
        initialDate: dateTime,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
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
    String latestSpentAmount = amounts.last;
    List<String> latestServicesAvailed = servicesList.last;
    List<DateTime> dateTimes = [];
    return ListTile(
      title: Text(
        name,
        style: TextStyle(
          fontSize: _ClientPageState().isWeb(context) ? w / 80 : w / 30,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phone Number: $phoneNumber',
            style: TextStyle(
              fontSize: _ClientPageState().isWeb(context) ? w / 80 : w / 30,
            ),
          ),
          Text(
            'Last Visit Date: $latestDate',
            style: TextStyle(
              fontSize: _ClientPageState().isWeb(context) ? w / 80 : w / 30,
            ),
          ),
          Text(
            'Services: ${latestServicesAvailed.join(", ")}',
            style: TextStyle(
              fontSize: _ClientPageState().isWeb(context) ? w / 80 : w / 30,
            ),
          ),
          Text(
            'Amount Last Spent: $latestSpentAmount',
            style: TextStyle(
              fontSize: _ClientPageState().isWeb(context) ? w / 80 : w / 30,
            ),
          ),
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
                  child: Text(
                    'Client History',
                    style: TextStyle(
                      fontSize:
                          _ClientPageState().isWeb(context) ? w / 80 : w / 30,
                    ),
                  ),
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
                child: Text(
                  'Update',
                  style: TextStyle(
                    fontSize:
                        _ClientPageState().isWeb(context) ? w / 80 : w / 30,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(
              Icons.access_alarm_outlined,
              color: Colors.deepPurple,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: Text(
                          'Reminder',
                          style: TextStyle(
                            fontSize: isWeb(context) ? w / 80 : w / 30,
                          ),
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        content: SizedBox(
                          width: w * 0.4,
                          height: h * 0.4,
                          child: Column(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final date = await pickDate();
                                  if (date != null) {
                                    setState(() {
                                      dateTimes.add(date);
                                    });
                                  }
                                },
                                icon: Icon(Icons.add),
                                label: Text('Add'),
                              ),
                              SizedBox(height: 20),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: dateTimes.length,
                                  itemBuilder: (context, index) {
                                    final dateTime = dateTimes[index];
                                    return Card(
                                      child: ListTile(
                                        title: Text(
                                          '${dateTime.day}/${dateTime.month}/${dateTime.year}',
                                          style: TextStyle(
                                            fontSize: isWeb(context)
                                                ? w / 60
                                                : w / 30,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            setState(() {
                                              dateTimes.removeAt(index);
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
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
              Text(
                'Client History',
                style: TextStyle(
                  fontSize: _ClientPageState().isWeb(context) ? w / 60 : w / 30,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Show the statistics popup
                  _showStatisticsDialog(
                      name, visitDates, amounts, servicesList);
                },
                child: Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize:
                        _ClientPageState().isWeb(context) ? w / 60 : w / 30,
                  ),
                ),
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
              child: Text(
                'Close',
                style: TextStyle(
                  fontSize: _ClientPageState().isWeb(context) ? w / 60 : w / 30,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showStatisticsDialog(String name, List<String> visitDates,
      List<String> pastAmounts, List<List<String>> servicesList) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
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
          title: Text(
            'Statistics',
            style: TextStyle(
              fontSize: _ClientPageState().isWeb(context) ? w / 60 : w / 30,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Client Name: $name',
                style: TextStyle(
                  fontSize: _ClientPageState().isWeb(context) ? w / 60 : w / 30,
                ),
              ),
              Text(
                'Total Visits: ${visitDates.length}',
                style: TextStyle(
                  fontSize: _ClientPageState().isWeb(context) ? w / 60 : w / 30,
                ),
              ),
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
                  title: ChartTitle(
                    text: 'Client Spending Over Time',
                    textStyle: TextStyle(
                      fontSize:
                          _ClientPageState().isWeb(context) ? w / 100 : w / 30,
                    ),
                  ),
                  borderColor: Colors.deepPurple,
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(
                    title: AxisTitle(
                      text: 'Amount Spent',
                      textStyle: TextStyle(
                        fontSize: _ClientPageState().isWeb(context)
                            ? w / 100
                            : w / 30,
                      ),
                    ),
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
              child: Text(
                'Close',
                style: TextStyle(
                  fontSize: _ClientPageState().isWeb(context) ? w / 60 : w / 30,
                ),
              ),
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
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
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
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visit Date: $visitDate',
              style: TextStyle(
                fontSize: _ClientPageState().isWeb(context) ? w / 60 : w / 30,
              ),
            ),
            Text(
              'Past Services: ${pastServices.join(", ")}',
              style: TextStyle(
                fontSize: _ClientPageState().isWeb(context) ? w / 60 : w / 30,
              ),
            ),
            Text(
              'Amount Spent: $pastAmounts',
              style: TextStyle(
                fontSize: _ClientPageState().isWeb(context) ? w / 60 : w / 30,
              ),
            ),
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
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    await showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setStateInsideDialog) {
              money = calculateTotalSpend(serviceCheckboxes.keys
                      .where((key) => serviceCheckboxes[key]!)
                      .toList())
                  .toStringAsFixed(2);
              return AlertDialog(
                title: Text(
                  editingIndex == -1 ? 'Add Client' : 'Edit Client',
                  style: TextStyle(
                    fontSize:
                        _ClientPageState().isWeb(context) ? w / 60 : w / 30,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(
                          fontSize: _ClientPageState().isWeb(context)
                              ? w / 60
                              : w / 30,
                        ),
                      ),
                    ),
                    TextField(
                      controller: phoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(
                          fontSize: _ClientPageState().isWeb(context)
                              ? w / 60
                              : w / 30,
                        ),
                      ),
                    ),
                    // Add checkboxes for services
                    for (String service in salonServices)
                      CheckboxListTile(
                        title: Text(
                          service,
                          style: TextStyle(
                            fontSize: _ClientPageState().isWeb(context)
                                ? w / 60
                                : w / 30,
                          ),
                        ),
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
                        fontSize:
                            _ClientPageState().isWeb(context) ? w / 60 : w / 30,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize:
                            _ClientPageState().isWeb(context) ? w / 60 : w / 30,
                      ),
                    ),
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
                    child: Text(
                      editingIndex == -1 ? 'Add' : 'Save',
                      style: TextStyle(
                        fontSize:
                            _ClientPageState().isWeb(context) ? w / 60 : w / 30,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
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

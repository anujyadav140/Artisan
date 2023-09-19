import 'package:artisan/services/authentication/auth_service.dart';
import 'package:artisan/services/client_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/scheduler.dart';
import 'package:group_button/group_button.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import 'package:url_launcher/url_launcher.dart';

class MySearchDelegate extends SearchDelegate {
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
  Stream<QuerySnapshot<Map<String, dynamic>>>? streamData;
  @override
  void initState() {
    super.initState();
    // Initialize all services as unchecked
    for (String service in salonServices) {
      serviceCheckboxes[service] = false;
    }

    streamData = FirebaseFirestore.instance
        .collection('Clients')
        .orderBy('visits', descending: true)
        .snapshots();
  }

  DateTime now = DateTime.now();
  GroupButtonController groupButtonController = GroupButtonController(
    selectedIndex: 0,
  );
  List<String> filterOptions = [
    'All clients',
    'Latest visit date to oldest visit',
    'Oldest visit date to latest visit',
    'Within 2 days',
    'No reminder set'
  ];
  String selectedFilter = 'All clients';
  bool isReminderInFewDays = false;
  bool isNoReminderSet = false;
  Stream<QuerySnapshot<Map<String, dynamic>>>? streamDataFilterOptions(
      String selectedFilter) {
    switch (selectedFilter) {
      case 'All clients':
        SchedulerBinding.instance.addPostFrameCallback((_) {
          context.read<AuthService>().searchQuery = '';
          context.read<AuthService>().searchResult = false;
          groupButtonController = GroupButtonController(
            selectedIndex: 0,
          );
          isReminderInFewDays = false;
          isNoReminderSet = false;
          streamData = FirebaseFirestore.instance
              .collection('Clients')
              .orderBy('visits', descending: true)
              .snapshots();
        });
        break;
      case 'Latest visit date to oldest visit':
        SchedulerBinding.instance.addPostFrameCallback((_) {
          context.read<AuthService>().searchQuery = '';
          context.read<AuthService>().searchResult = false;
          groupButtonController = GroupButtonController(
            selectedIndex: 1,
          );
          isReminderInFewDays = false;
          isNoReminderSet = false;
          streamData = FirebaseFirestore.instance
              .collection('Clients')
              .orderBy('visits', descending: true)
              .snapshots();
        });
        break;
      case 'Oldest visit date to latest visit':
        SchedulerBinding.instance.addPostFrameCallback((_) {
          context.read<AuthService>().searchQuery = '';
          context.read<AuthService>().searchResult = false;
          groupButtonController = GroupButtonController(
            selectedIndex: 2,
          );
          isReminderInFewDays = false;
          isNoReminderSet = false;
          streamData = FirebaseFirestore.instance
              .collection('Clients')
              .orderBy('visits', descending: false)
              .snapshots();
        });
        break;
      case 'Within 2 days':
        SchedulerBinding.instance.addPostFrameCallback((_) {
          context.read<AuthService>().searchQuery = '';
          context.read<AuthService>().searchResult = false;
          groupButtonController = GroupButtonController(
            selectedIndex: 3,
          );
          isReminderInFewDays = true;
          isNoReminderSet = false;
          streamData = FirebaseFirestore.instance
              .collection('Clients')
              .orderBy('reminders', descending: true)
              .snapshots();
        });
        break;
      case 'No reminder set':
        SchedulerBinding.instance.addPostFrameCallback((_) {
          context.read<AuthService>().searchQuery = '';
          context.read<AuthService>().searchResult = false;
          groupButtonController = GroupButtonController(
            selectedIndex: 4,
          );
          isReminderInFewDays = false;
          isNoReminderSet = true;
          streamData = FirebaseFirestore.instance
              .collection('Clients')
              .orderBy('reminders', descending: true)
              .snapshots();
        });
        break;
      default:
        break;
    }
    return streamData;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final searchResult = context.watch<AuthService>().searchResult;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              groupButtonController = GroupButtonController(
                selectedIndex: 0,
              );
              selectedFilter = filterOptions[0];
              streamDataFilterOptions(selectedFilter);
              showSearch(context: context, delegate: MySearchDelegate());
            },
            icon: Icon(Icons.search),
          ),
        ],
        title: Text(
          'Client Page',
          style: TextStyle(
            fontSize: isWeb(context) ? w / 80 : w / 20,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal, // Enable horizontal scrolling
              children: [
                GroupButton(
                  isRadio: true,
                  controller: groupButtonController,
                  onSelected: (value, index, isSelected) {
                    setState(() {
                      selectedFilter = filterOptions[index];
                      streamDataFilterOptions(selectedFilter);
                    });
                  },
                  buttons: filterOptions,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: streamData,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No data available');
                }
                var clientData = snapshot.data!.docs;
                clientData = filtering(clientData);
                return ListView.builder(
                  itemCount: clientData.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        _buildClientListItem(clientData, index),
                        const Divider(),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
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
        child: const Icon(Icons.add),
      ),
    );
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> filtering(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> clientData,
  ) {
    if (selectedFilter == 'No reminder set') {
      clientData = clientData.where((client) {
        final data = client.data();
        final reminders = data['reminders'];
        return reminders == null || reminders.isEmpty;
      }).toList();
    } else if (selectedFilter == 'Within 2 days') {
      clientData = clientData.where((client) {
        if (client['reminders'] != null) {
          DateTime now = DateTime.now();
          DateTime twoDaysAhead = now.add(const Duration(days: 2));
          return client['reminders'].keys.any((key) {
            DateTime reminderDate = DateTime.parse(key.split(" ")[0]);
            return reminderDate.isBefore(twoDaysAhead);
          });
        }
        return false;
      }).toList();
    }
    return clientData;
  }

  Widget _buildClientListItem(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> clientData, int index) {
    final searchQuery = context.read<AuthService>().searchQuery;
    final searchResult = context.read<AuthService>().searchResult;
    if (searchResult) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        groupButtonController = GroupButtonController(
          selectedIndex: -1,
        );
        Future.delayed(const Duration(milliseconds: 1), () {
          setState(() {
            streamData = FirebaseFirestore.instance
                .collection('Clients')
                .where('phoneNumber', isEqualTo: searchQuery)
                .snapshots();
          });
        });
      });
    } else {
      streamDataFilterOptions(selectedFilter);
      clientData = filtering(clientData);
    }

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

    Future<TimeOfDay?> pickTime() => showTimePicker(
        context: context,
        initialTime: TimeOfDay(
            hour: DateTime.now().hour, minute: DateTime.now().minute));
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
                    'History',
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
          !isReminderInFewDays
              ? IconButton(
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
                                  fontSize: _ClientPageState().isWeb(context)
                                      ? w / 60
                                      : w / 30,
                                ),
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              content: SizedBox(
                                width: w * 0.4,
                                height: h * 0.6,
                                child: Column(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            DateTime selectedDate = DateTime
                                                .now(); // Initialize with the current date and time
                                            TimeOfDay selectedTime =
                                                TimeOfDay.now();
                                            List<String> selectedServices =
                                                []; // Initialize an empty list for selected services

                                            return StatefulBuilder(
                                              builder: (BuildContext context,
                                                  StateSetter setState) {
                                                return AlertDialog(
                                                  title: Text(
                                                    'Add Reminders',
                                                    style: TextStyle(
                                                      fontSize: isWeb(context)
                                                          ? w / 80
                                                          : w / 30,
                                                    ),
                                                  ),
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(10.0),
                                                    ),
                                                  ),
                                                  content: SizedBox(
                                                    width: w * 0.4,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Date:',
                                                          style: TextStyle(
                                                            fontSize:
                                                                isWeb(context)
                                                                    ? w / 80
                                                                    : w / 30,
                                                          ),
                                                        ),
                                                        ElevatedButton.icon(
                                                          onPressed: () async {
                                                            final date =
                                                                await pickDate();
                                                            if (date != null) {
                                                              setState(() {
                                                                selectedDate =
                                                                    date;
                                                              });
                                                            }
                                                          },
                                                          icon: const Icon(Icons
                                                              .calendar_today),
                                                          label: Text(
                                                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  isWeb(context)
                                                                      ? w / 60
                                                                      : w / 30,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'Time:',
                                                          style: TextStyle(
                                                            fontSize:
                                                                isWeb(context)
                                                                    ? w / 80
                                                                    : w / 30,
                                                          ),
                                                        ),
                                                        ElevatedButton.icon(
                                                          onPressed: () async {
                                                            // Inside your onPressed method
                                                            final time =
                                                                await pickTime();
                                                            if (time != null) {
                                                              setState(() {
                                                                selectedTime = TimeOfDay(
                                                                    hour: time
                                                                        .hour,
                                                                    minute: time
                                                                        .minute);
                                                              });
                                                            }
                                                          },
                                                          icon: const Icon(Icons
                                                              .access_time),
                                                          label: Text(
                                                            selectedTime.format(
                                                                context),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  isWeb(context)
                                                                      ? w / 60
                                                                      : w / 30,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'Select Services:',
                                                          style: TextStyle(
                                                            fontSize:
                                                                isWeb(context)
                                                                    ? w / 80
                                                                    : w / 30,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: ListView(
                                                            children:
                                                                _ClientPageState
                                                                    .salonServices
                                                                    .map(
                                                                        (service) {
                                                              return CheckboxListTile(
                                                                title: Text(
                                                                    service),
                                                                value: selectedServices
                                                                    .contains(
                                                                        service),
                                                                onChanged:
                                                                    (bool?
                                                                        value) {
                                                                  setState(() {
                                                                    if (value !=
                                                                        null) {
                                                                      if (value) {
                                                                        selectedServices
                                                                            .add(service); // Check the checkbox
                                                                      } else {
                                                                        selectedServices
                                                                            .remove(service); // Uncheck the checkbox
                                                                      }
                                                                    }
                                                                  });
                                                                },
                                                              );
                                                            }).toList(),
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                ClientService().addReminderToClient(
                                                                    phoneNumber,
                                                                    selectedDate,
                                                                    selectedTime,
                                                                    selectedServices);
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(); // Close this dialog
                                                              },
                                                              child: Text(
                                                                'OK',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: _ClientPageState()
                                                                          .isWeb(
                                                                              context)
                                                                      ? w / 60
                                                                      : w / 30,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(); // Close this dialog
                                                              },
                                                              child: Text(
                                                                'Cancel',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: _ClientPageState()
                                                                          .isWeb(
                                                                              context)
                                                                      ? w / 60
                                                                      : w / 30,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
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
                                      icon: const Icon(Icons.add),
                                      label: Text(
                                        'Add',
                                        style: TextStyle(
                                          fontSize:
                                              _ClientPageState().isWeb(context)
                                                  ? w / 60
                                                  : w / 30,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Expanded(
                                      child: StreamBuilder(
                                        stream: streamData,
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData ||
                                              snapshot.data!.docs.isEmpty) {
                                            return Text(
                                              'No data available',
                                              style: TextStyle(
                                                fontSize: _ClientPageState()
                                                        .isWeb(context)
                                                    ? w / 60
                                                    : w / 30,
                                              ),
                                            );
                                          }

                                          var clientData = snapshot.data!.docs;
                                          clientData = filtering(clientData);
                                          var reminder =
                                              clientData[index].data();

                                          if (!reminder
                                              .containsKey('reminders')) {
                                            return const Text('NO DATA FOUND');
                                          }
                                          Map<String, dynamic> reminders =
                                              reminder['reminders'];

                                          if (reminders.isEmpty) {
                                            return const Text(
                                                'No reminders is set');
                                          }

                                          return ListView.builder(
                                            itemCount: reminders.length,
                                            itemBuilder: (context, index) {
                                              // Get the reminder keys (date and time) as a List
                                              List<String> reminderKeys =
                                                  reminders.keys.toList();

                                              // Extract the reminder data for the current index
                                              Map<String, dynamic>
                                                  reminderData = reminders[
                                                      reminderKeys[index]];

                                              // Get the date and time from the reminder data
                                              String date =
                                                  reminderData['date'];
                                              String time =
                                                  reminderData['time'];

                                              // Construct the reminder key
                                              String reminderKey =
                                                  '$date $time';

                                              // Extract service list
                                              List<String> services =
                                                  List<String>.from(
                                                      reminderData['services']);

                                              return Card(
                                                child: ListTile(
                                                  title: Text(
                                                    'Reminder set for $date at $time for ${services.join(", ")}',
                                                    style: TextStyle(
                                                      fontSize:
                                                          _ClientPageState()
                                                                  .isWeb(
                                                                      context)
                                                              ? w / 60
                                                              : w / 35,
                                                    ),
                                                  ),
                                                  trailing: IconButton(
                                                    icon: const Icon(
                                                        Icons.delete),
                                                    onPressed: () {
                                                      ClientService()
                                                          .deleteReminder(
                                                        phoneNumber,
                                                        reminderKey,
                                                      );
                                                    },
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
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                )
              : Container(),
          !isNoReminderSet
              ? SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              'Send Reminders',
                              style: TextStyle(
                                fontSize: _ClientPageState().isWeb(context)
                                    ? w / 60
                                    : w / 30,
                              ),
                            ),
                            content: SizedBox(
                              width: w * 0.4,
                              height: h * 0.6,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: StreamBuilder(
                                      stream: streamData,
                                      builder: (context, snapshot) {
                                        // if (snapshot.connectionState ==
                                        //     ConnectionState.waiting) {}
                                        if (!snapshot.hasData ||
                                            snapshot.data!.docs.isEmpty) {
                                          return Text(
                                            'No data available',
                                            style: TextStyle(
                                              fontSize: _ClientPageState()
                                                      .isWeb(context)
                                                  ? w / 60
                                                  : w / 30,
                                            ),
                                          );
                                        }
                                        var clientData = snapshot.data!.docs;
                                        clientData = filtering(clientData);
                                        var reminder = clientData[index].data();

                                        if (!reminder
                                            .containsKey('reminders')) {
                                          return const Text('NO DATA FOUND');
                                        }
                                        Map<String, dynamic> reminders =
                                            reminder['reminders'];

                                        if (reminders.isEmpty) {
                                          return const Text('No reminders set');
                                        }

                                        return ListView.builder(
                                          itemCount: reminders.length,
                                          itemBuilder: (context, index) {
                                            List<String> reminderKeys =
                                                reminders.keys.toList();
                                            Map<String, dynamic> reminderData =
                                                reminders[reminderKeys[index]];
                                            String date = reminderData['date'];
                                            String time = reminderData['time'];
                                            String reminderKey = '$date $time';
                                            List<String> services =
                                                List<String>.from(
                                                    reminderData['services']);

                                            return Card(
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    title: Text(
                                                      'Reminder set for $date at $time for ${services.join(", ")}',
                                                      style: TextStyle(
                                                        fontSize:
                                                            _ClientPageState()
                                                                    .isWeb(
                                                                        context)
                                                                ? w / 80
                                                                : w / 35,
                                                      ),
                                                    ),
                                                    trailing: IconButton(
                                                      onPressed: () async {
                                                        launchWhatsAppUri(
                                                          phoneNumber,
                                                          visitDates.last,
                                                          date,
                                                          time,
                                                          services,
                                                        );
                                                      },
                                                      icon: const Icon(
                                                          Icons.send),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Close',
                                  style: TextStyle(
                                    fontSize: _ClientPageState().isWeb(context)
                                        ? w / 80
                                        : w / 45,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: SvgPicture.asset(
                      'assets/images/whatsapp.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  void launchWhatsAppUri(String number, String lastVisitDate, String date,
      String time, List<String> services) async {
    final phoneNumber = "+91-$number";
    final message = "Hey, Your last visit date was on: $lastVisitDate\n"
        "You have an appointment on $date at $time for the following services: ${services.join(', ')}\n"
        "Best regards,\nArtisan";

    final link = WhatsAppUnilink(
      phoneNumber: phoneNumber,
      text: message,
    );

    await launchUrl(link.asUri());
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
          content: SizedBox(
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
        return StatefulBuilder(
          builder: (context, setStateInsideDialog) {
            money = calculateTotalSpend(serviceCheckboxes.keys
                    .where((key) => serviceCheckboxes[key]!)
                    .toList())
                .toStringAsFixed(2);
            return AlertDialog(
              title: Text(
                editingIndex == -1 ? 'Add Client' : 'Edit Client',
                style: TextStyle(
                  fontSize: _ClientPageState().isWeb(context) ? w / 60 : w / 30,
                ),
              ),
              content: SizedBox(
                width: w * 0.3,
                height: h * 0.6,
                child: Column(
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
                    Expanded(
                      child: ListView(
                        children: salonServices.map((service) {
                          return CheckboxListTile(
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
                          );
                        }).toList(),
                      ),
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
        );
      },
    );
  }
}

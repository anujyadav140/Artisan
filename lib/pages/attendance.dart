import 'package:artisan/components/employee_details.dart';
import 'package:artisan/components/heat_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Employee {
  final String id;
  final String firstName;
  final String lastName;

  Employee(
    this.id,
    this.firstName,
    this.lastName,
  );
}

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  List<int> dayList = [];
  List<int> monthList = [];
  List<int> yearList = [];
  List<Employee> employees = [];

  Employee? selectedEmployee;

  Future<List<Map<String, dynamic>>> fetchEmployeeData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Employee').get();

    return querySnapshot.docs.map((doc) {
      return {
        'id': doc.id, // This will contain the auto-generated document ID
        'firstName': doc['firstName'], // This will contain the first name
        'lastName': doc['lastName'], // This will contain the last name
      };
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    fetchEmployeeData().then((value) {
      setState(() {
        employees = value
            .map((e) => Employee(e['id'], e['firstName'], e['lastName']))
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String profilePic = '';
    String birthDate = '';
    String address = '';
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedEmployee == null
            ? 'Employee Attendance List'
            : 'Attendance History For ${selectedEmployee!.firstName}'),
        leading: selectedEmployee == null
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const Attendance(),
                  ));
                },
              ),
      ),
      body: ListView.builder(
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          return Card(
            child: ListTile(
              leading: IconButton(
                icon: Icon(
                  Icons.info,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () async {
                  DocumentSnapshot doc = await FirebaseFirestore.instance
                      .collection("Employee")
                      .doc(employee.id)
                      .get();
                  setState(() {
                    profilePic = doc['profilePic'];
                    birthDate = doc['birthDate'];
                    address = doc['address'];
                  });
                  // ignore: use_build_context_synchronously
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return EmployeeDetailsDialog(
                        firstName: employee.firstName,
                        lastName: employee.lastName,
                        address: address,
                        profilePic: profilePic,
                        birthDate: birthDate,
                      );
                    },
                  );
                },
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () async {
                  List<int> dayList = [];
                  List<int> monthList = [];
                  List<int> yearList = [];
                  setState(() {
                    selectedEmployee = employee;
                  });
                  //in the below code i want to get all the doc names from the Record collection
                  CollectionReference recordCollection = FirebaseFirestore
                      .instance
                      .collection("Employee")
                      .doc(employee.id)
                      .collection("Record");
                  QuerySnapshot recordDocsSnapshot =
                      await recordCollection.get();
                  List<String> docNames =
                      recordDocsSnapshot.docs.map((doc) => doc.id).toList();
                  for (String dateStr in docNames) {
                    // Split the date string into day, month, and year parts
                    List<String> parts = dateStr.split(' ');

                    // Check if the date string has enough parts
                    if (parts.length == 3) {
                      int? day = int.tryParse(parts[0]);
                      String monthStr = parts[1];
                      int? year = int.tryParse(parts[2]);

                      // Define a map for converting month names to numeric values
                      const monthMap = {
                        'January': 1,
                        'February': 2,
                        'March': 3,
                        'April': 4,
                        'May': 5,
                        'June': 6,
                        'July': 7,
                        'August': 8,
                        'September': 9,
                        'October': 10,
                        'November': 11,
                        'December': 12,
                      };

                      int month = monthMap[monthStr] ??
                          1; // Default to January if month name is not recognized

                      if (day != null && year != null) {
                        DateTime date = DateTime(year, month, day);
                        dayList.add(day);
                        monthList.add(month);
                        yearList.add(year);
                      }
                    }
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MyHeatMapCalendar(
                      id: employee.id,
                      name: '${employee.firstName} ${employee.lastName}',
                      dayList: dayList,
                      monthList: monthList,
                      yearList: yearList,
                    ),
                  ));
                },
              ),
              title: Text('${employee.firstName} ${employee.lastName}'),
            ),
          );
        },
      ),
    );
  }
}

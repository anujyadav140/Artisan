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
            : 'Heatmap for ${selectedEmployee!.firstName}'),
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
      body: selectedEmployee == null
          ? ListView.builder(
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
                        print(profilePic);
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
                      onPressed: () {
                        setState(() {
                          selectedEmployee = employee;
                        });
                      },
                    ),
                    title: Text('${employee.firstName} ${employee.lastName}'),
                  ),
                );
              },
            )
          : const MyHeatMapCalendar(),
    );
  }
}

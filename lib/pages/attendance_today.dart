import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  final String id;
  final String username;
  final String firstName;
  final String lastName;

  Employee(
    this.id,
    this.username,
    this.firstName,
    this.lastName,
  );
}

class AttendanceForTheDay extends StatefulWidget {
  const AttendanceForTheDay({Key? key}) : super(key: key);

  @override
  State<AttendanceForTheDay> createState() => _AttendanceForTheDayState();
}

class _AttendanceForTheDayState extends State<AttendanceForTheDay> {
  List<Employee> employees = [];
  List<String> presentEmployees = [];
  List<String> absentEmployees = [];

  // Function to get today's date in the format "dd MMMM yyyy"
  String _getTodayDate() {
    final DateTime now = DateTime.now();
    final String formattedDate =
        "${now.day.toString().padLeft(2, '0')} ${_getMonthName(now.month)} ${now.year}";
    return formattedDate;
  }

  // Function to get month name
  String _getMonthName(int month) {
    final List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }

  Future<void> checkAttendance() async {
    final formattedDate = _getTodayDate();
    print(formattedDate);
    for (var i = 0; i < employees.length; i++) {
      final employee = employees[i];
      final recordDocRef = FirebaseFirestore.instance
          .collection('Employee')
          .doc(employee.id)
          .collection('Record')
          .doc(formattedDate);

      final recordDocSnapshot = await recordDocRef.get();
      if (recordDocSnapshot.exists) {
        setState(() {
          presentEmployees.add('${employee.firstName} ${employee.lastName}');
        });
      } else {
        setState(() {
          absentEmployees.add('${employee.firstName} ${employee.lastName}');
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchEmployeeData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Employee').get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      return {
        'id': doc.id,
        'username': data['id'] ?? '',
        'firstName': data['firstName'] ?? '',
        'lastName': data['lastName'] ?? '',
      };
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    fetchEmployeeData().then((value) {
      setState(() {
        employees = value
            .map((e) =>
                Employee(e['id'], e['username'], e['firstName'], e['lastName']))
            .toList();
      });
    }).then((value) => checkAttendance());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance for the day"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Present Employees:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            for (var name in presentEmployees) Text(name),
            const SizedBox(height: 20),
            const Text(
              "Absent Employees:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            for (var name in absentEmployees) Text(name),
          ],
        ),
      ),
    );
  }
}

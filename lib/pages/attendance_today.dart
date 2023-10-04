import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
  String checkInTime = "";
  String checkOutTime = "";
  String checkInLocation = "";
  String checkOutLocation = "";
  List<Employee> employees = [];
  List<String> presentEmployees = [];
  List<String> absentEmployees = [];
  List<String> employeeIds = [];

  bool isIconButtonClicked = false;

  Color iconButtonColor = Colors.blue; // Initial color
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
    for (var i = 0; i < employees.length; i++) {
      final employee = employees[i];
      employeeIds.add(employee.id);
      final recordDocRef = FirebaseFirestore.instance
          .collection('Employee')
          .doc(employee.id)
          .collection('Record')
          .doc(formattedDate);

      final recordDocSnapshot = await recordDocRef.get();
      if (recordDocSnapshot.exists) {
        setState(() {
          presentEmployees.add(
              '${employee.username} - ${employee.firstName} ${employee.lastName} - ${employee.id}');
        });
      } else {
        setState(() {
          absentEmployees.add(
              '${employee.username} - ${employee.firstName} ${employee.lastName} - ${employee.id}');
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
        'firstName': data['firstName'] ?? 'Name not specified',
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

  Widget _buildEmployeeList(
      List<String> employeeNames, String title, bool showIconButton) {
    double screenWidth = MediaQuery.of(context).size.width;
    List<String> employeeNamesList = [];

    for (int i = 0; i < employeeNames.length; i++) {
      String employeeInfo = employeeNames[i];
      // Split the string by '-' to get an array of parts
      List<String> parts = employeeInfo.split('-');

      if (parts.length >= 2) {
        String fullName = parts[0].trim() + ' - ' + parts[1].trim();
        employeeNamesList.add(fullName);
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontFamily: "NexaBold",
              fontSize: kIsWeb ? 25 : screenWidth / 30,
            ),
          ),
        ),
        for (int i = 0; i < employeeNames.length; i++)
          Column(
            children: [
              Column(
                children: [
                  ListTile(
                    title: Text(
                      employeeNamesList[i],
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "NexaBold",
                        fontSize: kIsWeb ? 25 : screenWidth / 30,
                      ),
                    ),
                    trailing: showIconButton
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                if (selectedEmployee == employeeNames[i]) {
                                  selectedEmployee = null;
                                } else {
                                  selectedEmployee = employeeNames[i];
                                }
                              });

                              String employeeId = "";
                              List<String> parts = employeeNames[i].split('-');
                              if (parts.length >= 3) {
                                employeeId = parts[2].trim();
                                print(employeeId);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Invalid employee name format"),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                              renderEmployeeAttendanceDetails(employeeId);
                            },
                            icon: Icon(
                              Icons.info,
                              color: Colors.blue,
                            ),
                          )
                        : null,
                  ),
                  const Divider(
                    color: Colors.blue,
                    thickness: 1.0,
                    height: 16.0,
                    indent: 20.0,
                    endIndent: 20.0,
                  )
                ],
              ),
              if (selectedEmployee == employeeNames[i])
                _showEmployeeDetailsDialog()
            ],
          )
      ],
    );
  }

  String? selectedEmployee;

  void updateDetails(Timestamp date, String checkIn, String checkOut,
      String checkOutLoc, String checkInLoc) {
    setState(() {
      checkInTime = checkIn;
      checkOutTime = checkOut;
      checkOutLocation = checkOutLoc;
      checkInLocation = checkInLoc;
    });
  }

  void renderEmployeeAttendanceDetails(String id) {
    print(id);
    final presentDate = DateTime.now();
    final formattedPresentDate = DateFormat('dd MMMM y').format(presentDate);
    print(formattedPresentDate);
    Future<DocumentSnapshot<Map<String, dynamic>>> selectedDateAttendance =
        FirebaseFirestore.instance
            .collection("Employee")
            .doc(id)
            .collection("Record")
            .doc(formattedPresentDate)
            .get();

    selectedDateAttendance.then((values) {
      if (values.exists) {
        final data = values.data();

        if (data!.containsKey('checkInLocation')) {
          updateDetails(data['date'], data['checkIn'], data['checkOut'],
              data['checkOutLocation'], data['checkInLocation']);
        } else {
          updateDetails(data['date'], data['checkIn'], data['checkOut'],
              data['checkOutLocation'], "Location Not Yet Available");
        }
      } else {
        print("Document does not exist");
      }
    });
  }

  Widget _showEmployeeDetailsDialog() {
    double screenWidth = MediaQuery.of(context).size.width;
    return AlertDialog(
      title: Text(
        "Employee Attendance Details",
        style: TextStyle(
          color: Colors.blue,
          fontSize: kIsWeb ? 25 : screenWidth / 30,
          fontFamily: "NexaBold",
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              checkInTime == "" ? "None" : checkInTime,
              style: TextStyle(
                fontFamily: "NexaRegular",
                fontSize: kIsWeb ? 18 : screenWidth / 30,
              ),
            ),
            Text(
              checkOutTime == "" ? "None" : checkOutTime,
              style: TextStyle(
                fontFamily: "NexaRegular",
                fontSize: kIsWeb ? 18 : screenWidth / 30,
              ),
            ),
            Text(
              checkOutLocation == "" ? "None" : checkOutLocation,
              style: TextStyle(
                fontFamily: "NexaRegular",
                fontSize: kIsWeb ? 18 : screenWidth / 30,
              ),
            ),
            Text(
              checkInLocation == "" ? "None" : checkInLocation,
              style: TextStyle(
                fontFamily: "NexaRegular",
                fontSize: kIsWeb ? 18 : screenWidth / 30,
              ),
            ),
          ],
        ),
      ),
      // actions: <Widget>[
      //   TextButton(
      //     onPressed: () {
      //       Navigator.of(context).pop(); // Close the dialog
      //     },
      //     child: Text(
      //       "Close",
      //       style: TextStyle(
      //         fontFamily: "NexaBold",
      //       ),
      //     ),
      //   ),
      // ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Attendance for the day",
          style: TextStyle(
            fontFamily: "NexaBold",
            fontSize: kIsWeb ? 25 : screenWidth / 30,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15), // Rounded bottom edges
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              if (presentEmployees.isNotEmpty)
                _buildEmployeeList(presentEmployees, "Present Employees", true),
              if (absentEmployees.isNotEmpty)
                _buildEmployeeList(absentEmployees, "Absent Employees", false),
            ],
          ),
        ),
      ),
    );
  }
}

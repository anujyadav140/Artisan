import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class MyHeatMapCalendar extends StatefulWidget {
  MyHeatMapCalendar({
    super.key,
    required this.name,
    required this.id,
    required this.username,
    required this.dayList,
    required this.monthList,
    required this.yearList,
  });
  String id;
  String name;
  String username;
  List<int> dayList;
  List<int> monthList;
  List<int> yearList;

  @override
  State<MyHeatMapCalendar> createState() => _MyHeatMapCalendarState();
}

class _MyHeatMapCalendarState extends State<MyHeatMapCalendar> {
  Map<DateTime, int> calendarData = {};
  DateTime selectedDate = DateTime.now(); // Initialize with the current date
  String checkInTime = "";
  String checkOutTime = "";
  String checkInLocation = "";
  String checkOutLocation = "";
  double screenWidth = 0;
  @override
  void initState() {
    renderDates();
    super.initState();
  }

  void renderDates() {
    for (int i = 0; i < widget.dayList.length; i++) {
      final DateTime date =
          DateTime(widget.yearList[i], widget.monthList[i], widget.dayList[i]);
      calendarData[date] = 10;
    }
  }

  void renderSingleDateDetails() async {
    //in the below code i want to get all the doc names from the Record collection
    CollectionReference recordCollection = FirebaseFirestore.instance
        .collection("Employee")
        .doc(widget.id)
        .collection("Record");
    QuerySnapshot recordDocsSnapshot = await recordCollection.get();
    List<String> docNames =
        recordDocsSnapshot.docs.map((doc) => doc.id).toList();

    // Create a copy of the current calendarData
    Map<DateTime, int> newCalendarData = Map.from(calendarData);

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
          newCalendarData[date] = 10;
        }
      }
    }

    // Check if there is a change in the calendarData
    if (!mapsAreEqual(calendarData, newCalendarData)) {
      setState(() {
        calendarData = newCalendarData;
      });
    }
  }

// Function to check if two maps are equal
  bool mapsAreEqual(Map<dynamic, dynamic> map1, Map<dynamic, dynamic> map2) {
    if (map1.length != map2.length) return false;

    for (var key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) return false;
    }

    return true;
  }

  void updateDetails(Timestamp date, String checkIn, String checkOut,
      String checkOutLoc, String checkInLoc) {
    final DateTime dateTime = date.toDate();

    setState(() {
      selectedDate = dateTime;
      checkInTime = checkIn;
      checkOutTime = checkOut;
      checkOutLocation = checkOutLoc;
      checkInLocation = checkInLoc;
    });
  }

  void renderHeatMapCalender(DateTime value) {
    final formattedSelectedDate = DateFormat('d MMMM y').format(value);
    Future<DocumentSnapshot<Map<String, dynamic>>> selectedDateAttendance =
        FirebaseFirestore.instance
            .collection("Employee")
            .doc(widget.id)
            .collection("Record")
            .doc(formattedSelectedDate)
            .get();

    selectedDateAttendance.then((values) {
      if (values.exists) {
        final data = values.data(); // Get the document data as a Map

        if (data!.containsKey('checkInLocation')) {
          updateDetails(data['date'], data['checkIn'], data['checkOut'],
              data['checkOutLocation'], data['checkInLocation']);
        } else {
          updateDetails(data['date'], data['checkIn'], data['checkOut'],
              data['checkOutLocation'], "Location Not Yet Available");
        }
      } else {
        // Handle the case where the document does not exist
        // You can decide what to do in this case
        print("Document does not exist");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance Calender-${widget.name.isEmpty ? widget.username : widget.name}',
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
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: kIsWeb
                    ? MediaQuery.of(context).size.width < 960
                        ? MediaQuery.of(context).size.width * 0.80
                        : MediaQuery.of(context).size.width * 0.40
                    : null,
                child: HeatMapCalendar(
                  defaultColor: Colors.white,
                  showColorTip: false,
                  flexible: true,
                  colorMode: ColorMode.color,
                  textColor: Colors.black,
                  datasets: calendarData,
                  colorsets: const {
                    1: Colors.blue,
                  },
                  onClick: (value) {
                    renderHeatMapCalender(value);
                  },
                ),
              ),
            ),
            SizedBox(
              width: kIsWeb
                  ? MediaQuery.of(context).size.width < 960
                      ? MediaQuery.of(context).size.width * 0.90
                      : MediaQuery.of(context).size.width * 0.60
                  : null,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 20, left: 12, right: 12),
                    height: 125,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(2, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Center(
                              child: Text(
                                DateFormat('EE\ndd').format(selectedDate),
                                style: TextStyle(
                                    fontFamily: "NexaBold",
                                    fontSize: kIsWeb ? 30 : screenWidth / 18,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Check In",
                                style: TextStyle(
                                  fontFamily: "NexaRegular",
                                  fontSize: kIsWeb ? 25 : screenWidth / 25,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                checkInTime == "" ? "None" : checkInTime,
                                style: TextStyle(
                                  fontFamily: "NexaBold",
                                  fontSize: kIsWeb ? 18 : screenWidth / 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Check Out",
                                style: TextStyle(
                                  fontFamily: "NexaRegular",
                                  fontSize: kIsWeb ? 25 : screenWidth / 25,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                checkOutTime == "" ? "None" : checkOutTime,
                                style: TextStyle(
                                  fontFamily: "NexaBold",
                                  fontSize: kIsWeb ? 18 : screenWidth / 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20, left: 12, right: 12),
                    height: 125,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(2, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 10.0),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 12.0, right: 30.0),
                              child: Text(
                                "Check In\nLocation",
                                style: TextStyle(
                                  fontFamily: "NexaBold",
                                  fontSize: kIsWeb ? 20 : screenWidth / 22,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            checkOutLocation == "" ? "None" : checkOutLocation,
                            style: TextStyle(
                              fontFamily: "NexaBold",
                              fontSize: kIsWeb ? 18 : screenWidth / 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                        top: 20, left: 12, right: 12, bottom: 20),
                    height: 125,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(2, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 10.0),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(
                                "Check Out\nLocation",
                                style: TextStyle(
                                  fontFamily: "NexaBold",
                                  fontSize: kIsWeb ? 20 : screenWidth / 22,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            checkInLocation == "" ? "None" : checkInLocation,
                            style: TextStyle(
                              fontFamily: "NexaBold",
                              fontSize: kIsWeb ? 18 : screenWidth / 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          widget.dayList.clear();
          widget.monthList.clear();
          widget.yearList.clear();
          calendarData.clear();
          renderSingleDateDetails();
          renderDates();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

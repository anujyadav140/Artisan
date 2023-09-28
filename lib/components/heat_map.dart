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
    required this.dayList,
    required this.monthList,
    required this.yearList,
  });
  String id;
  String name;
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
    super.initState();
    for (int i = 0; i < widget.dayList.length; i++) {
      final DateTime date =
          DateTime(widget.yearList[i], widget.monthList[i], widget.dayList[i]);
      calendarData[date] = 10;
    }
  }

  void updateDetails(Timestamp date, String checkIn, String checkInLoc,
      String checkOut, String checkOutLoc) {
    final DateTime dateTime = date.toDate();

    setState(() {
      selectedDate = dateTime;
      checkInTime = checkIn;
      checkOutTime = checkOut;
      checkInLocation = checkInLoc;
      checkOutLocation = checkOutLoc;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Calender For '),
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
                        ? MediaQuery.of(context).size.width * 0.65
                        : MediaQuery.of(context).size.width * 0.35
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
                    final formattedSelectedDate =
                        DateFormat('d MMMM y').format(value);
                    Future<DocumentSnapshot<Map<String, dynamic>>>
                        selectedDateAttendance = FirebaseFirestore.instance
                            .collection("Employee")
                            .doc(widget.id)
                            .collection("Record")
                            .doc(formattedSelectedDate)
                            .get();

                    selectedDateAttendance.then((value) {
                      updateDetails(
                          value['date'],
                          value['checkIn'],
                          value['checkInLocation'],
                          value['checkOut'],
                          value['checkOutLocation']);
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              width: kIsWeb
                  ? MediaQuery.of(context).size.width < 960
                      ? MediaQuery.of(context).size.width * 0.90
                      : MediaQuery.of(context).size.width * 0.60
                  : MediaQuery.of(context).size.width * 0.75,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 20, left: 12, right: 12),
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
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
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
                    margin: EdgeInsets.only(top: 20, left: 12, right: 12),
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
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 12.0, right: 30.0),
                              child: Text(
                                "Check In\nLocation",
                                style: TextStyle(
                                  fontFamily: "NexaBold",
                                  fontSize: kIsWeb ? 20 : screenWidth / 20,
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
                              fontSize: kIsWeb ? 18 : screenWidth / 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
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
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(
                                "Check Out\nLocation",
                                style: TextStyle(
                                  fontFamily: "NexaBold",
                                  fontSize: kIsWeb ? 20 : screenWidth / 20,
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
                              fontSize: kIsWeb ? 18 : screenWidth / 18,
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
    );
  }
}

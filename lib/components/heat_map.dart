import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class MyHeatMapCalendar extends StatelessWidget {
  const MyHeatMapCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return HeatMapCalendar(
      defaultColor: Colors.white,
      showColorTip: false,
      flexible: true,
      colorMode: ColorMode.color,
      textColor: Colors.black,
      datasets: {
        DateTime(2023, 9, 21): 10,
        DateTime(2023, 9, 22): 10,
        DateTime(2023, 9, 23): 10,
        DateTime(2023, 9, 24): 10,
        DateTime(2023, 9, 25): 10,
      },
      colorsets: const {
        1: Colors.blue,
      },
      onClick: (value) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(value.toString())));
      },
    );
  }
}

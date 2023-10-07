import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EmployeeDetailsDialog extends StatelessWidget {
  final String profilePic;
  final String firstName;
  final String lastName;
  final String address;
  final String birthDate;

  const EmployeeDetailsDialog({
    Key? key,
    required this.profilePic,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.birthDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      width: 400,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Employee Details",
              style: TextStyle(
                color: Colors.blue,
                fontFamily: "NexaBold",
                fontSize: kIsWeb ? 25 : w / 30,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            title: CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                profilePic,
                scale: 1.0,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.person,
              size: 30,
              color: Colors.blue,
            ),
            title: Text(
              "First Name:",
              style: TextStyle(
                color: Colors.blue,
                fontFamily: "NexaBold",
                fontSize: kIsWeb ? 20 : w / 25,
              ),
            ),
            subtitle: Text(
              firstName,
              style: TextStyle(
                color: Colors.black,
                fontFamily: "NexaBold",
                fontSize: kIsWeb ? 18 : w / 20,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.person,
              size: 30,
              color: Colors.blue,
            ),
            title: Text(
              "Last Name:",
              style: TextStyle(
                color: Colors.blue,
                fontFamily: "NexaBold",
                fontSize: kIsWeb ? 20 : w / 25,
              ),
            ),
            subtitle: Text(
              lastName,
              style: TextStyle(
                color: Colors.black,
                fontFamily: "NexaBold",
                fontSize: kIsWeb ? 18 : w / 20,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.location_on,
              size: 30,
              color: Colors.blue,
            ),
            title: Text(
              "Address:",
              style: TextStyle(
                color: Colors.blue,
                fontFamily: "NexaBold",
                fontSize: kIsWeb ? 20 : w / 25,
              ),
            ),
            subtitle: Text(
              address,
              style: TextStyle(
                color: Colors.black,
                fontFamily: "NexaBold",
                fontSize: kIsWeb ? 18 : w / 20,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.calendar_today,
              size: 30,
              color: Colors.blue,
            ),
            title: Text(
              "Birth Date:",
              style: TextStyle(
                color: Colors.blue,
                fontFamily: "NexaBold",
                fontSize: kIsWeb ? 20 : w / 25,
              ),
            ),
            subtitle: Text(
              birthDate,
              style: TextStyle(
                color: Colors.black,
                fontFamily: "NexaBold",
                fontSize: kIsWeb ? 18 : w / 20,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15.0, right: 10.0),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  "Close",
                  style: TextStyle(
                    color: Colors.blue,
                    fontFamily: "NexaBold",
                    fontSize: kIsWeb ? 20 : w / 25,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(),
          ListTile(
            title: CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                profilePic,
                scale: 1.0,
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("First Name:"),
            subtitle: Text(
              firstName,
              style: TextStyle(fontSize: 18),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Last Name:"),
            subtitle: Text(
              lastName,
              style: TextStyle(fontSize: 18),
            ),
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text("Address:"),
            subtitle: Text(
              address,
              style: TextStyle(fontSize: 18),
            ),
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text("Birth Date:"),
            subtitle: Text(
              birthDate,
              style: TextStyle(fontSize: 18),
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
                child: const Text(
                  "Close",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
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

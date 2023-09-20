import 'package:artisan/pages/billing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClientService extends ChangeNotifier {
  // Get instance of auth and the firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> clientEngagement(
    String phoneNumber,
    String name,
    dynamic visitDate,
    List<String>? selectedServices,
    dynamic? money,
  ) async {
    try {
      // Check if the user is authenticated
      final User? user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception("User not authenticated.");
      }

      // Reference to the Firestore collection "Clients"
      final CollectionReference clientsCollection =
          _firestore.collection('Clients');

      // Create a document reference for the specific client
      final DocumentReference clientDocumentRef =
          clientsCollection.doc(phoneNumber);

      // Create a map to hold the client data
      final Map<String, dynamic> clientData = {
        'name': name,
        'phoneNumber': phoneNumber,
        'visits': {
          visitDate.toString(): {
            'services': selectedServices,
            'amount': money,
          },
        },
      };

      // Set the client data
      await clientDocumentRef.set(clientData, SetOptions(merge: true));

      notifyListeners();
    } catch (error) {
      print("Error: $error");
      rethrow;
    }
  }

  Future<void> addReminderToClient(
    String phoneNumber,
    DateTime reminderDate,
    TimeOfDay reminderTime,
    List<String> reminderServices,
  ) async {
    try {
      // Reference to the Firestore collection "Clients"
      final CollectionReference clientsCollection =
          _firestore.collection('Clients');

      // Create a document reference for the specific client
      final DocumentReference clientDocumentRef =
          clientsCollection.doc(phoneNumber);

      // Get the existing client data
      final DocumentSnapshot clientSnapshot = await clientDocumentRef.get();
      if (!clientSnapshot.exists) {
        throw Exception("Client not found.");
      }

      // Extract the current client data
      final Map<String, dynamic> clientData =
          clientSnapshot.data() as Map<String, dynamic>;

      // Format the date using the intl package
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      final String formattedDate = dateFormat.format(reminderDate);

      // Format the time as a string
      final String formattedTime =
          '${reminderTime.hour}:${reminderTime.minute}';

      // Create a map for the new reminder
      final Map<String, dynamic> reminderData = {
        'date': formattedDate,
        'time': formattedTime,
        'services': reminderServices,
      };

      // Add the reminder to the client's reminders list
      final Map<String, dynamic> reminders =
          Map<String, dynamic>.from(clientData['reminders'] ?? {});
      final String reminderKey = "$formattedDate $formattedTime";
      reminders[reminderKey] = reminderData;

      // Update the client data with the new reminders field
      clientData['reminders'] = reminders;

      // Update the client document with the new data
      await clientDocumentRef.update(clientData);

      notifyListeners();
    } catch (error) {
      print("Error: $error");
      throw error;
    }
  }

  Future<void> deleteReminder(
    String phoneNumber,
    String reminderKey,
  ) async {
    try {
      // Reference to the Firestore collection "Clients"
      final CollectionReference clientsCollection =
          _firestore.collection('Clients');

      // Create a document reference for the specific client
      final DocumentReference clientDocumentRef =
          clientsCollection.doc(phoneNumber);

      // Get the existing client data
      final DocumentSnapshot clientSnapshot = await clientDocumentRef.get();
      if (!clientSnapshot.exists) {
        throw Exception("Client not found.");
      }

      // Extract the current client data
      final Map<String, dynamic> clientData =
          clientSnapshot.data() as Map<String, dynamic>;

      // Check if the reminders field exists
      if (clientData.containsKey('reminders')) {
        // Get the reminders map
        final Map<String, dynamic> reminders =
            Map<String, dynamic>.from(clientData['reminders']);

        // Check if the reminder key exists in the reminders map
        if (reminders.containsKey(reminderKey)) {
          // Delete the specific reminder
          reminders.remove(reminderKey);

          // Update the client data with the modified reminders map
          clientData['reminders'] = reminders;

          // Update the client document with the new data
          await clientDocumentRef.update(clientData);

          notifyListeners();
        }
      }
    } catch (error) {
      print("Error: $error");
      throw error;
    }
  }

  Future<ClientData> getClientDataByPhoneNumber(String phoneNumber) async {
    try {
      // You should implement the logic to fetch client data from your data source
      // (e.g., Firestore) using the provided phoneNumber.
      // This is a simplified example assuming you have a Firestore collection named 'Clients'.

      final DocumentSnapshot clientSnapshot = await FirebaseFirestore.instance
          .collection('Clients')
          .doc(phoneNumber)
          .get();

      if (clientSnapshot.exists) {
        final Map<String, dynamic> data =
            clientSnapshot.data() as Map<String, dynamic>;
        final String name = data['name'];
        final String phoneNumber = data['phoneNumber'];

        return ClientData(
          name: name,
          phoneNumber: phoneNumber,
        );
      } else {
        // Handle the case where the client is not found
        throw Exception('Client not found');
      }
    } catch (error) {
      // Handle any errors that may occur during the data retrieval process
      print('Error fetching client data: $error');
      rethrow;
    }
  }
}

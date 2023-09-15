import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ClientService extends ChangeNotifier {
  // Get instance of auth and the firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> clientEngagement(
    String phoneNumber,
    String name,
    dynamic visitDate,
    List<String> selectedServices,
    dynamic money,
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
      throw error;
    }
  }
}

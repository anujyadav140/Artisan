import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ClientService extends ChangeNotifier {
  //get instance of auth and the firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Send message
  Future<void> clientEngagement(
      String phoneNumber,
      String name,
      List<dynamic> visitDates,
      List<List<String>> pastServices,
      List<dynamic> pastAmounts) async {
        
      }
}

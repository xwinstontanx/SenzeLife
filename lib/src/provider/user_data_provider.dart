import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class UserDataProvider extends ChangeNotifier {
  Future<Object?> getUser(String uid) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .get();

    return userSnapshot.data();
  }
}

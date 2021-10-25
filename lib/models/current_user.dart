import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentUser {
  late String uid;
  late String name;
  late String image;

  CurrentUser({
    required this.name,
    required this.uid,
    required this.image,
  });

  factory CurrentUser.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic>? getDocs = doc.data() as Map<String, dynamic>?;
    return CurrentUser(
      name: getDocs?["name"] ?? '',
      uid: getDocs?["uid"] ?? '',
      image: getDocs?['image'] ?? '',
    );
  }
}

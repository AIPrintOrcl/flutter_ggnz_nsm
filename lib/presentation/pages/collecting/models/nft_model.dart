import 'package:cloud_firestore/cloud_firestore.dart';

class NftTest {
  final String image;
  final num health;
  final num tokenID;

  NftTest({required this.image, required this.health, required this.tokenID});

  NftTest.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : image = doc.data()!["image"] ?? '',
        health = doc.data()!['health'] ?? 0.0,
        tokenID = doc.data()!['tokenID'] ?? 0;
}

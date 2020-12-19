import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String id;
  final String email;
  final String image;
  final Timestamp lastseen;
  final String name;
  final String lastname;

  Contact({this.id, this.email, this.name, this.lastname, this.image, this.lastseen});

  factory Contact.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data();
    return Contact(
      id: _snapshot.id,
      lastseen: _data['lastSeen'],
      email: _data['email'],
      name: _data['name'],
      lastname: _data['lastname'],
      image: _data['image'],
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  final String id;
  final String name;
  final DateTime dateAdded;
  final String imageUrl;
  final String imagePath;

  const Place({required this.id, required this.name, required this.dateAdded, required this.imageUrl, required this.imagePath});
  Place.fromMap(map): id = map.id, name = map['name'], dateAdded = map['dateAdded'].toDate(), imageUrl = map['imageUrl'], imagePath=map['imagePath'];

  Map<String,dynamic> get toMap {
    return {
      'id' : id,
      ...dataToMap
    };
  }

  Map<String,dynamic> get dataToMap {
    return {
      'name': name,
      'dateAdded' : Timestamp.fromDate(dateAdded),
      'imageUrl': imageUrl,
      'imagePath': imagePath
    };
  }

}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class PlaceLocation {
  final String address;
  final double latitude;
  final double longitude;

  PlaceLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
  PlaceLocation.fromMap(map)
    : address = map['address'],
      latitude = map['latitude'],
      longitude = map['longitude'];

  Map<String, dynamic> get toMap {
    return {'address': address, 'latitude': latitude, 'longitude': longitude};
  }
}

class Place {
  final String id;
  final String name;
  final DateTime dateAdded;
  final String imageUrl;
  final String imagePath;
  final PlaceLocation location;

  Place({
    id,
    required this.name,
    required this.dateAdded,
    required this.imageUrl,
    required this.imagePath,
    required this.location,
  }) : id = id ?? uuid.v4();
  Place.fromMap(map)
    : id = map.id,
      name = map['name'],
      dateAdded = (map['dateAdded'] as Timestamp).toDate(),
      imageUrl = map['imageUrl'],
      imagePath = map['imagePath'],
      location = PlaceLocation.fromMap(map['location']);

  Map<String, dynamic> get toMap {
    return {'id': id, ...dataToMap};
  }

  Map<String, dynamic> get dataToMap {
    return {
      'name': name,
      'dateAdded': Timestamp.fromDate(dateAdded),
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'location': location.toMap,
    };
  }
}

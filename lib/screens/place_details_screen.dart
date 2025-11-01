import 'package:favorite_places/models/place.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class PlaceDetailsScreen extends StatelessWidget {
  final Place place;

  const PlaceDetailsScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(place.name)),
      body: Stack(
        children: [
          FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: place.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ],
      ),
    );
  }
}

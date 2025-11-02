import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/screens/map_screen.dart';
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                GestureDetector(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => MapScreen(location: place.location, isSelecting: false,)));
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(place.location.locationImage),
                    radius: 70,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black54],
                      begin: AlignmentGeometry.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Text(
                    place.location.address,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

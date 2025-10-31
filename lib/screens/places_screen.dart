import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/screens/add_new_place_screen.dart';
import 'package:favorite_places/widgets/connection_error_screen.dart';
import 'package:favorite_places/widgets/place_list_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({super.key});

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Places'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const AddNewPlaceScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('place_lists')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('places')
            .snapshots()
            .handleError((error) {
              dev.log(
                'Stream error.',
                name: 'PlacesScreen.Stream',
                error: error,
              );
              return ConnectionErrorScreen();
            }),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            );
          }

          if (snap.hasError) {
            dev.log(
              'snapshot has error.',
              name: 'PlacesScreen.Snapshot',
              error: snap.error,
            );

            return ConnectionErrorScreen();
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Add a favorite place!',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          }

          final places = snap.data!.docs;
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            itemCount: places.length,
            itemBuilder: (ctx, idx) {
              final place = Place.fromMap(places[idx]);
              return PlaceListItem(context: context, place: place);
            },
          );
        },
      ),
    );
  }
}

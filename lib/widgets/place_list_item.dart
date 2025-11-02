import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/screens/place_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PlaceListItem extends StatelessWidget {
  final Place place;
  final BuildContext context;
  const PlaceListItem({super.key, required this.context, required this.place});

  void _showErrorSnackbar(e) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.message ?? 'We encountered an error, please try again later.',
        ),
      ),
    );
  }

  void _showDeleteSnackbar() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${place.name} deleted.'),
        action: SnackBarAction(label: 'Undo', onPressed: _addItem),
      ),
    );
  }

  void _addItem() async {
    try {
      await FirebaseFirestore.instance
          .collection('place_lists')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('places')
          .doc(place.id)
          .set(place.dataToMap)
          .timeout(
            Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Connection timeout.');
            },
          );
    } on FirebaseException catch (e) {
      _showErrorSnackbar(e);
      return;
    } on TimeoutException catch (e) {
      _showErrorSnackbar(e);
      return;
    }
  }

  void _deleteItem() async {
    try {
      await FirebaseFirestore.instance
          .collection('place_lists')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('places')
          .doc(place.id)
          .delete()
          .timeout(
            Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Connection timeout.');
            },
          );
    } on FirebaseException catch (e) {
      _showErrorSnackbar(e);
      return;
    } on TimeoutException catch (e) {
      _showErrorSnackbar(e);
      return;
    }

    _showDeleteSnackbar();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(place.id),
      background: Container(
        color: Theme.of(
          context,
        ).colorScheme.errorContainer.withValues(alpha: .5),
        child: Center(
          child: Icon(
            Icons.delete,
            color: Theme.of(
              context,
            ).colorScheme.onErrorContainer.withValues(alpha: .9),
          ),
        ),
      ),
      onDismissed: (direction) {
        _deleteItem();
      },
      child: ListTile(
        contentPadding: EdgeInsets.all(6),
        leading: CircleAvatar(radius: 26, backgroundImage: NetworkImage(place.imageUrl),),
        title: Text(place.name),
        subtitle: Text(place.location.address),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => PlaceDetailsScreen(place: place),
            ),
          );
        },
      ),
    );
  }
}

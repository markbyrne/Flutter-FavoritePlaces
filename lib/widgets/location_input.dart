import 'dart:convert';

import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/secrets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:developer' as dev;

class LocationInputController {
  _LocationInputState? _state;

  void _attach(_LocationInputState state) => _state = state;
  void _detach() => _state = null;

  void showError(String msg) {
    _state?.showError(msg);
  }

  void clearError() {
    _state?.clearError();
  }

  void clearLocation() {
    _state?.clearLocation();
  }

  void reset() {
    _state?.clearError();
    _state?.clearLocation();
  }

  PlaceLocation? get pickedLocation {
    return _state?.pickedLocation;
  }
}

class LocationInput extends StatefulWidget {
  final LocationInputController controller;

  const LocationInput({super.key, required this.controller});

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String? _errorMsg;
  PlaceLocation? _pickedLocation;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
  }

  @override
  void dispose() {
    widget.controller._detach();
    super.dispose();
  }

  void showError(String msg) {
    setState(() {
      _errorMsg = msg;
    });
  }

  void clearError() {
    setState(() {
      _errorMsg = null;
    });
  }

  void clearLocation() {
    _pickedLocation = null;
  }

  PlaceLocation? get pickedLocation {
    return _pickedLocation;
  }

  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lon = locationData.longitude;
    dev.log(
      'User Location: $lat, $lon',
      name: 'LocationInput:_getCurrentLocation',
    );

    if (lat == null || lon == null) {
      setState(() {
        _isGettingLocation = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to get location. Please try again later.'),
        ),
      );

      return;
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=${Secrets.googleMapAPIKey}',
    );
    final response = await http.get(url);
    final responseData = json.decode(response.body);
    final address = responseData['results'][0]['formatted_address'];

    _pickedLocation = PlaceLocation(
      address: address,
      latitude: lat,
      longitude: lon,
    );
    setState(() {
      _isGettingLocation = false;
    });
    clearError();
  }

  String? get locationImage {
    if (_pickedLocation == null) {
      return null;
    }
    final lat = _pickedLocation!.latitude;
    final lon = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lon&zoom=16&size=600x300&markers=color:blue%7Clabel:%7C$lat,$lon&key=${Secrets.googleMapAPIKey}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          child: _isGettingLocation
              ? const Center(child: CircularProgressIndicator())
              : _pickedLocation == null
              ? Text(
                  'No location chosen',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                )
              : Image.network(
                  locationImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: Icon(Icons.location_on),
              label: const Text('Get Current Location'),
              onPressed: _getCurrentLocation,
            ),
            TextButton.icon(
              icon: Icon(Icons.map),
              label: const Text('Pick on Map'),
              onPressed: () {},
            ),
          ],
        ),
        if (_errorMsg != null)
          Text(
            _errorMsg!,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
      ],
    );
  }
}

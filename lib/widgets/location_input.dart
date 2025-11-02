import 'dart:async';
import 'dart:convert';

import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/screens/map_screen.dart';
import 'package:favorite_places/secrets.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
    _state?._isGettingLocation = false;
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
    LocationData? locationData;

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

    try {
      locationData = await location.getLocation().timeout(
        Duration(seconds: 10),
      );
    } on TimeoutException catch (e) {
      dev.log(
        'Location service timed out',
        name: 'LocationInput:_getCurrentLocation',
        error: e,
      );
    }

    final lat = locationData?.latitude;
    final lon = locationData?.longitude;

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
    dev.log(
      'User Location: $lat, $lon',
      name: 'LocationInput:_getCurrentLocation',
    );

    final address = await getAddress(lat, lon);

    setState(() {
          _pickedLocation = PlaceLocation(
      address: address,
      latitude: lat,
      longitude: lon,
    );
      _isGettingLocation = false;
    });
    clearError();
  }

  Future<String> getAddress(double lat, double lon) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=${Secrets.googleMapAPIKey}',
    );
    final response = await http.get(url);
    final responseData = json.decode(response.body);
    final address = responseData['results'][0]['formatted_address'];

    return address;
  }

  String? get locationImage {
    if (_pickedLocation == null) {
      return null;
    }
    final lat = _pickedLocation!.latitude;
    final lon = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lon&zoom=16&size=600x300&markers=color:blue%7Clabel:%7C$lat,$lon&key=${Secrets.googleMapAPIKey}';
  }

  void _pickMapLocation() async {
    final selectedLocation = await Navigator.of(context).push<LatLng>(MaterialPageRoute(builder: (ctx) => _pickedLocation == null ? MapScreen() : MapScreen(location: _pickedLocation!,)));
    
    if(selectedLocation == null){
      return;
    }

    setState(() {
      _isGettingLocation = true;
    });

    final lat = selectedLocation.latitude;
    final lon = selectedLocation.longitude;

    final address = await getAddress(lat, lon);


    setState(() {
      _isGettingLocation = false;
          _pickedLocation = PlaceLocation(
      address: address,
      latitude: lat,
      longitude: lon,
    );
    });
    clearError();
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
              onPressed: _pickMapLocation,
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

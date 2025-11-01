import 'package:flutter/material.dart';

class LocationInputController {
  _LocationInputState? _state;

  void _attach(_LocationInputState state) => _state = state;
  void _detach() => _state = null;

  void showError(String msg) {
    _state?.showError(msg);
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
          child: Text(
            'No location chosen',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: Icon(Icons.location_on),
              label: const Text('Get Current Location'),
              onPressed: () {},
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

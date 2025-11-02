import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:favorite_places/widgets/location_input.dart';
import 'package:favorite_places/widgets/user_image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart' show kIsWeb;

class AddNewPlaceScreen extends StatefulWidget {
  const AddNewPlaceScreen({super.key});

  @override
  State<AddNewPlaceScreen> createState() => _AddNewPlaceScreenState();
}

class _AddNewPlaceScreenState extends State<AddNewPlaceScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final UserImagePickerController _userImagePickerController =
      UserImagePickerController();
  final LocationInputController _locationInputController =
      LocationInputController();
  String _locationName = '';
  bool _isUploading = false;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Map<String, String>?> uploadImage(XFile imageFile) async {
    try {
      String imageId = DateTime.now().millisecondsSinceEpoch.toString();
      String uid = FirebaseAuth.instance.currentUser!.uid;

      dev.log(
        'Attempting to upload image for user $uid to filename $imageId',
        name: 'AddNewPlaceScreen:uploadImage',
      );

      // Create a reference to the location you want to upload to
      Reference ref = _storage.ref().child('place_images/$uid/$imageId');
      dev.log(
        'Built reference: ${ref.fullPath}',
        name: 'AddNewPlaceScreen:uploadImage',
      );

      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': uid,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      UploadTask uploadTask;
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        uploadTask = ref.putData(bytes, metadata);
      } else {
        uploadTask = ref.putFile(File(imageFile.path), metadata);
      }

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      dev.log(
        'Upload complete. URL: $downloadUrl',
        name: 'AddNewPlaceScreen:uploadImage',
      );

      return {'imageUrl': downloadUrl, 'imagePath': ref.fullPath};
    } catch (e) {
      dev.log(
        'Unable to upload image.',
        name: 'AddNewPlaceScreen:uploadImage',
        error: e,
      );
      return null;
    }
  }

  void _saveForm() async {
    setState(() {
      _isUploading = true;
    });
    final pickedLocation = _locationInputController.pickedLocation;
    final locationImage = _userImagePickerController.selectedImage;
    bool isValid = _formKey.currentState!.validate();

    if (locationImage == null) {
      isValid = false;
      _userImagePickerController.showError(
        'Please add a valid image of this location.',
      );
    }

    if (pickedLocation == null) {
      isValid = false;
      _locationInputController.showError(
        'Please add a valid location.',
      );
    }

    if (!isValid) {
      setState(() {
        _isUploading = false;
      });
      return;
    }

    _formKey.currentState!.save();

    if (!mounted) return;

    Map<String, String>? storageData = await uploadImage(locationImage!);
    if (storageData == null) {
      setState(() {
        _isUploading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'We encountered an error uploading your image. Please try again later.',
          ),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('place_lists')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('places')
          .add({
            'name': _locationName,
            'dateAdded': FieldValue.serverTimestamp(),
            'imageUrl': storageData['imageUrl'],
            'imagePath': storageData['imagePath'],
            'location': pickedLocation!.toMap,
          })
          .timeout(
            Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Connection timeout.');
            },
          );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'We encountered an error, please try again later.',
          ),
        ),
      );
      return;
    } on TimeoutException catch (e) {
      if (!mounted) return;

      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'We encountered an error, please try again later.',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a Place')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUnfocus,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UserImagePicker(controller: _userImagePickerController),
                  SizedBox(height: 10),
                  LocationInput(controller: _locationInputController),
                  TextFormField(
                    autocorrect: true,
                    decoration: const InputDecoration(
                      labelText: 'Location Name',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name for this location.';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _locationName = newValue!;
                    },
                    onFieldSubmitted: (newValue) {
                      _saveForm();
                    },
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isUploading
                            ? null
                            : () {
                                _formKey.currentState!.reset();
                                _userImagePickerController.reset();
                                _locationInputController.reset();
                              },
                        child: Text(
                          'Clear',
                          style: _isUploading
                              ? TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.inverseSurface,
                                )
                              : null,
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isUploading ? null : _saveForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                        child: _isUploading
                            ? SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSecondaryContainer,
                                ),
                              )
                            : const Text('Submit'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

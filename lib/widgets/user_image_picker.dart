import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePickerController {
  _UserImagePickerState? _state;

  void _attach(_UserImagePickerState state) => _state = state;
  void _detach() => _state = null;

  void clearImage() {
    _state?.clearImage();
  }
}

class UserImagePicker extends StatefulWidget {
  final void Function(XFile) onPickedImage;
  final UserImagePickerController controller;
  const UserImagePicker({
    super.key,
    required this.onPickedImage,
    required this.controller,
  });

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  XFile? _pickedImageFile;

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

  void clearImage() {
    setState(() {
      _pickedImageFile = null;
    });
  }

  Future<ImageSource?> _pickImageSource() {
    return showModalBottomSheet<ImageSource?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.photo_library,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.of(ctx).pop(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.camera_alt,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.of(ctx).pop(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.grey),
                  title: const Text('Cancel'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _pickImage() async {
    final ImageSource? imageSrc = kIsWeb
        ? ImageSource.gallery
        : await _pickImageSource();

    if (imageSrc == null) {
      return;
    }

    final pickedImage = await ImagePicker().pickImage(
      source: imageSrc,
      imageQuality: 50,
      maxWidth: 250,
    );

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickedImageFile = pickedImage;
    });
    widget.onPickedImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      child: _pickedImageFile == null
          ? TextButton.icon(
              onPressed: _pickImage,
              label: const Text('Add Picture'),
              icon: const Icon(Icons.camera),
            )
          : kIsWeb
          ? GestureDetector(
              onTap: _pickImage,
              child: Image.network(
                _pickedImageFile!.path,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            )
          : GestureDetector(
              onTap: _pickImage,
              child: Image.file(
                File(_pickedImageFile!.path),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
    );
  }
}

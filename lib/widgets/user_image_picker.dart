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

  void showError(String msg){
    _state?.showError(msg);
  }

  void clearError(){
    _state?.clearError();
  }

  void reset(){
    _state?.clearImage();
    _state?.clearError();
  }

  XFile? get selectedImage {
    return _state?.selectedImage;
  }
}

class UserImagePicker extends StatefulWidget {
  final UserImagePickerController controller;
  const UserImagePicker({
    super.key,
    required this.controller,
  });

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  XFile? _pickedImageFile;
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

  void clearImage() {
    setState(() {
      _pickedImageFile = null;
    });
  }

  void clearError(){
    setState(() {
      _errorMsg = null;
    });
  }

  void showError(String msg){
    setState(() {
      _errorMsg = msg;
    });
  }

  XFile? get selectedImage {
    return _pickedImageFile;
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
        ),
        if (_errorMsg != null)
          Container(
            margin: EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              _errorMsg!,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

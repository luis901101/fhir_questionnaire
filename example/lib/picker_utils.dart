import 'dart:io';

import 'package:example/resource.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class PickerUtils {
  static Future<String?> _retrieveLostData() async {
    if (!Platform.isAndroid) return null;
    final LostDataResponse response = await ImagePicker().retrieveLostData();
    return response.file?.path != null ? response.file!.path : null;
  }

  static const String cameraAccessDenied = 'camera_access_denied';
  static const String galleryAccessDenied = 'photo_access_denied';

  static Future<List<PlatformFile>> handlePickerResponse(
      Future<Resource<List<PlatformFile>>> getCall,
      {bool closeBottomSheetAutomatically = true,
      required BuildContext context}) async {
    Resource<List<PlatformFile>> resource = await getCall;
    switch (resource.status) {
      case ResourceStatus.success:
        if ((resource.data?.isNotEmpty ?? false) &&
            closeBottomSheetAutomatically) {
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
        return resource.data ?? [];

      case ResourceStatus.error:
        if (context.mounted) {
          PickerUtils.showPermissionExplanation(
              context: context, message: resource.message);
        }
        break;

      default:
    }
    return [];
  }

  static Future<Resource<List<PlatformFile>>> _pickFrom({
    ImageSource source = ImageSource.camera,
    CameraDevice cameraDevice = CameraDevice.rear,
    bool multiple = true,
    bool pickImage = true,
    Duration? maxDuration,
  }) async {
    Resource<List<PlatformFile>> resource = Resource.success([]);

    List<PlatformFile> pickedFiles = [];
    try {
      Future<void> pickMultiple() async {
        final pickedXFiles = pickImage
            ? await ImagePicker().pickMultiImage(
                maxWidth: 1080
                    .toDouble(), //Inverted dimensions to prioritize portrait
                maxHeight: 1920,
                imageQuality: 100,
              )
            : await ImagePicker().pickMultipleMedia(
                maxWidth: 1080
                    .toDouble(), //Inverted dimensions to prioritize portrait
                maxHeight: 1920,
                imageQuality: 100,
              );
        for (final xFile in pickedXFiles) {
          pickedFiles
              .add(PlatformFile(path: xFile.path, name: xFile.name, size: 0));
        }
      }

      Future<void> pickSingle() async {
        final pickedXFile = pickImage
            ? await ImagePicker().pickImage(
                source: source,
                preferredCameraDevice: cameraDevice,
                maxWidth: 1080
                    .toDouble(), //Inverted dimensions to prioritize portrait
                maxHeight: 1920,
                imageQuality: 100,
              )
            : await ImagePicker().pickVideo(
                source: source,
                preferredCameraDevice: cameraDevice,
                maxDuration: maxDuration,
              );
        if (pickedXFile != null) {
          pickedFiles = [
            PlatformFile(
                path: pickedXFile.path, name: pickedXFile.name, size: 0)
          ];
        }
      }

      if (pickImage && multiple) {
        await pickMultiple();
      } else {
        await pickSingle();
      }

      if (pickedFiles.isEmpty) {
        final path = await _retrieveLostData();
        if (path != null) {
          pickedFiles.add(PlatformFile(path: path, name: '', size: 0));
        }
      }
      resource = Resource<List<PlatformFile>>.success(pickedFiles);
    } on PlatformException catch (e) {
      resource = Resource<List<PlatformFile>>.error([], e.message,
          exception: e, extras: e.details);
      switch (e.code) {
        case cameraAccessDenied:
          resource.message = 'Camera access denied, plase grant camera access.';
          break;
        case galleryAccessDenied:
          resource.message =
              'Gallery access denied, please grant gallery access.';
          break;
      }
    } catch (e) {
      resource =
          Resource<List<PlatformFile>>.error([], e.toString(), exception: e);
    }
    return resource;
  }

  static Future<Resource<List<PlatformFile>>> _pickFromEnhanced({
    ImageSource source = ImageSource.camera,
    CameraDevice cameraDevice = CameraDevice.rear,
    bool multiple = true,
    required FileType type,
    List<String>? allowedExtensions,
    Duration? maxDuration,
  }) async {
    Resource<List<PlatformFile>> resource = Resource.success([]);

    List<PlatformFile> pickedFiles = [];
    try {
      Future<void> pickFromGallery() async {
        final result = await FilePicker.platform.pickFiles(
          type: type,
          allowedExtensions: allowedExtensions,
          allowMultiple: multiple,
        );
        if (result != null) {
          pickedFiles = result.files;
        }
      }

      Future<void> pickFromCamera() async {
        final pickedXFile = type == FileType.image
            ? await ImagePicker().pickImage(
                source: source,
                preferredCameraDevice: cameraDevice,
                maxWidth: 1080
                    .toDouble(), //Inverted dimensions to prioritize portrait
                maxHeight: 1920,
                imageQuality: 100,
              )
            : await ImagePicker().pickVideo(
                source: source,
                preferredCameraDevice: cameraDevice,
                maxDuration: maxDuration,
              );
        if (pickedXFile != null) {
          pickedFiles = [
            PlatformFile(
                path: pickedXFile.path, name: pickedXFile.name, size: 0)
          ];
        }
      }

      if (source == ImageSource.gallery) {
        await pickFromGallery();
      } else {
        await pickFromCamera();
      }

      if (pickedFiles.isEmpty) {
        final path = await _retrieveLostData();
        if (path != null) {
          pickedFiles.add(PlatformFile(path: path, name: '', size: 0));
        }
      }
      resource = Resource<List<PlatformFile>>.success(pickedFiles);
    } on PlatformException catch (e) {
      resource = Resource<List<PlatformFile>>.error([], e.message,
          exception: e, extras: e.details);
      switch (e.code) {
        case cameraAccessDenied:
          resource.message = 'Camera access denied, plase grant camera access.';
          break;
        case galleryAccessDenied:
          resource.message =
              'Gallery access denied, please grant gallery access.';
          break;
      }
    } catch (e) {
      resource =
          Resource<List<PlatformFile>>.error([], e.toString(), exception: e);
    }
    return resource;
  }

  static Future<Resource<List<PlatformFile>>> pickFromGallery({
    bool multiple = true,
    bool pickImage = true,
    Duration? maxDuration,
  }) async =>
      await _pickFrom(
        source: ImageSource.gallery,
        multiple: multiple,
        pickImage: pickImage,
        maxDuration: maxDuration,
      );

  static Future<Resource<List<PlatformFile>>> pickFromGalleryEnhanced({
    bool multiple = true,
    required FileType type,
    List<String>? allowedExtensions,
    Duration? maxDuration,
  }) async =>
      await _pickFromEnhanced(
        source: ImageSource.gallery,
        multiple: multiple,
        type: type,
        allowedExtensions: allowedExtensions,
        maxDuration: maxDuration,
      );

  static Future<Resource<List<PlatformFile>>> takeFromCamera({
    CameraDevice cameraDevice = CameraDevice.rear,
    bool pickImage = true,
    Duration? maxDuration,
  }) async =>
      await _pickFrom(
        source: ImageSource.camera,
        cameraDevice: cameraDevice,
        multiple: false,
        pickImage: pickImage,
        maxDuration: maxDuration,
      );

  static void showPermissionExplanation(
      {required BuildContext context, String? message}) {
    showDialog(
        context: context,
        builder: (innerContext) => AlertDialog(
              title: const Text('Info'),
              content: Text(message ?? ''),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(innerContext).pop();
                    },
                    child: const Text('No')),
                TextButton(
                    onPressed: () {
                      Navigator.of(innerContext).pop();
                      Future.delayed(
                          const Duration(milliseconds: 300), () async {});
                    },
                    child: const Text('Yes'))
              ],
            ));
  }
}

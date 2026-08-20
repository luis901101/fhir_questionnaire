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

  static Future<List<XFile>> handlePickerResponse(
    Future<Resource<List<XFile>>> getCall, {
    bool closeBottomSheetAutomatically = true,
    required BuildContext context,
  }) async {
    Resource<List<XFile>> resource = await getCall;
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
            context: context,
            message: resource.message,
          );
        }
        break;

      default:
    }
    return [];
  }

  static Future<Resource<List<XFile>>> _pickFrom({
    ImageSource source = ImageSource.camera,
    CameraDevice cameraDevice = CameraDevice.rear,
    bool multiple = true,
    bool pickImage = true,
    Duration? maxDuration,
  }) async {
    Resource<List<XFile>> resource = Resource.success([]);

    List<XFile> pickedFiles = [];
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
        pickedFiles.addAll(pickedXFiles);
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
        pickedFiles = [?pickedXFile];
      }

      if (pickImage && multiple) {
        await pickMultiple();
      } else {
        await pickSingle();
      }

      if (pickedFiles.isEmpty) {
        final path = await _retrieveLostData();
        if (path != null) {
          pickedFiles.add(XFile(path));
        }
      }
      resource = Resource<List<XFile>>.success(pickedFiles);
    } on PlatformException catch (e) {
      resource = Resource<List<XFile>>.error(
        [],
        e.message,
        exception: e,
        extras: e.details,
      );
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
      resource = Resource<List<XFile>>.error([], e.toString(), exception: e);
    }
    return resource;
  }

  static Future<Resource<List<XFile>>> _pickFromEnhanced({
    ImageSource source = ImageSource.camera,
    CameraDevice cameraDevice = CameraDevice.rear,
    bool multiple = true,
    required FileType type,
    List<String>? allowedExtensions,
    Duration? maxDuration,
  }) async {
    Resource<List<XFile>> resource = Resource.success([]);

    List<XFile> pickedFiles = [];
    try {
      Future<void> pickFromGallery() async {
        // file_picker 12 deprecates `allowMultiple` in favour of a dedicated
        // single file entry point, and both now return the picked files
        // directly instead of a nullable result object.
        final List<PlatformFile> picked;
        if (multiple) {
          picked = await FilePicker.pickFiles(
            type: type,
            allowedExtensions: allowedExtensions,
          );
        } else {
          final file = await FilePicker.pickFile(
            type: type,
            allowedExtensions: allowedExtensions,
          );
          picked = [?file];
        }
        pickedFiles = [for (final file in picked) file.xFile];
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
        pickedFiles = [?pickedXFile];
      }

      if (source == ImageSource.gallery) {
        await pickFromGallery();
      } else {
        await pickFromCamera();
      }

      if (pickedFiles.isEmpty) {
        final path = await _retrieveLostData();
        if (path != null) {
          pickedFiles.add(XFile(path));
        }
      }
      resource = Resource<List<XFile>>.success(pickedFiles);
    } on PlatformException catch (e) {
      resource = Resource<List<XFile>>.error(
        [],
        e.message,
        exception: e,
        extras: e.details,
      );
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
      resource = Resource<List<XFile>>.error([], e.toString(), exception: e);
    }
    return resource;
  }

  static Future<Resource<List<XFile>>> pickFromGallery({
    bool multiple = true,
    bool pickImage = true,
    Duration? maxDuration,
  }) async => await _pickFrom(
    source: ImageSource.gallery,
    multiple: multiple,
    pickImage: pickImage,
    maxDuration: maxDuration,
  );

  static Future<Resource<List<XFile>>> pickFromGalleryEnhanced({
    bool multiple = true,
    required FileType type,
    List<String>? allowedExtensions,
    Duration? maxDuration,
  }) async => await _pickFromEnhanced(
    source: ImageSource.gallery,
    multiple: multiple,
    type: type,
    allowedExtensions: allowedExtensions,
    maxDuration: maxDuration,
  );

  static Future<Resource<List<XFile>>> takeFromCamera({
    CameraDevice cameraDevice = CameraDevice.rear,
    bool pickImage = true,
    Duration? maxDuration,
  }) async => await _pickFrom(
    source: ImageSource.camera,
    cameraDevice: cameraDevice,
    multiple: false,
    pickImage: pickImage,
    maxDuration: maxDuration,
  );

  static void showPermissionExplanation({
    required BuildContext context,
    String? message,
  }) {
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
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(innerContext).pop();
              Future.delayed(const Duration(milliseconds: 300), () async {});
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:example/resource.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
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

  static Future<List<String>> handlePickerResponse(
      Future<Resource<List<String>>> getCall,
      {bool closeBottomSheetAutomatically = true,
      required BuildContext context}) async {
    Resource<List<String>> resource = await getCall;
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

  static Future<Resource<List<String>>> _pickFrom({
    ImageSource source = ImageSource.camera,
    CameraDevice cameraDevice = CameraDevice.rear,
    bool multiple = true,
    bool pickImage = true,
    Duration? maxDuration,
  }) async {
    Resource<List<String>> resource = Resource.success([]);

    XFile? pickedFile;
    List<XFile>? pickedFiles;
    try {
      Future<void> pickMultiple() async {
        pickedFiles = pickImage
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
      }

      Future<void> pickSingle() async {
        pickedFile = pickImage
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
        if (pickedFile != null) pickedFiles = [pickedFile!];
      }

      if (pickImage && multiple) {
        await pickMultiple();
      } else {
        await pickSingle();
      }

      List<String> filePaths = [];
      String? path;
      pickedFiles?.forEach((item) => filePaths.add(item.path));
      if (filePaths.isEmpty) {
        path = await _retrieveLostData();
        if (path != null) filePaths.add(path);
      }
      resource = Resource<List<String>>.success(filePaths);
    } on PlatformException catch (e) {
      resource = Resource<List<String>>.error([], e.message,
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
      resource = Resource<List<String>>.error([], e.toString(), exception: e);
    }
    return resource;
  }

  static Future<Resource<List<String>>> _pickFromEnhanced({
    ImageSource source = ImageSource.camera,
    CameraDevice cameraDevice = CameraDevice.rear,
    bool multiple = true,
    required FileType type,
    List<String>? allowedExtensions,
    Duration? maxDuration,
  }) async {
    Resource<List<String>> resource = Resource.success([]);

    XFile? pickedFile;
    List<XFile>? pickedFiles;
    try {
      Future<void> pickFromGallery() async {
        final result = await FilePicker.platform.pickFiles(
          type: type,
          allowedExtensions: allowedExtensions,
          allowMultiple: multiple,
        );
        if (result != null) {
          pickedFiles = result.paths
              .mapWhere((path) => XFile(path!), (path) => path != null)
              .toList();
        }
      }

      Future<void> pickFromCamera() async {
        pickedFile = type == FileType.image
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
        if (pickedFile != null) pickedFiles = [pickedFile!];
      }

      if (source == ImageSource.gallery) {
        await pickFromGallery();
      } else {
        await pickFromCamera();
      }

      List<String> filePaths = [];
      String? path;
      pickedFiles?.forEach((item) => filePaths.add(item.path));
      if (filePaths.isEmpty) {
        path = await _retrieveLostData();
        if (path != null) filePaths.add(path);
      }
      resource = Resource<List<String>>.success(filePaths);
    } on PlatformException catch (e) {
      resource = Resource<List<String>>.error([], e.message,
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
      resource = Resource<List<String>>.error([], e.toString(), exception: e);
    }
    return resource;
  }

  static Future<Resource<List<String>>> pickFromGallery({
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

  static Future<Resource<List<String>>> pickFromGalleryEnhanced({
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

  static Future<Resource<List<String>>> takeFromCamera({
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

  static showPermissionExplanation(
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

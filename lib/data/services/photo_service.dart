import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Service for handling photo capture and storage.
class PhotoService {
  final ImagePicker _picker = ImagePicker();

  static const String _photoDirectory = 'catch_photos';
  static const int _maxImageWidth = 1200;
  static const int _maxImageHeight = 1200;
  static const int _imageQuality = 85;

  /// Takes a photo using the device camera.
  /// Returns the saved file path or null if cancelled/failed.
  Future<String?> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: _maxImageWidth.toDouble(),
        maxHeight: _maxImageHeight.toDouble(),
        imageQuality: _imageQuality,
      );

      if (image == null) return null;

      return await _saveImage(image);
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  /// Picks a photo from the device gallery.
  /// Returns the saved file path or null if cancelled/failed.
  Future<String?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: _maxImageWidth.toDouble(),
        maxHeight: _maxImageHeight.toDouble(),
        imageQuality: _imageQuality,
      );

      if (image == null) return null;

      return await _saveImage(image);
    } catch (e) {
      debugPrint('Error picking from gallery: $e');
      return null;
    }
  }

  /// Saves an image to the app's document directory.
  Future<String> _saveImage(XFile image) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String photoDir = p.join(appDir.path, _photoDirectory);

    // Ensure directory exists
    await Directory(photoDir).create(recursive: true);

    // Generate unique filename
    final String fileName =
        'catch_${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}';
    final String savedPath = p.join(photoDir, fileName);

    // Copy file to app directory
    await File(image.path).copy(savedPath);

    return savedPath;
  }

  /// Deletes a photo file.
  Future<void> deletePhoto(String? photoPath) async {
    if (photoPath == null || photoPath.isEmpty) return;

    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting photo: $e');
    }
  }

  /// Checks if a photo file exists.
  Future<bool> photoExists(String? photoPath) async {
    if (photoPath == null || photoPath.isEmpty) return false;

    try {
      return await File(photoPath).exists();
    } catch (e) {
      return false;
    }
  }

  /// Gets the photos directory path.
  Future<String> getPhotosDirectory() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    return p.join(appDir.path, _photoDirectory);
  }

  /// Cleans up orphaned photos not associated with any catch.
  Future<void> cleanupOrphanedPhotos(Set<String> validPhotoPaths) async {
    try {
      final photosDir = Directory(await getPhotosDirectory());
      if (!await photosDir.exists()) return;

      await for (final entity in photosDir.list()) {
        if (entity is File && !validPhotoPaths.contains(entity.path)) {
          await entity.delete();
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up orphaned photos: $e');
    }
  }
}

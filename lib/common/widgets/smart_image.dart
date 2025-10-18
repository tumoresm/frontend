import 'package:flutter/material.dart';
import 'dart:io';

/// A smart image widget that can handle both local files and network URLs
class SmartImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? errorWidget;
  final Widget? loadingWidget;

  const SmartImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit,
    this.errorWidget,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Check if it's a local file path
    if (_isLocalFile(imagePath)) {
      return _buildFileImage();
    } else {
      return _buildNetworkImage();
    }
  }

  /// Check if the path is a local file
  bool _isLocalFile(String path) {
    return path.startsWith('file://') || 
           path.startsWith('/') || 
           (path.length > 1 && path[1] == ':'); // Windows path like C:\
  }

  /// Build image from local file
  Widget _buildFileImage() {
    // Remove 'file://' prefix if present
    final cleanPath = imagePath.startsWith('file://') 
        ? imagePath.substring(7) 
        : imagePath;
    
    final file = File(cleanPath);
    
    // Check if file exists
    if (!file.existsSync()) {
      return _buildErrorWidget();
    }

    return Image.file(
      file,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  /// Build image from network URL
  Widget _buildNetworkImage() {
    return Image.network(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return loadingWidget ?? _buildLoadingWidget();
      },
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  /// Build error widget
  Widget _buildErrorWidget() {
    return errorWidget ?? 
        Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(
            Icons.broken_image,
            color: Colors.grey,
          ),
        );
  }

  /// Build loading widget
  Widget _buildLoadingWidget() {
    return loadingWidget ?? 
        Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
  }
}

/// A smart image provider that can handle both local files and network URLs
class SmartImageProvider {
  /// Get appropriate image provider based on image path
  static ImageProvider getImageProvider(String imagePath) {
    // Check if it's a local file path
    if (imagePath.startsWith('file://') || 
        imagePath.startsWith('/') || 
        (imagePath.length > 1 && imagePath[1] == ':')) {
      // Remove 'file://' prefix if present
      final cleanPath = imagePath.startsWith('file://') 
          ? imagePath.substring(7) 
          : imagePath;
      return FileImage(File(cleanPath));
    } else {
      // Assume it's a network URL
      return NetworkImage(imagePath);
    }
  }
}
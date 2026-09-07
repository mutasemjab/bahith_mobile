import 'package:flutter/material.dart';

import '../api/api_endpoints.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import 'shimmer_box.dart';

/// Rounded network image with shimmer placeholder and graceful
/// fallback icon — used for course covers, teacher photos, avatars.
class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double height;
  final double radius;
  final BoxFit fit;
  final IconData fallbackIcon;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    required this.height,
    this.radius = AppRadius.md,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image_rounded,
  });

  /// Normalizes image URLs: cleans linebreaks (\n, \r, \t), strips leading invalid
  /// characters (such as '*' or quotes), encodes spaces, and prepends host origin for relative paths.
  static String? formatUrl(String? rawUrl) {
    if (rawUrl == null) return null;
    String cleanUrl = rawUrl.replaceAll(RegExp(r'[\r\n\t]'), '').trim();
    if (cleanUrl.isEmpty) return null;

    // Remove any leading garbage (like '*', '"', '\'', bullet points, or control chars) before http:// or https://
    final httpsIdx = cleanUrl.indexOf('https://');
    final httpIdx = cleanUrl.indexOf('http://');
    if (httpsIdx != -1) {
      cleanUrl = cleanUrl.substring(httpsIdx);
    } else if (httpIdx != -1) {
      cleanUrl = cleanUrl.substring(httpIdx);
    } else {
      // Relative path: remove any leading symbols except '/'
      cleanUrl = cleanUrl.replaceAll(RegExp(r'^[^a-zA-Z0-9/]+'), '');
    }

    // Strip trailing quotes or symbols if any
    cleanUrl = cleanUrl.replaceAll(RegExp(r'["*\s]+$'), '');

    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      try {
        final baseUri = Uri.parse(ApiEndpoints.baseUrl);
        final origin = baseUri.origin;
        if (!cleanUrl.startsWith('/')) {
          cleanUrl = '/$cleanUrl';
        }
        cleanUrl = '$origin$cleanUrl';
      } catch (_) {}
    }

    cleanUrl = cleanUrl.replaceAll(' ', '%20');
    return cleanUrl;
  }

  @override
  Widget build(BuildContext context) {
    final formattedUrl = formatUrl(url);

    final placeholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(fallbackIcon, color: AppColors.border, size: 32),
    );

    if (formattedUrl == null || formattedUrl.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        formattedUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return ShimmerBox(width: width, height: height, radius: radius);
        },
        errorBuilder: (context, error, stackTrace) => placeholder,
      ),
    );
  }
}

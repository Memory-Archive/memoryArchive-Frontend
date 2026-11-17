import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smart_memories/core/themes/app_colors.dart';
import 'package:smart_memories/core/themes/app_text_styles.dart';

/// A flat tinted block shown where a photo is missing, loading or failed.
class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({super.key, this.tintIndex = 0, this.label});

  /// Picks one of AppColors.photoTints so neighbouring tiles differ.
  final int tintIndex;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.photoTint(tintIndex),
      child: label == null
          ? const SizedBox.expand()
          : Center(child: Text(label!, style: AppTextStyles.micro)),
    );
  }
}

/// A network image with disk caching. Falls back to a [PhotoPlaceholder]
/// when [url] is null or empty, while loading and on error. Size it from the
/// parent (SizedBox, AspectRatio, Expanded).
class AppCachedImage extends StatelessWidget {
  const AppCachedImage({
    super.key,
    required this.url,
    this.tintIndex = 0,
    this.placeholderLabel,
    this.radius = 0,
    this.fit = BoxFit.cover,
  });

  final String? url;
  final int tintIndex;
  final String? placeholderLabel;
  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final placeholder = PhotoPlaceholder(
      tintIndex: tintIndex,
      label: placeholderLabel,
    );
    final imageUrl = url;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: imageUrl == null || imageUrl.isEmpty
          ? placeholder
          : CachedNetworkImage(
              imageUrl: imageUrl,
              fit: fit,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => placeholder,
              errorWidget: (context, url, error) => placeholder,
            ),
    );
  }
}

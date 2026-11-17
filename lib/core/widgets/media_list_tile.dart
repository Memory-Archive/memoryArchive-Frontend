import 'package:flutter/material.dart';
import 'package:smart_memories/core/themes/app_spacing.dart';
import 'package:smart_memories/core/themes/app_text_styles.dart';
import 'package:smart_memories/core/widgets/app_cached_image.dart';
import 'package:smart_memories/core/widgets/app_card.dart';

/// A card row with a square thumbnail, a title and a muted subtitle.
/// Used for memories on Home; reusable for search results and collections.
class MediaListTile extends StatelessWidget {
  const MediaListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.tintIndex = 0,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String? imageUrl;
  final int tintIndex;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          SizedBox.square(
            dimension: AppSizes.thumbnail,
            child: AppCachedImage(
              url: imageUrl,
              tintIndex: tintIndex,
              radius: AppRadii.tile,
            ),
          ),
          AppGap.h14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: AppTextStyles.bodyStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppGap.v2,
                Text(
                  subtitle,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

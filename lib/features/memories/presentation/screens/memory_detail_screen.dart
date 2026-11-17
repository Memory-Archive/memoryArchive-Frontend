import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_memories/core/constants/app_strings.dart';
import 'package:smart_memories/core/helpers/date_formatter.dart';
import 'package:smart_memories/core/helpers/extensions.dart';
import 'package:smart_memories/core/routing/app_routes.dart';
import 'package:smart_memories/core/themes/app_colors.dart';
import 'package:smart_memories/core/themes/app_spacing.dart';
import 'package:smart_memories/core/themes/app_text_styles.dart';
import 'package:smart_memories/core/widgets/app_button.dart';
import 'package:smart_memories/core/widgets/app_cached_image.dart';
import 'package:smart_memories/core/widgets/app_chip.dart';
import 'package:smart_memories/core/widgets/circle_icon_button.dart';
import 'package:smart_memories/core/widgets/state_views.dart';
import 'package:smart_memories/features/memories/domain/entities/memory.dart';
import 'package:smart_memories/features/memories/presentation/cubit/memory_detail_cubit.dart';
import 'package:smart_memories/features/memories/presentation/cubit/memory_detail_state.dart';

class MemoryDetailScreen extends StatelessWidget {
  const MemoryDetailScreen({super.key, required this.memoryId});

  final String memoryId;

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = context.read<MemoryDetailCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this memory?'),
        content: const Text(
          'The memory and its photos will be removed for everyone it is shared with.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await cubit.delete(memoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<MemoryDetailCubit, MemoryDetailState>(
        listener: (context, state) {
          if (state is MemoryDetailDeleted) {
            context.showSnack('Memory deleted.');
            context.go(AppRoutes.home);
          }
        },
        builder: (context, state) {
          return switch (state) {
            MemoryDetailSuccess(:final memory) => _MemoryView(
              memory: memory,
              onBack: () => _close(context),
              onDelete: () => _confirmDelete(context),
            ),
            MemoryDetailFailure(:final error) => SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      AppSpacing.x12,
                      AppSpacing.page,
                      0,
                    ),
                    child: CircleIconButton(
                      icon: Icons.chevron_left,
                      semanticLabel: 'Back',
                      onPressed: () => _close(context),
                    ),
                  ),
                  Expanded(
                    child: ErrorState(
                      message: error.message,
                      onRetry: () =>
                          context.read<MemoryDetailCubit>().load(memoryId),
                    ),
                  ),
                ],
              ),
            ),
            _ => const AppLoader(),
          };
        },
      ),
    );
  }
}

class _MemoryView extends StatelessWidget {
  const _MemoryView({
    required this.memory,
    required this.onBack,
    required this.onDelete,
  });

  /// How many thumbnails sit beside the "+N more" tile.
  static const int _thumbCount = 3;

  final Memory memory;
  final VoidCallback onBack;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final place = memory.placeName;
    final description = memory.description;
    final collection = memory.collectionName;
    final extraPhotos = memory.photoCount - 1 - _thumbCount;
    final isShared = memory.sharedWithCount > 0 && collection != null;

    return Column(
      children: <Widget>[
        _Cover(memory: memory, onBack: onBack),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.x22,
              AppSpacing.page,
              AppSpacing.x24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(memory.title, style: AppTextStyles.headline),
                AppGap.v8,
                _IconLine(
                  icon: Icons.calendar_today_outlined,
                  text: AppDateFormat.full(memory.memoryDate),
                ),
                if (place != null) ...<Widget>[
                  AppGap.v4,
                  InkWell(
                    onTap: () => context.push(AppRoutes.map),
                    child: _IconLine(
                      icon: Icons.place_outlined,
                      text: '$place · Show on map',
                      color: AppColors.primary,
                      strong: true,
                    ),
                  ),
                ],
                if (description != null && description.isNotEmpty) ...<Widget>[
                  AppGap.v18,
                  Text(
                    description,
                    style: AppTextStyles.body.copyWith(height: 1.55),
                  ),
                ],
                if (memory.photoCount > 1) ...<Widget>[
                  AppGap.v18,
                  _PhotoStrip(memory: memory, extraPhotos: extraPhotos),
                ],
                if (collection != null || memory.tags.isNotEmpty) ...<Widget>[
                  AppGap.v18,
                  Wrap(
                    spacing: AppSpacing.x8,
                    runSpacing: AppSpacing.x8,
                    children: <Widget>[
                      if (collection != null)
                        AppChip(
                          label: collection,
                          tinted: true,
                          onTap: () => context.push(AppRoutes.collections),
                        ),
                      for (final tag in memory.tags) AppChip(label: tag),
                    ],
                  ),
                ],
                AppGap.v18,
                Text(
                  isShared
                      ? 'Shared with ${memory.sharedWithCount} members of '
                            '$collection. Only you can edit or delete it.'
                      : 'Only you can see this memory unless you add it to '
                            'a shared collection.',
                  style: AppTextStyles.caption,
                ),
                AppGap.v24,
                AppButton(
                  label: 'Delete memory',
                  variant: AppButtonVariant.dangerOutline,
                  size: AppButtonSize.medium,
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.memory, required this.onBack});

  final Memory memory;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.detailCover,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AppCachedImage(url: memory.coverUrl, placeholderLabel: 'Cover photo'),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x18,
                AppSpacing.x12,
                AppSpacing.x18,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CircleIconButton(
                    icon: Icons.chevron_left,
                    semanticLabel: 'Back',
                    bordered: false,
                    onPressed: onBack,
                  ),
                  AppButton(
                    label: 'Edit',
                    variant: AppButtonVariant.surface,
                    size: AppButtonSize.pill,
                    expand: false,
                    // As in the design, Edit opens the editor. The design has
                    // no edit mode yet, so the editor opens empty (see
                    // README, "Missing from the design").
                    onPressed: () => context.push(AppRoutes.memoryNew),
                  ),
                ],
              ),
            ),
          ),
          if (memory.photoCount > 0)
            Positioned(
              right: AppSpacing.x18,
              bottom: AppSpacing.x16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(AppRadii.field),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x10,
                    vertical: AppSpacing.x4,
                  ),
                  child: Text(
                    '1 of ${memory.photoCount}',
                    style: AppTextStyles.micro.copyWith(
                      color: AppColors.surface,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({
    required this.icon,
    required this.text,
    this.color = AppColors.muted,
    this.strong = false,
  });

  final IconData icon;
  final String text;
  final Color color;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = strong ? AppTextStyles.bodySmStrong : AppTextStyles.bodySm;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.x2),
      child: Row(
        children: <Widget>[
          Icon(icon, size: AppSizes.iconSmall, color: color),
          AppGap.h8,
          Expanded(child: Text(text, style: style.copyWith(color: color))),
        ],
      ),
    );
  }
}

class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({required this.memory, required this.extraPhotos});

  final Memory memory;
  final int extraPhotos;

  @override
  Widget build(BuildContext context) {
    final shown = (memory.photoCount - 1).clamp(0, _MemoryView._thumbCount);

    return SizedBox(
      height: AppSizes.detailThumb,
      child: Row(
        children: <Widget>[
          for (var i = 0; i < _MemoryView._thumbCount + 1; i++) ...<Widget>[
            if (i > 0) AppGap.h8,
            Expanded(
              child: i < shown
                  ? AppCachedImage(
                      url: i < memory.photoUrls.length
                          ? memory.photoUrls[i]
                          : null,
                      tintIndex: i + 1,
                      radius: AppRadii.thumb,
                    )
                  : i == _MemoryView._thumbCount && extraPhotos > 0
                  ? _MoreTile(count: extraPhotos)
                  : const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.thumb),
        side: const BorderSide(
          color: AppColors.fieldBorder,
          width: AppSizes.borderWidth,
        ),
      ),
      child: InkWell(
        onTap: () => context.showSnack(AppStrings.notAvailableYet),
        child: Center(child: Text('+$count more', style: AppTextStyles.link)),
      ),
    );
  }
}

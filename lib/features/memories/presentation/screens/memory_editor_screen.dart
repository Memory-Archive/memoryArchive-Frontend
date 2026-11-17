import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_memories/core/constants/app_strings.dart';
import 'package:smart_memories/core/constants/env.dart';
import 'package:smart_memories/core/helpers/date_formatter.dart';
import 'package:smart_memories/core/helpers/extensions.dart';
import 'package:smart_memories/core/routing/app_routes.dart';
import 'package:smart_memories/core/themes/app_colors.dart';
import 'package:smart_memories/core/themes/app_spacing.dart';
import 'package:smart_memories/core/themes/app_text_styles.dart';
import 'package:smart_memories/core/validation/validated_text_field.dart';
import 'package:smart_memories/core/validation/validators.dart';
import 'package:smart_memories/core/widgets/app_button.dart';
import 'package:smart_memories/core/widgets/app_cached_image.dart';
import 'package:smart_memories/core/widgets/app_text_field.dart';
import 'package:smart_memories/core/widgets/dashed_border_box.dart';
import 'package:smart_memories/features/memories/domain/entities/memory.dart';
import 'package:smart_memories/features/memories/presentation/cubit/memory_editor_cubit.dart';
import 'package:smart_memories/features/memories/presentation/cubit/memory_editor_state.dart';

class MemoryEditorScreen extends StatefulWidget {
  const MemoryEditorScreen({super.key});

  @override
  State<MemoryEditorScreen> createState() => _MemoryEditorScreenState();
}

class _MemoryEditorScreenState extends State<MemoryEditorScreen> {
  static const int _titleMaxLength = 200;
  static const int _descriptionMaxLength = 10000;
  static const int _photoColumns = 4;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _dateText = TextEditingController();
  final TextEditingController _timeText = TextEditingController();

  DateTime _date = DateTime.now();
  TimeOfDay? _time;

  @override
  void initState() {
    super.initState();
    _dateText.text = AppDateFormat.short(_date);
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _dateText.dispose();
    _timeText.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() => _date = picked);
    _dateText.text = AppDateFormat.short(picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked == null) return;
    setState(() => _time = picked);
    _timeText.text = _formatTime(picked);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final description = _description.text.trim();
    final time = _time;
    context.read<MemoryEditorCubit>().save(
      MemoryDraft(
        title: _title.text.trim(),
        memoryDate: _date,
        memoryTime: time == null ? null : _formatTime(time),
        description: description.isEmpty ? null : description,
      ),
    );
  }

  void _cancel() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _notAvailable() => context.showSnack(AppStrings.notAvailableYet);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MemoryEditorCubit, MemoryEditorState>(
      listener: (context, state) {
        switch (state) {
          case MemoryEditorSuccess(:final memory):
            // Saved: replace the editor with the new memory's page.
            context.pushReplacement(AppRoutes.memory(memory.id));
          case MemoryEditorFailure(:final error)
              when error.fieldErrors.isEmpty:
            context.showSnack(error.message);
          default:
            break;
        }
      },
      builder: (context, state) {
        final error = switch (state) {
          MemoryEditorFailure(:final error) => error,
          _ => null,
        };

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.x12,
                AppSpacing.page,
                AppSpacing.x24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _Header(
                      isSaving: state is MemoryEditorLoading,
                      onCancel: _cancel,
                      onSave: _save,
                    ),
                    AppGap.v18,
                    ValidatedTextField(
                      label: 'Title',
                      controller: _title,
                      hint: 'What happened?',
                      textInputAction: TextInputAction.next,
                      serverError: error?.messageFor('title'),
                      validators: <Validator>[
                        Validators.required('Title'),
                        Validators.maxLength(_titleMaxLength, 'Title'),
                      ],
                    ),
                    AppGap.v16,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: AppTextField(
                            label: 'Date',
                            controller: _dateText,
                            readOnly: true,
                            onTap: _pickDate,
                            errorText: error?.messageFor('memoryDate'),
                          ),
                        ),
                        AppGap.h12,
                        Expanded(
                          child: AppTextField(
                            label: 'Time (optional)',
                            controller: _timeText,
                            hint: '--:--',
                            readOnly: true,
                            onTap: _pickTime,
                          ),
                        ),
                      ],
                    ),
                    AppGap.v16,
                    const Text('Place', style: AppTextStyles.label),
                    AppGap.v6,
                    _PickerRow(
                      icon: Icons.place_outlined,
                      label: 'Search or drop a pin on the map',
                      onTap: _notAvailable,
                    ),
                    AppGap.v16,
                    ValidatedTextField(
                      label: 'Description',
                      controller: _description,
                      hint: 'Who was there, what you want to remember…',
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      serverError: error?.messageFor('description'),
                      validators: <Validator>[
                        Validators.maxLength(
                          _descriptionMaxLength,
                          'Description',
                        ),
                      ],
                    ),
                    AppGap.v16,
                    const Text('Photos', style: AppTextStyles.label),
                    AppGap.v8,
                    _PhotoGrid(columns: _photoColumns, onAdd: _notAvailable),
                    AppGap.v8,
                    const Text(
                      'JPEG or PNG, up to 10 MB each.',
                      style: AppTextStyles.small,
                    ),
                    AppGap.v16,
                    _PickerRow(
                      label: 'Add to a collection',
                      trailing: 'None',
                      onTap: _notAvailable,
                    ),
                    AppGap.v24,
                    const Text(
                      'Only you can see this memory unless you add it to a '
                      'shared collection.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.small,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
  });

  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.text,
          size: AppButtonSize.pill,
          expand: false,
          onPressed: onCancel,
        ),
        const Text('New memory', style: AppTextStyles.titleSm),
        AppButton(
          label: 'Save',
          size: AppButtonSize.pill,
          expand: false,
          isLoading: isSaving,
          onPressed: onSave,
        ),
      ],
    );
  }
}

/// A field-shaped button that opens a picker (place, collection).
class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.label,
    required this.onTap,
    this.icon,
    this.trailing,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final hasValue = trailing != null;
    return Semantics(
      button: true,
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.field),
          side: const BorderSide(
            color: AppColors.fieldBorder,
            width: AppSizes.borderWidth,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.field),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x14),
              child: Row(
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    Icon(
                      icon,
                      size: AppSizes.iconMedium,
                      color: AppColors.muted,
                    ),
                    AppGap.h10,
                  ],
                  Expanded(
                    child: Text(
                      label,
                      style: hasValue
                          ? AppTextStyles.body
                          : AppTextStyles.bodyMuted,
                    ),
                  ),
                  if (trailing != null)
                    Text(trailing!, style: AppTextStyles.bodyMuted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One row of photo tiles ending with the dashed "add" tile.
///
/// Photo picking and upload are not implemented (no picker package is in the
/// agreed stack). In mock mode the three sample tiles from the design are
/// shown, including an upload in progress, so the layout can be reviewed.
class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.columns, required this.onAdd});

  final int columns;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      if (Env.useMock) ...const <Widget>[
        _PhotoTile(tintIndex: 0, label: 'Cover'),
        _PhotoTile(tintIndex: 1, label: 'Photo'),
        _PhotoTile(tintIndex: 2, uploadProgress: 0.6),
      ],
      _AddPhotoTile(onTap: onAdd),
    ];

    return SizedBox(
      height: AppSizes.photoTile,
      child: Row(
        children: <Widget>[
          for (var i = 0; i < columns; i++) ...<Widget>[
            if (i > 0) AppGap.h8,
            Expanded(
              child: i < tiles.length ? tiles[i] : const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.tintIndex, this.label, this.uploadProgress});

  final int tintIndex;
  final String? label;

  /// 0.0 to 1.0 while uploading, null when done.
  final double? uploadProgress;

  @override
  Widget build(BuildContext context) {
    final progress = uploadProgress;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.tile),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          PhotoPlaceholder(tintIndex: tintIndex, label: label),
          if (progress != null)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: AppSizes.progressBarWidth,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: AppSizes.progressBarHeight,
                      semanticsLabel: 'Uploading photo',
                    ),
                  ),
                ),
                AppGap.v6,
                Text(
                  '${(progress * 100).round()}%',
                  style: AppTextStyles.micro,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add photos',
      child: DashedBorderBox(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.tile),
          child: const Center(
            child: Icon(
              Icons.add,
              size: AppSizes.iconLarge,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

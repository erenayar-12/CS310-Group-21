import 'package:flutter/material.dart';
import '../../../data/habit.dart';

class HabitCard extends StatefulWidget {
  const HabitCard({
    required this.habit,
    required this.index,
    required this.isHovered,
    required this.onHabitSelected,
    required this.onHoverChanged,
    this.onDelete,
    this.onComplete,
    super.key,
  });

  final Habit habit;
  final int index;
  final bool isHovered;
  final ValueChanged<Habit> onHabitSelected;
  final ValueChanged<int?> onHoverChanged;
  final ValueChanged<Habit>? onDelete;
  final ValueChanged<Habit>? onComplete;

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  bool _isDeleteHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Light mode: siyah tonlar kalsın
    // Dark mode: temadan gelen açık renkleri kullan
    final titleColor = isDark ? colorScheme.onSurface : Colors.black87;
    final secondaryTextColor =
        isDark ? colorScheme.onSurfaceVariant : Colors.black87;
    final bodyColor = isDark ? colorScheme.onSurface : Colors.black87;

    final cardColor = isDark
        ? colorScheme.surfaceContainerHighest
        : colorScheme.surface;

    final emojiBgColor =
        isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade100;

    final progressTrackColor =
        isDark ? Colors.white.withOpacity(0.12) : AppColors.cardBackgroundLight;

    final shadowOpacityBase = isDark ? 0.08 : 0.18;
    final shadowOpacityHover = isDark ? 0.14 : 0.30;

    return MouseRegion(
      onEnter: (_) => widget.onHoverChanged(widget.index),
      onExit: (_) => widget.onHoverChanged(null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                widget.isHovered ? shadowOpacityHover : shadowOpacityBase,
              ),
              blurRadius: widget.isHovered ? 14 : 10,
              offset: Offset(0, widget.isHovered ? 8 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => widget.onHabitSelected(widget.habit),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: emojiBgColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.habit.emoji ?? '🗒️',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.habit.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: titleColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (widget.onDelete != null &&
                                  widget.habit.id != null)
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  onEnter: (_) =>
                                      setState(() => _isDeleteHovered = true),
                                  onExit: (_) =>
                                      setState(() => _isDeleteHovered = false),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: _isDeleteHovered
                                          ? (isDark
                                              ? Colors.red.withOpacity(0.18)
                                              : Colors.red.shade50)
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _isDeleteHovered
                                            ? Colors.red
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                      boxShadow: _isDeleteHovered
                                          ? [
                                              BoxShadow(
                                                color:
                                                    Colors.red.withOpacity(0.35),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        size: 20,
                                        color: _isDeleteHovered
                                            ? Colors.red.shade700
                                            : Colors.red.shade400,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () => _showDeleteDialog(context),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.habit.frequencyLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.habit.streakLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: secondaryTextColor,
                            ),
                          ),
                          if (widget.habit.description != null &&
                              widget.habit.description!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              widget.habit.description!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: bodyColor,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: widget.habit.progress.clamp(0.0, 1.0),
                              minHeight: 8,
                              backgroundColor: progressTrackColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (widget.onComplete != null && widget.habit.id != null)
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: widget.habit.progress >= 1.0
                                    ? null
                                    : () => widget.onComplete?.call(widget.habit),
                                icon: Icon(
                                  widget.habit.progress >= 1.0
                                      ? Icons.check_circle
                                      : Icons.check,
                                  size: 18,
                                ),
                                label: Text(
                                  'Done',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: widget.habit.progress >= 1.0
                                      ? (isDark
                                          ? Colors.green.shade700
                                          : Colors.green)
                                      : colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  disabledBackgroundColor: isDark
                                      ? Colors.white.withOpacity(0.12)
                                      : null,
                                  disabledForegroundColor: isDark
                                      ? Colors.white.withOpacity(0.60)
                                      : null,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${widget.habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete?.call(widget.habit);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

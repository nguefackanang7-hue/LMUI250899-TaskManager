import 'package:flutter/material.dart';
import '../main.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  Color get priorityColor {
    switch (task.priority) {
      case 'High':
        return AppColors.danger;
      case 'Medium':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  IconData get categoryIcon {
    switch (task.category) {
      case 'Work':
        return Icons.work_outline_rounded;
      case 'Personal':
        return Icons.person_outline_rounded;
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      case 'Health':
        return Icons.favorite_outline_rounded;
      default:
        return Icons.task_outlined;
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: priorityColor, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(categoryIcon, color: priorityColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: task.isCompleted
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _Pill(label: task.category, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        _Pill(label: task.priority, color: priorityColor),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (task.isCompleted)
                    const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18)
                  else if (isOverdue)
                    const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 18),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(task.dueDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue && !task.isCompleted
                          ? AppColors.danger
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

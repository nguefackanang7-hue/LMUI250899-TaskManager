import 'package:flutter/material.dart';
import '../main.dart';
import '../models/task.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final ValueChanged<Task> onUpdate;
  final VoidCallback onDelete;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task taskCopy;

  @override
  void initState() {
    super.initState();
    taskCopy = widget.task;
  }

  String _formatFullDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color get priorityColor {
    switch (taskCopy.priority) {
      case 'High': return AppColors.danger;
      case 'Medium': return AppColors.warning;
      default: return AppColors.success;
    }
  }

  IconData get categoryIcon {
    switch (taskCopy.category) {
      case 'Work': return Icons.work_outline_rounded;
      case 'Personal': return Icons.person_outline_rounded;
      case 'Shopping': return Icons.shopping_bag_outlined;
      case 'Health': return Icons.favorite_outline_rounded;
      default: return Icons.task_outlined;
    }
  }

  void toggleCompletion() {
    setState(() => taskCopy.isCompleted = !taskCopy.isCompleted);
    widget.onUpdate(taskCopy);
  }

  Future<void> showEditTaskSheet() async {
    final titleController = TextEditingController(text: taskCopy.title);
    final descController = TextEditingController(text: taskCopy.description);
    String selCategory = taskCopy.category;
    String selPriority = taskCopy.priority;
    DateTime selDate = taskCopy.dueDate;
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Edit Task',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 24),
                  _buildField(titleController, 'Task Title', Icons.title_rounded,
                    validator: (v) => (v == null || v.isEmpty) ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildField(descController, 'Description', Icons.notes_rounded,
                    maxLines: 3,
                    validator: (v) => (v == null || v.isEmpty) ? 'Description is required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildDropdown('Category', selCategory,
                        ['Work', 'Personal', 'Shopping', 'Health'],
                        Icons.label_outline_rounded, AppColors.secondary,
                        (v) => setModal(() => selCategory = v!),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDropdown('Priority', selPriority,
                        ['High', 'Medium', 'Low'],
                        Icons.flag_outlined, AppColors.warning,
                        (v) => setModal(() => selPriority = v!),
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        builder: (ctx, child) => Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(primary: AppColors.primary),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) setModal(() => selDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined, color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Due: ${_formatFullDate(selDate)}',
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          if (formKey.currentState?.validate() == true) {
                            setState(() {
                              taskCopy.title = titleController.text;
                              taskCopy.description = descController.text;
                              taskCopy.category = selCategory;
                              taskCopy.priority = selPriority;
                              taskCopy.dueDate = selDate;
                            });
                            widget.onUpdate(taskCopy);
                            Navigator.pop(ctx);
                          }
                        },
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.danger)),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    IconData icon,
    Color color,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        dropdownColor: AppColors.surfaceLight,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          prefixIcon: Icon(icon, color: color, size: 18),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Task?', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        content: const Text('This action cannot be undone.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = taskCopy.dueDate.isBefore(DateTime.now()) && !taskCopy.isCompleted;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  taskCopy.isCompleted ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                  color: taskCopy.isCompleted ? AppColors.success : AppColors.textSecondary,
                ),
                onPressed: toggleCompletion,
                tooltip: taskCopy.isCompleted ? 'Mark incomplete' : 'Mark complete',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                onPressed: confirmDelete,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [priorityColor.withValues(alpha: 0.3), AppColors.surface],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: priorityColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(categoryIcon, color: priorityColor, size: 24),
                            ),
                            const SizedBox(width: 12),
                            _chip(taskCopy.category, AppColors.secondary),
                            const SizedBox(width: 8),
                            _chip(taskCopy.priority, priorityColor),
                            if (isOverdue) ...[
                              const SizedBox(width: 8),
                              _chip('Overdue', AppColors.danger),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          taskCopy.title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            decoration: taskCopy.isCompleted ? TextDecoration.lineThrough : null,
                            decorationColor: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoCard(
                    'Status',
                    taskCopy.isCompleted ? 'Completed' : 'Pending',
                    Icons.radio_button_checked_rounded,
                    taskCopy.isCompleted ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(height: 12),
                  _infoCard(
                    'Due Date',
                    _formatFullDate(taskCopy.dueDate),
                    Icons.calendar_today_outlined,
                    isOverdue ? AppColors.danger : AppColors.secondary,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      taskCopy.description,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.6),
                    ),
                  ),
                  if (isOverdue) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'This task is overdue. Update the due date or mark it complete.',
                              style: TextStyle(color: AppColors.danger, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: showEditTaskSheet,
            borderRadius: BorderRadius.circular(16),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Edit Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _infoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

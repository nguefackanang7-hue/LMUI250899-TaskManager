import 'package:flutter/material.dart';
import '../main.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];
  String searchQuery = '';
  String selectedFilter = 'All';
  bool showSearchField = false;

  final List<String> categories = ['Work', 'Personal', 'Shopping', 'Health'];
  final List<String> priorities = ['High', 'Medium', 'Low'];
  final List<String> filters = ['All', 'Pending', 'Completed'];

  List<Task> get filteredTasks {
    return tasks.where((task) {
      final matchesFilter = selectedFilter == 'All' ||
          (selectedFilter == 'Completed' && task.isCompleted) ||
          (selectedFilter == 'Pending' && !task.isCompleted);
      final matchesSearch = searchQuery.isEmpty ||
          task.title.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  int get totalTasks => tasks.length;
  int get completedTasks => tasks.where((t) => t.isCompleted).length;
  int get pendingTasks => tasks.where((t) => !t.isCompleted).length;
  double get completionRate => totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

  String _formatFullDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void sortByDate() => setState(() => tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate)));

  void sortByPriority() {
    const order = {'High': 1, 'Medium': 2, 'Low': 3};
    setState(() => tasks.sort((a, b) => order[a.priority]!.compareTo(order[b.priority]!)));
  }

  void deleteTask(Task task) => setState(() => tasks.remove(task));

  Future<void> clearAllTasks() async {
    if (tasks.isEmpty) return;
    final confirmed = await _showConfirmDialog(
      'Clear All Tasks',
      'This will permanently delete all tasks. Continue?',
    );
    if (confirmed == true) setState(() => tasks.clear());
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(color: AppColors.textSecondary)),
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
  }

  void showAddTaskSheet({Task? existingTask}) {
    final titleController = TextEditingController(text: existingTask?.title ?? '');
    final descController = TextEditingController(text: existingTask?.description ?? '');
    String selCategory = existingTask?.category ?? categories[0];
    String selPriority = existingTask?.priority ?? priorities[0];
    DateTime selDate = existingTask?.dueDate ?? DateTime.now();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
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
                  Text(
                    existingTask == null ? 'New Task' : 'Edit Task',
                    style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
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
                      Expanded(child: _buildDropdown('Category', selCategory, categories,
                        Icons.label_outline_rounded, AppColors.secondary,
                        (v) => setModal(() => selCategory = v!),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDropdown('Priority', selPriority, priorities,
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
                          if (formKey.currentState!.validate()) {
                            if (existingTask == null) {
                              setState(() {
                                tasks.add(Task(
                                  title: titleController.text,
                                  description: descController.text,
                                  category: selCategory,
                                  priority: selPriority,
                                  dueDate: selDate,
                                ));
                              });
                            } else {
                              setState(() {
                                existingTask.title = titleController.text;
                                existingTask.description = descController.text;
                                existingTask.category = selCategory;
                                existingTask.priority = selPriority;
                                existingTask.dueDate = selDate;
                              });
                            }
                            Navigator.pop(ctx);
                          }
                        },
                        child: Text(
                          existingTask == null ? 'Create Task' : 'Update Task',
                          style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white,
                          ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsCard(),
            _buildFilterRow(),
            if (showSearchField) _buildSearchBar(),
            Expanded(child: _buildTaskList()),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 2),
                const Text(
                  'My Tasks',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              showSearchField ? Icons.search_off_rounded : Icons.search_rounded,
              color: AppColors.textSecondary,
            ),
            onPressed: () => setState(() {
              showSearchField = !showSearchField;
              if (!showSearchField) searchQuery = '';
            }),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune_rounded, color: AppColors.textSecondary),
            color: AppColors.surfaceLight,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (v) {
              if (v == 'Date') sortByDate();
              if (v == 'Priority') sortByPriority();
              if (v == 'Clear') clearAllTasks();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'Date', child: Row(children: [Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.secondary), SizedBox(width: 10), Text('Sort by Date', style: TextStyle(color: AppColors.textPrimary))])),
              const PopupMenuItem(value: 'Priority', child: Row(children: [Icon(Icons.flag_outlined, size: 18, color: AppColors.warning), SizedBox(width: 10), Text('Sort by Priority', style: TextStyle(color: AppColors.textPrimary))])),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'Clear', child: Row(children: [Icon(Icons.delete_sweep_outlined, size: 18, color: AppColors.danger), SizedBox(width: 10), Text('Clear All', style: TextStyle(color: AppColors.danger))])),
            ],
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF5B21B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statColumn('Total', totalTasks),
              _divider(),
              _statColumn('Done', completedTasks),
              _divider(),
              _statColumn('Pending', pendingTasks),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: completionRate,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(completionRate * 100).round()}% complete',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.2));
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: filters.map((f) {
          final isActive = f == selectedFilter;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedFilter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.border,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  f,
                  style: TextStyle(
                    color: isActive ? Colors.white : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: TextField(
        autofocus: true,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (v) => setState(() => searchQuery = v),
      ),
    );
  }

  Widget _buildTaskList() {
    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline_rounded, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              tasks.isEmpty ? 'No tasks yet' : 'No tasks match this filter',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              tasks.isEmpty ? 'Tap + to add your first task' : 'Try a different filter',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 100),
      itemCount: filteredTasks.length,
      itemBuilder: (_, i) {
        final task = filteredTasks[i];
        return Dismissible(
          key: ValueKey(task),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
                SizedBox(width: 8),
              ],
            ),
          ),
          onDismissed: (_) => deleteTask(task),
          child: TaskCard(
            task: task,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskDetailScreen(
                    task: task,
                    onUpdate: (_) => setState(() {}),
                    onDelete: () {
                      deleteTask(task);
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFab() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: showAddTaskSheet,
          borderRadius: BorderRadius.circular(18),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('New Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

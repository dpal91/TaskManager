import 'package:flutter/material.dart';

class Task {
  String title;
  String description;
  DateTime? dateTime;

  Task({
    required this.title,
    required this.description,
    this.dateTime,
  });
}

String formatDateHeader(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final input = DateTime(date.year, date.month, date.day);
  final diff = input.difference(today).inDays;

  if (diff < 0) return 'Overdue';
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';

  return '${input.day} ${_monthName(input.month)} ${input.year}';
}

String _monthName(int month) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return months[month - 1];
}

Map<String, List<Task>> groupTasksByDate(List<Task> tasks) {
  final Map<String, List<Task>> grouped = {};

  for (var task in tasks) {
    final key = task.dateTime != null ? formatDateHeader(task.dateTime!) : 'Unscheduled';

    grouped.putIfAbsent(key, () => []);
    grouped[key]!.add(task);
  }

  return grouped;
}

class HomePage_back extends StatefulWidget {
  const HomePage_back({Key? key}) : super(key: key);

  @override
  State<HomePage_back> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage_back> {
  final List<Task> _tasks = [];

  Future<void> _addOrEditTask({Task? task, int? index}) async {
    final titleController = TextEditingController(text: task?.title ?? '');
    final descController = TextEditingController(text: task?.description ?? '');

    DateTime? selectedDate = task?.dateTime;
    TimeOfDay? selectedTime = task?.dateTime != null ? TimeOfDay.fromDateTime(task!.dateTime!) : null;

    final result = await showDialog<Task>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(task == null ? 'New Task' : 'Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Task Title'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 10),
                    Text(selectedDate == null ? 'Select Date' : '${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}'),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                        }
                      },
                      child: const Text('Pick Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 10),
                    Text(selectedTime == null ? 'Select Time' : selectedTime?.format(context) ?? ""),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.fromDateTime(DateTime.now()),
                        );
                        if (time != null) {
                          setState(() => selectedTime = time);
                        }
                      },
                      child: const Text('Pick Time'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final desc = descController.text.trim();
                if (title.isEmpty) return;

                DateTime? finalDateTime;
                if (selectedDate != null && selectedTime != null) {
                  finalDateTime = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );
                }

                final newTask = Task(
                  title: title,
                  description: desc,
                  dateTime: finalDateTime,
                );

                Navigator.pop(context, newTask);
              },
              child: Text(task == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        if (task == null) {
          _tasks.add(result); // Add new task
        } else {
          _tasks[index!] = result; // Update existing
        }
      });
    }
  }

  void _deleteTask(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _tasks.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  DateTime parseCustomDate(String dateStr) {
    final parts = dateStr.split(' ');
    if (parts.length != 3) throw FormatException('Invalid date format');

    final day = int.parse(parts[0]);
    final month = _monthNameToNumber(parts[1]);
    final year = int.parse(parts[2]);

    return DateTime(year, month, day);
  }

  int _monthNameToNumber(String name) {
    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };

    return months[name]!;
  }

  @override
  Widget build(BuildContext context) {
    final groupedTasks = groupTasksByDate(_tasks);
    final sortedKeys = groupedTasks.keys.toList()
      ..sort((a, b) {
        if (a == 'Overdue') return -1;
        if (b == 'Overdue') return 1;
        if (a == 'Today') return -1;
        if (b == 'Today') return 1;
        if (a == 'Tomorrow') return -1;
        if (b == 'Tomorrow') return 1;
        if (a == 'Unscheduled') return 1;
        if (b == 'Unscheduled') return -1;

        // Else, try to parse as date and compare
        try {
          final aDate = parseCustomDate(a);
          final bDate = parseCustomDate(b);
          return aDate.compareTo(bDate);
        } catch (_) {
          return 0;
        }
      });
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addOrEditTask(),
            tooltip: 'Add Task',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditTask(), // opens add task dialog
        tooltip: 'Add Task',
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
      body: groupedTasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade100,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Icon(
                        Icons.inbox_rounded,
                        size: 60,
                        color: Colors.deepPurple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'No tasks yet!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tap the + button to create your first task.',
                    style: TextStyle(fontSize: 16, color: Colors.black45),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView(
              children: sortedKeys.map((sectionTitle) {
                final tasksInSection = groupedTasks[sectionTitle]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        sectionTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    ...tasksInSection.map((task) {
                      final index = _tasks.indexOf(task);
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(task.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.description),
                              if (task.dateTime != null)
                                Text(
                                  'At ${TimeOfDay.fromDateTime(task.dateTime!).format(context)}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _addOrEditTask(task: task, index: index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTask(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/Consts/Constants.dart';
import 'package:task_manager/Pages/HomePage/Controller/HomeController.dart';
import 'package:task_manager/Pages/HomePage/Model/TaskModel.dart';

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

class HomePage extends GetWidget<HomeController> {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => showLogoutDialog(),
            tooltip: 'Logout',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditTask(), // opens add task dialog
        tooltip: 'Add Task',
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection(Constants.userID).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [CircularProgressIndicator(), Text("Please wait...")],
              ),
            );
          } else {
            if (!snapshot.hasData) {
              return Center(
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
              );
            } else {
              List<Task> taskList = [];
              for (var index = 0; index < snapshot.data!.size; index++) {
                var doc = snapshot.data!.docs[index];
                taskList.add(Task(
                    title: doc.data().containsKey("title") ? doc["title"] : "",
                    description: doc.data().containsKey("description") ? doc["description"] : "",
                    dateTime: doc.data().containsKey("dateTime") ? DateTime.parse(doc["dateTime"]) : null,
                    docId: doc.id ?? ""));
              }

              final groupedTasks = groupTasksByDate(taskList);
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
                    final aDate = controller.parseCustomDate(a);
                    final bDate = controller.parseCustomDate(b);
                    return aDate.compareTo(bDate);
                  } catch (_) {
                    return 0;
                  }
                });
              return groupedTasks.isEmpty
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
                              final index = taskList.indexOf(task);
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
                                        onPressed: () => _deleteTask(taskList[index]),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                    );
            }
          }
        },
      ),
    );
  }

  _deleteTask(Task task) {
    Get.defaultDialog(
      title: 'Delete Task',
      content: const Text('Are you sure you want to delete this task?'),
      actions: [
        TextButton(onPressed: () => Get.back(closeOverlays: true), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            controller.deleteTask(task);
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }

  Future<void> _addOrEditTask({Task? task, int? index}) async {
    controller.titleController.text = task?.title ?? '';
    controller.descController.text = task?.description ?? '';

    controller.selectedDate.value = task?.dateTime;
    controller.selectedTime.value = task?.dateTime != null ? TimeOfDay.fromDateTime(task!.dateTime!) : null;
    controller.clearErrors();
    Get.defaultDialog(
      barrierDismissible: false,
      title: task == null ? 'New Task' : 'Edit Task',
      content: Obx(() => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: controller.titleController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      labelText: "Enter Task Title",
                      error: controller.titleHasError.value
                          ? Text(
                              controller.titleError.value,
                              style: TextStyle(color: Colors.red),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: controller.descController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      labelText: "Enter Task Description",
                      error: controller.descHasError.value
                          ? Text(
                              controller.descError.value,
                              style: TextStyle(color: Colors.red),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: Get.context!,
                        initialDate: controller.selectedDate.value ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2200),
                      );
                      if (date != null) {
                        controller.selectedDate.value = date;
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: controller.dateHasError.value ? Colors.red : Colors.grey.shade800),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 10),
                          Text(controller.selectedDate.value == null
                              ? 'Select Date'
                              : '${controller.selectedDate.value?.day}/${controller.selectedDate.value?.month}/${controller.selectedDate.value?.year}'),
                        ],
                      ),
                    ),
                  ),
                  controller.dateHasError.value
                      ? Padding(
                          padding: const EdgeInsets.only(left: 10.0, top: 5),
                          child: Text(controller.dateError.value, style: TextStyle(color: Colors.red)),
                        )
                      : SizedBox(),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: Get.context!,
                        initialTime: controller.selectedTime.value ?? TimeOfDay.fromDateTime(DateTime.now()),
                      );
                      if (time != null) {
                        controller.selectedTime.value = time;
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: controller.timeHasError.value ? Colors.red : Colors.grey.shade800),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time),
                          const SizedBox(width: 10),
                          Text(controller.selectedTime.value == null
                              ? 'Select Time'
                              : controller.selectedTime.value?.format(Get.context!) ?? ""),
                        ],
                      ),
                    ),
                  ),
                  controller.timeHasError.value
                      ? Padding(
                          padding: const EdgeInsets.only(left: 10.0, top: 5),
                          child: Text(controller.timeError.value, style: TextStyle(color: Colors.red)),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          )),
      actions: [
        TextButton(
          onPressed: () => Get.back(closeOverlays: true),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            controller.addOrUpdateTask(task);
          },
          child: Text(task == null ? 'Save' : 'Update'),
        ),
      ],
    );
  }

  showLogoutDialog() {
    Get.defaultDialog(barrierDismissible: false, title: "Logout?", content: Text("Do you want to logout?"), actions: [
      TextButton(
          onPressed: () {
            Get.back(closeOverlays: true);
          },
          child: Text("Cancel")),
      ElevatedButton(
          onPressed: () {
            controller.logout();
          },
          child: Text("Logout"))
    ]);
  }
}

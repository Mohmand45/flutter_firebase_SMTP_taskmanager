import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_management/core/data/models/task_model.dart';

class TaskService {
  static final CollectionReference _tasksCollection =
  FirebaseFirestore.instance.collection('tasks');

  static Future<void> createTask(Task task) async {
    await _tasksCollection.doc(task.id).set(task.toMap());
  }

  static Future<void> updateTask(Task task) async {
    await _tasksCollection.doc(task.id).update(task.toMap());
  }

  static Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  static Stream<List<Task>> streamTasks() {
    return _tasksCollection.snapshots().map(
          (snapshot) {
        return snapshot.docs
            .map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
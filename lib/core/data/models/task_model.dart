class Task {
  String id; // Add id property
  String title;
  String description;
  bool isDone;
  bool isApproved;
  String status; // Add status property

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.isDone = false,
    this.isApproved = false,
    required this.status,
  });

factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
    };
  }
}
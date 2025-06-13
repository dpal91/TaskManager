class Task {
  String title;
  String description;
  DateTime? dateTime;
  String? docId;

  Task({
    required this.title,
    required this.description,
    this.dateTime,
    this.docId,
  });

  Map<String, dynamic> toMap() {
    return dateTime == null
        ? {"title": title, "description": description}
        : {"title": title, "description": description, "dateTime": dateTime.toString()};
  }
}

class AcademicAnnouncement {
  const AcademicAnnouncement({required this.id, required this.title, required this.body, required this.category, required this.publishedAt});

  final String id;
  final String title;
  final String body;
  final String category;
  final String publishedAt;

  factory AcademicAnnouncement.fromJson(Map<String, dynamic> json) => AcademicAnnouncement(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Untitled announcement',
        body: json['body']?.toString() ?? '',
        category: json['category']?.toString() ?? 'GENERAL',
        publishedAt: json['publishedAt']?.toString() ?? '',
      );
}

class TimetableEntry {
  const TimetableEntry({required this.id, required this.dayOfWeek, required this.startTime, required this.endTime, required this.subject, required this.teacherName, required this.room, this.sectionName});

  final String id;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String subject;
  final String teacherName;
  final String room;
  final String? sectionName;

  factory TimetableEntry.fromJson(Map<String, dynamic> json) => TimetableEntry(
        id: json['id']?.toString() ?? '',
        dayOfWeek: (json['dayOfWeek'] as num?)?.toInt() ?? 1,
        startTime: json['startTime']?.toString() ?? '--:--',
        endTime: json['endTime']?.toString() ?? '--:--',
        subject: json['subject']?.toString() ?? 'Untitled class',
        teacherName: json['teacherName']?.toString() ?? '',
        room: json['room']?.toString() ?? '',
        sectionName: json['sectionName']?.toString(),
      );
}

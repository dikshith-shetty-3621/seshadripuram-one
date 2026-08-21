import 'package:dio/dio.dart';

import '../domain/academic_models.dart';

class AcademicRepository {
  AcademicRepository(this._dio);

  final Dio _dio;

  Future<List<AcademicAnnouncement>> getAnnouncements() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/academic/announcements');
    final items = response.data?['announcements'] as List<dynamic>? ?? const [];
    return items.whereType<Map<String, dynamic>>().map(AcademicAnnouncement.fromJson).toList();
  }

  Future<List<TimetableEntry>> getTimetable() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/academic/timetable');
    final items = response.data?['timetable'] as List<dynamic>? ?? const [];
    return items.whereType<Map<String, dynamic>>().map(TimetableEntry.fromJson).toList();
  }
}

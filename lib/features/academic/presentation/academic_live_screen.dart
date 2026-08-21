import 'package:flutter/material.dart';

import '../../../core/widgets/dashboard_components.dart';
import 'live_academic_sections.dart';

class AcademicLiveScreen extends StatelessWidget {
  const AcademicLiveScreen({required this.showTimetable, super.key});

  final bool showTimetable;

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: showTimetable ? 'Class timetable' : 'Announcements',
      subtitle: 'Seshadripuram One • Live campus data',
      child: showTimetable ? const LiveTimetableSection() : const LiveAnnouncementsSection(),
    );
  }
}

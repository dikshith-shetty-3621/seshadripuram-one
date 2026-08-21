import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/dashboard_components.dart';
import 'academic_providers.dart';

class LiveAnnouncementsSection extends ConsumerWidget {
  const LiveAnnouncementsSection({this.limit, super.key});

  final int? limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcements = ref.watch(announcementsProvider);
    return announcements.when(
      loading: () => const DashboardSection(title: 'Announcements', child: Center(child: CircularProgressIndicator())),
      error: (error, _) => DashboardSection(title: 'Announcements', child: Text('Announcements are unavailable right now.', style: Theme.of(context).textTheme.bodyMedium)),
      data: (items) {
        final visible = limit == null ? items : items.take(limit!).toList();
        return DashboardSection(
          title: 'Announcements',
          child: visible.isEmpty
              ? const Text('No announcements yet.')
              : Column(children: [
                  for (var index = 0; index < visible.length; index++) ...[
                    AnnouncementTile(title: visible[index].title, date: '${visible[index].category} • ${_dateLabel(visible[index].publishedAt)}'),
                    if (index < visible.length - 1) const SizedBox(height: AppSpacing.sm),
                  ],
                ]),
        );
      },
    );
  }
}

class LiveTimetableSection extends ConsumerWidget {
  const LiveTimetableSection({this.limit, super.key});

  final int? limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timetable = ref.watch(timetableProvider);
    return timetable.when(
      loading: () => const DashboardSection(title: 'Today’s schedule', child: Center(child: CircularProgressIndicator())),
      error: (error, _) => DashboardSection(title: 'Today’s schedule', child: Text('The timetable is unavailable right now.', style: Theme.of(context).textTheme.bodyMedium)),
      data: (items) {
        final visible = limit == null ? items : items.take(limit!).toList();
        return DashboardSection(
          title: 'Today’s schedule',
          child: visible.isEmpty
              ? const Text('No classes have been scheduled.')
              : Column(children: [
                  for (var index = 0; index < visible.length; index++) ...[
                    ScheduleCard(time: visible[index].startTime, subject: visible[index].subject, meta: '${visible[index].room} • ${visible[index].teacherName}'),
                    if (index < visible.length - 1) const SizedBox(height: AppSpacing.sm),
                  ],
                ]),
        );
      },
    );
  }
}

String _dateLabel(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
}

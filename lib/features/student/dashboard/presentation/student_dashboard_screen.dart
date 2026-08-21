import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/dashboard_components.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Good morning, Student',
      subtitle: 'BCA • Semester 4 • Section A',
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none), tooltip: 'Notifications'),
        const CircleAvatar(backgroundColor: AppColors.gold500, child: Text('S', style: TextStyle(color: AppColors.navy950, fontWeight: FontWeight.w800))),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          const stats = Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              SizedBox(width: 180, child: StatCard(label: 'Attendance', value: '86%', icon: Icons.event_available, accent: AppColors.success)),
              SizedBox(width: 180, child: StatCard(label: 'Next deadline', value: '2 days', icon: Icons.schedule, accent: AppColors.warning)),
              SizedBox(width: 180, child: StatCard(label: 'Unread notices', value: '4', icon: Icons.notifications_active_outlined, accent: AppColors.gold500)),
            ],
          );
          const schedule = DashboardSection(
            title: 'Today’s schedule',
            child: Column(children: [
              ScheduleCard(time: '09:00', subject: 'Web Technology', meta: 'Room 204 • Dr. Rao'),
              SizedBox(height: AppSpacing.sm),
              ScheduleCard(time: '11:00', subject: 'Database Systems', meta: 'Lab 2 • Prof. Mehta'),
            ]),
          );
          const announcements = DashboardSection(
            title: 'Announcements',
            child: Column(children: [
              AnnouncementTile(title: 'Examination timetable published', date: 'Today • Academic Office'),
              SizedBox(height: AppSpacing.sm),
              AnnouncementTile(title: 'Workshop registration is open', date: 'Yesterday • Department of Computer Science'),
            ]),
          );

          final explore = Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
            OutlinedButton.icon(onPressed: () => context.push('/student/timetable'), icon: const Icon(Icons.calendar_month_outlined), label: const Text('Full timetable')),
            OutlinedButton.icon(onPressed: () => context.push('/student/attendance'), icon: const Icon(Icons.event_available), label: const Text('Attendance')),
            OutlinedButton.icon(onPressed: () => context.push('/student/marks'), icon: const Icon(Icons.auto_graph_outlined), label: const Text('Marks')),
            OutlinedButton.icon(onPressed: () => context.push('/student/assignments'), icon: const Icon(Icons.assignment_outlined), label: const Text('Assignments')),
            OutlinedButton.icon(onPressed: () => context.push('/student/announcements'), icon: const Icon(Icons.campaign_outlined), label: const Text('All notices')),
          ]);
          if (!wide) {
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              stats,
              const SizedBox(height: AppSpacing.xl),
              schedule,
              const SizedBox(height: AppSpacing.xl),
              announcements,
              const SizedBox(height: AppSpacing.xl),
              Text('Explore', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              explore,
            ]);
          }
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            stats,
            SizedBox(height: AppSpacing.xl),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: schedule),
              SizedBox(width: AppSpacing.lg),
              Expanded(child: announcements),
            ]),
            const SizedBox(height: AppSpacing.xl),
            Text('Explore', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            explore,
          ]);
        },
      ),
    );
  }
}

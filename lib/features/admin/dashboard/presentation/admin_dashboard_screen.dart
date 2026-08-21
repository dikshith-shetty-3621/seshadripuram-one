import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/dashboard_components.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Institution overview',
      subtitle: 'Seshadripuram College • Administration',
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none), tooltip: 'Notifications'),
        const CircleAvatar(backgroundColor: AppColors.gold500, child: Text('A', style: TextStyle(color: AppColors.navy950, fontWeight: FontWeight.w800))),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Card(
          color: AppColors.navy900,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(children: [
              const Icon(Icons.account_balance_outlined, color: AppColors.gold300, size: 34),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Always aiming high', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                const Text('Manage academic operations with confidence.', style: TextStyle(color: Colors.white70)),
              ])),
            ]),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
          SizedBox(width: 180, child: StatCard(label: 'Active students', value: '1,248', icon: Icons.school_outlined, accent: AppColors.navy800)),
          SizedBox(width: 180, child: StatCard(label: 'Faculty members', value: '86', icon: Icons.people_outline, accent: AppColors.gold500)),
          SizedBox(width: 180, child: StatCard(label: 'Pending imports', value: '2', icon: Icons.file_upload_outlined, accent: AppColors.warning)),
        ]),
        const SizedBox(height: AppSpacing.xl),
        Text('Administration tools', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
          OutlinedButton.icon(onPressed: () => context.push('/admin/imports'), icon: const Icon(Icons.file_upload_outlined), label: const Text('Import data')),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.account_tree_outlined), label: const Text('Academic structure')),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.fact_check_outlined), label: const Text('Review attendance')),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.history), label: const Text('Audit logs')),
        ]),
        const SizedBox(height: AppSpacing.xl),
        const DashboardSection(
          title: 'Recent activity',
          child: Column(children: [
            AnnouncementTile(title: 'Student data import requires review', date: 'Today • 42 rows need attention'),
            SizedBox(height: AppSpacing.sm),
            AnnouncementTile(title: 'Academic year 2026–27 structure prepared', date: 'Yesterday • Draft configuration'),
          ]),
        ),
      ]),
    );
  }
}

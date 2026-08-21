import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class DashboardShell extends StatelessWidget {
  const DashboardShell({
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions = const [],
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final content = SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? AppSpacing.xxl : AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DashboardHeader(title: title, subtitle: subtitle, actions: actions),
                    const SizedBox(height: AppSpacing.xl),
                    child,
                  ],
                ),
              ),
            );

            if (!wide) return content;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _NavigationRail(),
                Expanded(child: content),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: MediaQuery.sizeOf(context).width < 760
          ? const NavigationBar(
              selectedIndex: 0,
              destinations: [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: 'Schedule'),
                NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
              ],
            )
          : null,
    );
  }
}

class _NavigationRail extends StatelessWidget {
  const _NavigationRail();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      color: AppColors.navy900,
      child: const Column(
        children: [
          SizedBox(height: 28),
          _BrandMark(),
          SizedBox(height: 44),
          Icon(Icons.home, color: AppColors.gold300),
          SizedBox(height: 28),
          Icon(Icons.calendar_month_outlined, color: Colors.white70),
          SizedBox(height: 28),
          Icon(Icons.notifications_none, color: Colors.white70),
          Spacer(),
          Icon(Icons.settings_outlined, color: Colors.white70),
          SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.title, required this.subtitle, required this.actions});

  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _BrandMark(),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        ...actions,
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.navy900,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold500, width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0x33D7A928), blurRadius: 14)],
      ),
      alignment: Alignment.center,
      child: const Text('S', style: TextStyle(color: AppColors.gold300, fontSize: 24, fontWeight: FontWeight.w800)),
    );
  }
}

class DashboardSection extends StatelessWidget {
  const DashboardSection({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.2, color: AppColors.navy700, fontWeight: FontWeight.w800)),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({required this.label, required this.value, required this.icon, this.accent = AppColors.navy800, super.key});

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadii.sm)),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: Theme.of(context).textTheme.titleLarge), Text(label, style: Theme.of(context).textTheme.bodySmall)])),
          ],
        ),
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({required this.time, required this.subject, required this.meta, super.key});

  final String time;
  final String subject;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Text(time, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.gold500)),
            const SizedBox(width: AppSpacing.md),
            Container(width: 3, height: 44, color: AppColors.gold500),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(subject, style: Theme.of(context).textTheme.titleMedium), Text(meta, style: Theme.of(context).textTheme.bodyMedium)])),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class AnnouncementTile extends StatelessWidget {
  const AnnouncementTile({required this.title, required this.date, super.key});

  final String title;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
        leading: const CircleAvatar(backgroundColor: Color(0x1AD7A928), child: Icon(Icons.campaign_outlined, color: AppColors.gold500)),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(date),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.muted),
      ),
    );
  }
}

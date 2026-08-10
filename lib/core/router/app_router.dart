import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/user_role.dart';
import '../../features/auth/presentation/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/admin/dashboard/presentation/admin_dashboard_screen.dart';
import '../../features/student/dashboard/presentation/student_dashboard_screen.dart';
import '../../features/teacher/dashboard/presentation/teacher_dashboard_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthLoading = authState.isLoading;
      if (isAuthLoading) return null; // Can redirect to a splash screen here if needed

      final user = authState.value;
      final isLoggedIn = user != null;
      final isGoingToLogin = state.matchedLocation == '/login';

      // 1. Unauthenticated users must be sent to login
      if (!isLoggedIn) {
        return isGoingToLogin ? null : '/login';
      }

      // 2. Authenticated users shouldn't be on the login screen
      if (isGoingToLogin) {
        return switch (user.role) {
          UserRole.student => '/student/dashboard',
          UserRole.teacher => '/teacher/dashboard',
          UserRole.admin => '/admin/dashboard',
        };
      }

      // 3. Role-based Route Protection
      final isGoingToStudent = state.matchedLocation.startsWith('/student');
      final isGoingToTeacher = state.matchedLocation.startsWith('/teacher');
      final isGoingToAdmin = state.matchedLocation.startsWith('/admin');

      if (isGoingToStudent && user.role != UserRole.student) {
        return '/login';
      }
      if (isGoingToTeacher && user.role != UserRole.teacher) {
        return '/login';
      }
      if (isGoingToAdmin && user.role != UserRole.admin) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/student/dashboard',
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      GoRoute(
        path: '/teacher/dashboard',
        builder: (context, state) => const TeacherDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../data/academic_repository.dart';

final academicRepositoryProvider = Provider<AcademicRepository>((ref) => AcademicRepository(ref.watch(apiClientProvider)));

final announcementsProvider = FutureProvider.autoDispose((ref) => ref.watch(academicRepositoryProvider).getAnnouncements());

final timetableProvider = FutureProvider.autoDispose((ref) => ref.watch(academicRepositoryProvider).getTimetable());

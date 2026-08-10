import 'package:equatable/equatable.dart';
import 'user_role.dart';

class AppUser extends Equatable {
  final String id;
  final String name;
  final UserRole role;
  final String institutionId;

  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.institutionId,
  });

  @override
  List<Object?> get props => [id, name, role, institutionId];
}

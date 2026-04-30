enum UserRole { chapterLead, teamLead, member }

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String chapterId;
  final List<String> teamIds;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.chapterId,
    this.teamIds = const [],
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.member,
      ),
      chapterId: map['chapterId'] as String,
      teamIds: List<String>.from(map['teamIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'chapterId': chapterId,
      'teamIds': teamIds,
    };
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? chapterId,
    List<String>? teamIds,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      chapterId: chapterId ?? this.chapterId,
      teamIds: teamIds ?? this.teamIds,
    );
  }

  bool get isChapterLead => role == UserRole.chapterLead;
  bool get isTeamLead => role == UserRole.teamLead;
  bool get isMember => role == UserRole.member;
}

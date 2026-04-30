class Team {
  final String id;
  final String chapterId;
  final String name;
  final String? leadId;
  final List<String> memberIds;
  final DateTime createdAt;
  final bool isArchived;

  Team({
    required this.id,
    required this.chapterId,
    required this.name,
    this.leadId,
    this.memberIds = const [],
    required this.createdAt,
    this.isArchived = false,
  });

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'] as String,
      chapterId: map['chapterId'] as String,
      name: map['name'] as String,
      leadId: map['leadId'] as String?,
      memberIds: List<String>.from(map['memberIds'] ?? []),
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      isArchived: map['isArchived'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chapterId': chapterId,
      'name': name,
      'leadId': leadId,
      'memberIds': memberIds,
      'createdAt': createdAt,
      'isArchived': isArchived,
    };
  }

  Team copyWith({
    String? id,
    String? chapterId,
    String? name,
    String? leadId,
    List<String>? memberIds,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Team(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      name: name ?? this.name,
      leadId: leadId ?? this.leadId,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

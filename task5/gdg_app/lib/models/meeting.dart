class Meeting {
  final String id;
  final String teamId;
  final String topic;
  final DateTime scheduledAt;
  final String? location;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;

  Meeting({
    required this.id,
    required this.teamId,
    required this.topic,
    required this.scheduledAt,
    this.location,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });

  factory Meeting.fromMap(Map<String, dynamic> map) {
    return Meeting(
      id: map['id'] as String,
      teamId: map['teamId'] as String,
      topic: map['topic'] as String,
      scheduledAt: (map['scheduledAt'] as dynamic)?.toDate() ?? DateTime.now(),
      location: map['location'] as String?,
      notes: map['notes'] as String?,
      createdBy: map['createdBy'] as String,
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teamId': teamId,
      'topic': topic,
      'scheduledAt': scheduledAt,
      'location': location,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }

  Meeting copyWith({
    String? id,
    String? teamId,
    String? topic,
    DateTime? scheduledAt,
    String? location,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Meeting(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      topic: topic ?? this.topic,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isUpcoming => scheduledAt.isAfter(DateTime.now());
  bool get isPast => scheduledAt.isBefore(DateTime.now());
}

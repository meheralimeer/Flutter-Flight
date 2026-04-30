enum AttendanceStatus { present, absent, late, excused }

class Attendance {
  final String id;
  final String meetingId;
  final String memberId;
  final AttendanceStatus status;
  final String? markedBy;
  final DateTime markedAt;
  final DateTime? updatedAt;

  Attendance({
    required this.id,
    required this.meetingId,
    required this.memberId,
    required this.status,
    this.markedBy,
    required this.markedAt,
    this.updatedAt,
  });

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'] as String,
      meetingId: map['meetingId'] as String,
      memberId: map['memberId'] as String,
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AttendanceStatus.absent,
      ),
      markedBy: map['markedBy'] as String?,
      markedAt: (map['markedAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'meetingId': meetingId,
      'memberId': memberId,
      'status': status.name,
      'markedBy': markedBy,
      'markedAt': markedAt,
      'updatedAt': updatedAt,
    };
  }

  Attendance copyWith({
    String? id,
    String? meetingId,
    String? memberId,
    AttendanceStatus? status,
    String? markedBy,
    DateTime? markedAt,
    DateTime? updatedAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      memberId: memberId ?? this.memberId,
      status: status ?? this.status,
      markedBy: markedBy ?? this.markedBy,
      markedAt: markedAt ?? this.markedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String generateId(String meetingId, String memberId) {
    return '${meetingId}_$memberId';
  }
}

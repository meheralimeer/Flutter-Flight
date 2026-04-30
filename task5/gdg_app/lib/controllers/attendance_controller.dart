import 'package:get/get.dart';
import '../models/models.dart';
import '../services/services.dart';

class AttendanceController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  final RxList<Attendance> attendances = <Attendance>[].obs;
  final RxList<Attendance> memberAttendances = <Attendance>[].obs;
  final RxBool isLoading = false.obs;

  Stream<List<Attendance>>? _attendanceStream;

  void loadAttendance(String meetingId) {
    _attendanceStream = _firestoreService.getAttendanceStream(meetingId);
    _attendanceStream?.listen((attendanceList) {
      attendances.value = attendanceList;
    });
  }

  void loadMemberAttendance(String memberId) {
    _firestoreService.getMemberAttendanceStream(memberId).listen((
      attendanceList,
    ) {
      memberAttendances.value = attendanceList;
    });
  }

  Future<void> markAttendance({
    required String meetingId,
    required String memberId,
    required AttendanceStatus status,
    required String markedBy,
  }) async {
    isLoading.value = true;
    final id = Attendance.generateId(meetingId, memberId);
    final existing = await _firestoreService.getAttendance(meetingId, memberId);
    final now = DateTime.now();

    if (existing != null) {
      final updated = existing.copyWith(
        status: status,
        markedBy: markedBy,
        updatedAt: now,
      );
      await _firestoreService.updateAttendance(updated);
    } else {
      final attendance = Attendance(
        id: id,
        meetingId: meetingId,
        memberId: memberId,
        status: status,
        markedBy: markedBy,
        markedAt: now,
      );
      await _firestoreService.setAttendance(attendance);
    }
    isLoading.value = false;
  }

  Future<void> bulkMarkAttendance({
    required String meetingId,
    required List<String> memberIds,
    required AttendanceStatus status,
    required String markedBy,
  }) async {
    isLoading.value = true;
    for (final memberId in memberIds) {
      await markAttendance(
        meetingId: meetingId,
        memberId: memberId,
        status: status,
        markedBy: markedBy,
      );
    }
    isLoading.value = false;
  }

  Attendance? getAttendanceForMember(String meetingId, String memberId) {
    return attendances.firstWhereOrNull(
      (a) => a.meetingId == meetingId && a.memberId == memberId,
    );
  }

  Map<AttendanceStatus, int> getAttendanceStats(List<String> memberIds) {
    final stats = <AttendanceStatus, int>{};
    for (final status in AttendanceStatus.values) {
      stats[status] = memberAttendances.where((a) => a.status == status).length;
    }
    return stats;
  }

  double getAttendancePercentage(String memberId) {
    final total = memberAttendances.length;
    if (total == 0) return 0;
    final present = memberAttendances
        .where(
          (a) =>
              a.status == AttendanceStatus.present ||
              a.status == AttendanceStatus.late,
        )
        .length;
    return present / total * 100;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/controllers.dart';
import '../constants/app_constants.dart';
import '../models/models.dart';

class AttendanceScreen extends StatefulWidget {
  final Meeting meeting;

  const AttendanceScreen({super.key, required this.meeting});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final AttendanceController _attendanceController =
      Get.find<AttendanceController>();
  final TeamController _teamController = Get.find<TeamController>();

  @override
  void initState() {
    super.initState();
    _attendanceController.loadAttendance(widget.meeting.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.markAttendance),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildMeetingInfo(),
          Expanded(child: _buildMembersList()),
        ],
      ),
    );
  }

  Widget _buildMeetingInfo() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.meeting.topic,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.event,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat(
                    'MMM d, y - h:mm a',
                  ).format(widget.meeting.scheduledAt),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            if (widget.meeting.location != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.meeting.location!,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMembersList() {
    return Obx(() {
      final team = _teamController.teams.firstWhereOrNull(
        (t) => t.id == widget.meeting.teamId,
      );
      if (team == null || team.memberIds.isEmpty) {
        return const Center(
          child: Text(
            'No members in this team',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: team.memberIds.length,
        itemBuilder: (context, index) {
          final memberId = team.memberIds[index];
          final attendance = _attendanceController.getAttendanceForMember(
            widget.meeting.id,
            memberId,
          );
          return _buildMemberTile(memberId, attendance);
        },
      );
    });
  }

  Widget _buildMemberTile(String memberId, Attendance? attendance) {
    final status = attendance?.status;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(status),
          child: Icon(_getStatusIcon(status), color: Colors.white),
        ),
        title: Text('Member'),
        subtitle: Text(memberId),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: AttendanceStatus.values.map((s) {
            return Padding(
              padding: const EdgeInsets.only(left: 4),
              child: InkWell(
                onTap: () => _markAttendance(memberId, s),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: status == s ? _getStatusColor(s) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusLabel(s),
                    style: TextStyle(
                      fontSize: 10,
                      color: status == s ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getStatusColor(AttendanceStatus? status) {
    switch (status) {
      case AttendanceStatus.present:
        return AppColors.secondary;
      case AttendanceStatus.absent:
        return AppColors.error;
      case AttendanceStatus.late:
        return AppColors.warning;
      case AttendanceStatus.excused:
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(AttendanceStatus? status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.late:
        return Icons.access_time;
      case AttendanceStatus.excused:
        return Icons.verified;
      default:
        return Icons.person;
    }
  }

  String _getStatusLabel(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'P';
      case AttendanceStatus.absent:
        return 'A';
      case AttendanceStatus.late:
        return 'L';
      case AttendanceStatus.excused:
        return 'E';
    }
  }

  Future<void> _markAttendance(String memberId, AttendanceStatus status) async {
    await _attendanceController.markAttendance(
      meetingId: widget.meeting.id,
      memberId: memberId,
      status: status,
      markedBy: _authController.currentUser.value?.id ?? '',
    );
  }
}

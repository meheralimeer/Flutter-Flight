import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../controllers/controllers.dart';
import '../constants/app_constants.dart';
import '../models/models.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final AttendanceController _attendanceController =
      Get.find<AttendanceController>();

  @override
  void initState() {
    super.initState();
    final userId = _authController.currentUser.value?.id;
    if (userId != null) {
      _attendanceController.loadMemberAttendance(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authController.currentUser.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.history),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final attendances = _attendanceController.memberAttendances;
        final percentage = _attendanceController.getAttendancePercentage(
          user?.id ?? '',
        );
        final stats = _attendanceController.getAttendanceStats(
          user?.teamIds ?? [],
        );

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCard(percentage, stats),
            const SizedBox(height: 16),
            _buildHistoryList(attendances),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryCard(
    double percentage,
    Map<AttendanceStatus, int> stats,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircularPercentIndicator(
              radius: 80,
              lineWidth: 12,
              percent: percentage / 100,
              center: Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              progressColor: percentage >= 75
                  ? AppColors.secondary
                  : AppColors.warning,
              backgroundColor: Colors.grey[300]!,
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 24),
            const Text(
              'Attendance Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Present',
                  stats[AttendanceStatus.present] ?? 0,
                  AppColors.secondary,
                ),
                _buildStatItem(
                  'Absent',
                  stats[AttendanceStatus.absent] ?? 0,
                  AppColors.error,
                ),
                _buildStatItem(
                  'Late',
                  stats[AttendanceStatus.late] ?? 0,
                  AppColors.warning,
                ),
                _buildStatItem(
                  'Excused',
                  stats[AttendanceStatus.excused] ?? 0,
                  AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildHistoryList(List<Attendance> attendances) {
    if (attendances.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.history, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No attendance history yet',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Recent Attendance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: attendances.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final attendance = attendances[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(attendance.status),
                  child: Icon(
                    _getStatusIcon(attendance.status),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text('Meeting: ${attendance.meetingId}'),
                subtitle: Text(
                  DateFormat('MMM d, y - h:mm a').format(attendance.markedAt),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(attendance.status).withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AttendanceStatusLabels.getDisplayName(
                      attendance.status.name,
                    ),
                    style: TextStyle(
                      color: _getStatusColor(attendance.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return AppColors.secondary;
      case AttendanceStatus.absent:
        return AppColors.error;
      case AttendanceStatus.late:
        return AppColors.warning;
      case AttendanceStatus.excused:
        return AppColors.primary;
    }
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.late:
        return Icons.access_time;
      case AttendanceStatus.excused:
        return Icons.verified;
    }
  }
}

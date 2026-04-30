import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/controllers.dart';
import '../constants/app_constants.dart';
import '../models/models.dart';
import 'teams_screen.dart';
import 'meetings_screen.dart';
import 'attendance_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final TeamController _teamController = Get.put(TeamController());
  final MeetingController _meetingController = Get.put(MeetingController());
  final AttendanceController _attendanceController = Get.put(
    AttendanceController(),
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final user = _authController.currentUser.value;
    if (user != null) {
      _teamController.loadTeams(user.chapterId);
      _meetingController.loadUpcomingMeetings(user.teamIds);
      _attendanceController.loadMemberAttendance(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.dashboard),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authController.signOut();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: Obx(() {
        final user = _authController.currentUser.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildWelcomeCard(user),
              const SizedBox(height: 16),
              if (user.isChapterLead || user.isTeamLead) ...[
                _buildQuickActionsSection(user),
                const SizedBox(height: 16),
              ],
              _buildUpcomingMeetingsSection(),
              const SizedBox(height: 16),
              _buildTeamsSection(user),
              const SizedBox(height: 16),
              _buildAttendanceSummary(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildWelcomeCard(AppUser user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 30,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${user.name}!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        UserRoles.getDisplayName(user.role.name),
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(AppUser user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionButton(
                  icon: Icons.group_add,
                  label: 'Create Team',
                  onTap: user.isChapterLead
                      ? () => Get.to(() => const TeamsScreen())
                      : null,
                ),
                _buildQuickActionButton(
                  icon: Icons.event_available,
                  label: 'New Meeting',
                  onTap: (user.isChapterLead || user.isTeamLead)
                      ? () => Get.to(() => const MeetingsScreen())
                      : null,
                ),
                _buildQuickActionButton(
                  icon: Icons.how_to_reg,
                  label: 'Mark Attendance',
                  onTap: (user.isChapterLead || user.isTeamLead)
                      ? () => Get.to(() => const MeetingsScreen())
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: onTap != null
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: onTap != null ? AppColors.primary : Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: onTap != null ? AppColors.textPrimary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingMeetingsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Meetings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => Get.to(() => const MeetingsScreen()),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() {
              final meetings = _meetingController.upcomingMeetings;
              if (meetings.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No upcoming meetings',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: meetings.take(3).length,
                itemBuilder: (context, index) {
                  final meeting = meetings[index];
                  return ListTile(
                    leading: const Icon(Icons.event, color: AppColors.primary),
                    title: Text(meeting.topic),
                    subtitle: Text(
                      DateFormat(
                        'MMM d, y - h:mm a',
                      ).format(meeting.scheduledAt),
                    ),
                    trailing: meeting.location != null
                        ? const Icon(Icons.location_on, size: 16)
                        : null,
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamsSection(AppUser user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Teams',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => Get.to(() => const TeamsScreen()),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() {
              final teams = _teamController.teams;
              final userTeams = teams
                  .where(
                    (t) =>
                        user.teamIds.contains(t.id) ||
                        t.leadId == user.id ||
                        user.isChapterLead,
                  )
                  .toList();
              if (userTeams.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No teams yet',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userTeams.take(3).length,
                itemBuilder: (context, index) {
                  final team = userTeams[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.group,
                      color: AppColors.secondary,
                    ),
                    title: Text(team.name),
                    subtitle: Text('${team.memberIds.length} members'),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSummary() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attendance Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () =>
                      Get.to(() => const AttendanceHistoryScreen()),
                  child: const Text('View History'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() {
              final percentage = _attendanceController.getAttendancePercentage(
                _authController.currentUser.value?.id ?? '',
              );
              final stats = _attendanceController.getAttendanceStats(
                _authController.currentUser.value?.teamIds ?? [],
              );
              return Column(
                children: [
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[300],
                    color: percentage >= 75
                        ? AppColors.secondary
                        : AppColors.warning,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${percentage.toStringAsFixed(1)}% attendance rate',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatChip(
                        'Present',
                        stats[AttendanceStatus.present] ?? 0,
                        AppColors.secondary,
                      ),
                      _buildStatChip(
                        'Absent',
                        stats[AttendanceStatus.absent] ?? 0,
                        AppColors.error,
                      ),
                      _buildStatChip(
                        'Late',
                        stats[AttendanceStatus.late] ?? 0,
                        AppColors.warning,
                      ),
                      _buildStatChip(
                        'Excused',
                        stats[AttendanceStatus.excused] ?? 0,
                        AppColors.primary,
                      ),
                    ],
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

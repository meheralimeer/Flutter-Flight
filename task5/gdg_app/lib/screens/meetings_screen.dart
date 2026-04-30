import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/controllers.dart';
import '../constants/app_constants.dart';
import '../models/models.dart';
import 'attendance_screen.dart';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({super.key});

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthController _authController = Get.find<AuthController>();
  final MeetingController _meetingController = Get.find<MeetingController>();
  final TeamController _teamController = Get.find<TeamController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMeetings();
  }

  void _loadMeetings() {
    final user = _authController.currentUser.value;
    if (user != null) {
      for (final teamId in user.teamIds) {
        _meetingController.loadMeetings(teamId);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authController.currentUser.value;
    final canCreate = user?.isChapterLead == true || user?.isTeamLead == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.meetings),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton(
              onPressed: () => _showCreateMeetingDialog(context),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMeetingsList(upcoming: true),
          _buildMeetingsList(upcoming: false),
        ],
      ),
    );
  }

  Widget _buildMeetingsList({required bool upcoming}) {
    return Obx(() {
      final allMeetings = _meetingController.meetings;
      final user = _authController.currentUser.value;
      final userTeams = _teamController.teams
          .where(
            (t) =>
                user?.teamIds.contains(t.id) == true ||
                t.leadId == user?.id ||
                user?.isChapterLead == true,
          )
          .toList();

      final filtered = <Meeting>[];
      for (final team in userTeams) {
        final teamMeetings = allMeetings.where((m) => m.teamId == team.id);
        if (upcoming) {
          filtered.addAll(teamMeetings.where((m) => m.isUpcoming));
        } else {
          filtered.addAll(teamMeetings.where((m) => m.isPast));
        }
      }

      if (filtered.isEmpty) {
        return Center(
          child: Text(
            upcoming ? 'No upcoming meetings' : 'No past meetings',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final meeting = filtered[index];
          return _buildMeetingCard(meeting);
        },
      );
    });
  }

  Widget _buildMeetingCard(Meeting meeting) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: meeting.isUpcoming
              ? AppColors.primary
              : AppColors.textSecondary,
          child: const Icon(Icons.event, color: Colors.white),
        ),
        title: Text(
          meeting.topic,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(DateFormat('MMM d, y - h:mm a').format(meeting.scheduledAt)),
            if (meeting.location != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    meeting.location!,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'attendance',
              child: Text('Mark Attendance'),
            ),
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) {
            switch (value) {
              case 'attendance':
                Get.to(() => AttendanceScreen(meeting: meeting));
                break;
              case 'edit':
                _showEditMeetingDialog(context, meeting);
                break;
              case 'delete':
                _confirmDeleteMeeting(context, meeting);
                break;
            }
          },
        ),
      ),
    );
  }

  void _showCreateMeetingDialog(BuildContext context) {
    final topicController = TextEditingController();
    final locationController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
    String? selectedTeamId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(AppStrings.createMeeting),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => DropdownButtonFormField<String>(
                    initialValue: selectedTeamId,
                    decoration: const InputDecoration(
                      labelText: 'Team',
                      border: OutlineInputBorder(),
                    ),
                    items: _teamController.teams
                        .map(
                          (t) => DropdownMenuItem(
                            value: t.id,
                            child: Text(t.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTeamId = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: topicController,
                  decoration: const InputDecoration(
                    labelText: 'Topic',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(DateFormat('MMM d, y').format(selectedDate)),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = time;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(selectedTime.format(context)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (topicController.text.isNotEmpty && selectedTeamId != null) {
                  final scheduledAt = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                  await _meetingController.createMeeting(
                    teamId: selectedTeamId!,
                    topic: topicController.text,
                    scheduledAt: scheduledAt,
                    location: locationController.text.isEmpty
                        ? null
                        : locationController.text,
                    notes: notesController.text.isEmpty
                        ? null
                        : notesController.text,
                    createdBy: _authController.currentUser.value?.id ?? '',
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditMeetingDialog(BuildContext context, Meeting meeting) {
    final topicController = TextEditingController(text: meeting.topic);
    final locationController = TextEditingController(
      text: meeting.location ?? '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Meeting'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: topicController,
              decoration: const InputDecoration(
                labelText: 'Topic',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (topicController.text.isNotEmpty) {
                await _meetingController.updateMeeting(
                  meeting.copyWith(
                    topic: topicController.text,
                    location: locationController.text.isEmpty
                        ? null
                        : locationController.text,
                  ),
                );
                if (!context.mounted) return;
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteMeeting(BuildContext context, Meeting meeting) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meeting'),
        content: Text('Are you sure you want to delete "${meeting.topic}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _meetingController.deleteMeeting(meeting.id);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

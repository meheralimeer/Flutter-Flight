import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/controllers.dart';
import '../constants/app_constants.dart';
import '../models/models.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final TeamController _teamController = Get.find<TeamController>();

  @override
  Widget build(BuildContext context) {
    final user = _authController.currentUser.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.teams),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: user?.isChapterLead == true
          ? FloatingActionButton(
              onPressed: () => _showCreateTeamDialog(context),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            )
          : null,
      body: Obx(() {
        final teams = _teamController.teams;
        if (teams.isEmpty) {
          return const Center(
            child: Text(
              'No teams yet',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final team = teams[index];
            return _buildTeamCard(team, user);
          },
        );
      }),
    );
  }

  Widget _buildTeamCard(Team team, AppUser? user) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.secondary,
          child: Text(
            team.name.isNotEmpty ? team.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          team.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${team.memberIds.length} members'),
            if (team.leadId != null) const Text('Has team lead'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (user?.isChapterLead == true) ...[
              const PopupMenuItem(value: 'edit', child: Text('Edit Team')),
              const PopupMenuItem(value: 'delete', child: Text('Delete Team')),
            ],
            const PopupMenuItem(value: 'view', child: Text('View Members')),
          ],
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditTeamDialog(context, team);
                break;
              case 'delete':
                _confirmDeleteTeam(context, team);
                break;
              case 'view':
                _showMembersDialog(context, team);
                break;
            }
          },
        ),
      ),
    );
  }

  void _showCreateTeamDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.createTeam),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Team Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final user = _authController.currentUser.value;
                await _teamController.createTeam(
                  nameController.text,
                  user?.chapterId ?? 'default_chapter',
                  null,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditTeamDialog(BuildContext context, Team team) {
    final nameController = TextEditingController(text: team.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Team'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Team Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await _teamController.updateTeam(
                  team.copyWith(name: nameController.text),
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

  void _confirmDeleteTeam(BuildContext context, Team team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Team'),
        content: Text('Are you sure you want to delete "${team.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _teamController.deleteTeam(team.id);
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

  void _showMembersDialog(BuildContext context, Team team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${team.name} Members'),
        content: SizedBox(
          width: double.maxFinite,
          child: team.memberIds.isEmpty
              ? const Text('No members in this team')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: team.memberIds.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text('Member ${index + 1}'),
                      subtitle: Text(team.memberIds[index]),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

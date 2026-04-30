import 'package:get/get.dart';
import '../models/models.dart';
import '../services/services.dart';

class TeamController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  final RxList<Team> teams = <Team>[].obs;
  final Rx<Team?> selectedTeam = Rx<Team?>(null);
  final RxBool isLoading = false.obs;

  Stream<List<Team>>? _teamsStream;

  void loadTeams(String chapterId) {
    _teamsStream = _firestoreService.getTeamsStream(chapterId);
    _teamsStream?.listen((teamList) {
      teams.value = teamList;
    });
  }

  Future<void> createTeam(String name, String chapterId, String? leadId) async {
    isLoading.value = true;
    final team = Team(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chapterId: chapterId,
      name: name,
      leadId: leadId,
      createdAt: DateTime.now(),
    );
    await _firestoreService.createTeam(team);
    isLoading.value = false;
  }

  Future<void> updateTeam(Team team) async {
    isLoading.value = true;
    await _firestoreService.updateTeam(team);
    isLoading.value = false;
  }

  Future<void> deleteTeam(String teamId) async {
    isLoading.value = true;
    await _firestoreService.deleteTeam(teamId);
    isLoading.value = false;
  }

  Future<void> addMember(String teamId, String memberId) async {
    final team = await _firestoreService.getTeam(teamId);
    if (team != null) {
      final updatedMembers = [...team.memberIds, memberId];
      await _firestoreService.updateTeam(
        team.copyWith(memberIds: updatedMembers),
      );
    }
  }

  Future<void> removeMember(String teamId, String memberId) async {
    final team = await _firestoreService.getTeam(teamId);
    if (team != null) {
      final updatedMembers = team.memberIds
          .where((id) => id != memberId)
          .toList();
      await _firestoreService.updateTeam(
        team.copyWith(memberIds: updatedMembers),
      );
    }
  }

  Future<void> setTeamLead(String teamId, String? leadId) async {
    final team = await _firestoreService.getTeam(teamId);
    if (team != null) {
      await _firestoreService.updateTeam(team.copyWith(leadId: leadId));
    }
  }

  void selectTeam(Team team) {
    selectedTeam.value = team;
  }

  void clearSelection() {
    selectedTeam.value = null;
  }
}

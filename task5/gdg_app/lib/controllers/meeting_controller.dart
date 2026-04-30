import 'package:get/get.dart';
import '../models/models.dart';
import '../services/services.dart';

class MeetingController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  final RxList<Meeting> meetings = <Meeting>[].obs;
  final RxList<Meeting> upcomingMeetings = <Meeting>[].obs;
  final Rx<Meeting?> selectedMeeting = Rx<Meeting?>(null);
  final RxBool isLoading = false.obs;

  Stream<List<Meeting>>? _meetingsStream;

  void loadMeetings(String teamId) {
    _meetingsStream = _firestoreService.getMeetingsStream(teamId);
    _meetingsStream?.listen((meetingList) {
      meetings.value = meetingList;
    });
  }

  void loadUpcomingMeetings(List<String> teamIds) {
    _firestoreService.getUpcomingMeetingsStream(teamIds).listen((meetingList) {
      upcomingMeetings.value = meetingList;
    });
  }

  Future<void> createMeeting({
    required String teamId,
    required String topic,
    required DateTime scheduledAt,
    String? location,
    String? notes,
    required String createdBy,
  }) async {
    isLoading.value = true;
    final meeting = Meeting(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      teamId: teamId,
      topic: topic,
      scheduledAt: scheduledAt,
      location: location,
      notes: notes,
      createdBy: createdBy,
      createdAt: DateTime.now(),
    );
    await _firestoreService.createMeeting(meeting);
    isLoading.value = false;
  }

  Future<void> updateMeeting(Meeting meeting) async {
    isLoading.value = true;
    await _firestoreService.updateMeeting(meeting);
    isLoading.value = false;
  }

  Future<void> deleteMeeting(String meetingId) async {
    isLoading.value = true;
    await _firestoreService.deleteMeeting(meetingId);
    isLoading.value = false;
  }

  void selectMeeting(Meeting meeting) {
    selectedMeeting.value = meeting;
  }

  void clearSelection() {
    selectedMeeting.value = null;
  }

  List<Meeting> getTeamMeetings(String teamId) {
    return meetings.where((m) => m.teamId == teamId).toList();
  }

  List<Meeting> getUpcomingForTeam(String teamId) {
    return meetings.where((m) => m.teamId == teamId && m.isUpcoming).toList();
  }

  List<Meeting> getPastForTeam(String teamId) {
    return meetings.where((m) => m.teamId == teamId && m.isPast).toList();
  }
}

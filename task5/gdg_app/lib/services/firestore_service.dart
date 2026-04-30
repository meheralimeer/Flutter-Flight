import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/models.dart';

class FirestoreService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Standard withConverter setup for typed collections
  CollectionReference<AppUser> get _usersRef =>
      _firestore.collection('users').withConverter<AppUser>(
            fromFirestore: (snapshot, _) => AppUser.fromMap(snapshot.data()!),
            toFirestore: (user, _) => user.toMap(),
          );

  CollectionReference<Team> get _teamsRef =>
      _firestore.collection('teams').withConverter<Team>(
            fromFirestore: (snapshot, _) => Team.fromMap(snapshot.data()!),
            toFirestore: (team, _) => team.toMap(),
          );

  CollectionReference<Meeting> get _meetingsRef =>
      _firestore.collection('meetings').withConverter<Meeting>(
            fromFirestore: (snapshot, _) => Meeting.fromMap(snapshot.data()!),
            toFirestore: (meeting, _) => meeting.toMap(),
          );

  CollectionReference<Attendance> get _attendanceRef =>
      _firestore.collection('attendance').withConverter<Attendance>(
            fromFirestore: (snapshot, _) => Attendance.fromMap(snapshot.data()!),
            toFirestore: (attendance, _) => attendance.toMap(),
          );

  Future<AppUser?> getUser(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    return doc.data();
  }

  Stream<AppUser?> userStream(String userId) {
    return _usersRef.doc(userId).snapshots().map((doc) => doc.data());
  }

  Future<void> createUser(AppUser user) async {
    await _usersRef.doc(user.id).set(user);
  }

  Future<void> updateUser(AppUser user) async {
    await _usersRef.doc(user.id).set(user, SetOptions(merge: true));
  }

  Stream<List<Team>> getTeamsStream(String chapterId) {
    return _teamsRef
        .where('chapterId', isEqualTo: chapterId)
        .where('isArchived', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<Team?> getTeam(String teamId) async {
    final doc = await _teamsRef.doc(teamId).get();
    return doc.data();
  }

  Future<void> createTeam(Team team) async {
    await _teamsRef.doc(team.id).set(team);
  }

  Future<void> updateTeam(Team team) async {
    await _teamsRef.doc(team.id).set(team, SetOptions(merge: true));
  }

  Future<void> deleteTeam(String teamId) async {
    await _teamsRef.doc(teamId).update({'isArchived': true});
  }

  Stream<List<Meeting>> getMeetingsStream(String teamId) {
    return _meetingsRef
        .where('teamId', isEqualTo: teamId)
        .orderBy('scheduledAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<Meeting>> getUpcomingMeetingsStream(List<String> teamIds) {
    if (teamIds.isEmpty) {
      return Stream.value([]);
    }
    return _meetingsRef
        .where('teamId', whereIn: teamIds)
        .orderBy('scheduledAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .where((m) => m.isUpcoming)
            .toList());
  }

  Future<Meeting?> getMeeting(String meetingId) async {
    final doc = await _meetingsRef.doc(meetingId).get();
    return doc.data();
  }

  Future<void> createMeeting(Meeting meeting) async {
    await _meetingsRef.doc(meeting.id).set(meeting);
  }

  Future<void> updateMeeting(Meeting meeting) async {
    await _meetingsRef.doc(meeting.id).set(meeting, SetOptions(merge: true));
  }

  Future<void> deleteMeeting(String meetingId) async {
    await _meetingsRef.doc(meetingId).delete();
  }

  Stream<List<Attendance>> getAttendanceStream(String meetingId) {
    return _attendanceRef
        .where('meetingId', isEqualTo: meetingId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<Attendance?> getAttendance(String meetingId, String memberId) async {
    final id = Attendance.generateId(meetingId, memberId);
    final doc = await _attendanceRef.doc(id).get();
    return doc.data();
  }

  Future<void> setAttendance(Attendance attendance) async {
    await _attendanceRef.doc(attendance.id).set(attendance);
  }

  Future<void> updateAttendance(Attendance attendance) async {
    await _attendanceRef.doc(attendance.id).set(attendance, SetOptions(merge: true));
  }

  Stream<List<Attendance>> getMemberAttendanceStream(String memberId) {
    return _attendanceRef
        .where('memberId', isEqualTo: memberId)
        .orderBy('markedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}

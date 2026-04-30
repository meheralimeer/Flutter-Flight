import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4285F4);
  static const Color secondary = Color(0xFF34A853);
  static const Color error = Color(0xFFEA4335);
  static const Color warning = Color(0xFFFBBC05);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF5F6368);
}

class AppStrings {
  static const String appName = 'GDG Team Manager';
  static const String login = 'Login';
  static const String signUp = 'Sign Up';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String name = 'Name';
  static const String dashboard = 'Dashboard';
  static const String teams = 'Teams';
  static const String meetings = 'Meetings';
  static const String attendance = 'Attendance';
  static const String history = 'History';
  static const String createTeam = 'Create Team';
  static const String createMeeting = 'Create Meeting';
  static const String markAttendance = 'Mark Attendance';
}

class UserRoles {
  static const String chapterLead = 'chapter_lead';
  static const String teamLead = 'team_lead';
  static const String member = 'member';

  static String getDisplayName(String role) {
    switch (role) {
      case chapterLead:
        return 'Chapter Lead';
      case teamLead:
        return 'Team Lead';
      case member:
        return 'Member';
      default:
        return 'Member';
    }
  }
}

class AttendanceStatusLabels {
  static const String present = 'Present';
  static const String absent = 'Absent';
  static const String late = 'Late';
  static const String excused = 'Excused';

  static String getDisplayName(String status) {
    switch (status) {
      case 'present':
        return present;
      case 'absent':
        return absent;
      case 'late':
        return late;
      case 'excused':
        return excused;
      default:
        return absent;
    }
  }
}

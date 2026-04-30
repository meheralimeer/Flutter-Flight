import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/app_user.dart';
import '../services/services.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  final Rx<AppUser?> currentUser = Rx<AppUser?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        await _loadUser(user.uid);
      } else {
        currentUser.value = null;
      }
    });
  }

  Future<void> _loadUser(String userId) async {
    final user = await _firestoreService.getUser(userId);
    if (user != null) {
      currentUser.value = user;
    } else {
      currentUser.value = AppUser(
        id: userId,
        name: 'Test User',
        email: 'test@example.com',
        role: UserRole.chapterLead,
        chapterId: 'default_chapter',
        teamIds: [],
      );
    }
  }

  Future<bool> signIn(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        await _loadUser(user.uid);
        return true;
      }
      errorMessage.value = 'User not found';
      return false;
    } on FirebaseAuthException catch (e) {
      errorMessage.value = e.message ?? 'Sign in failed';
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signUp(
    String name,
    String email,
    String password,
    UserRole role,
  ) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await _authService.signUp(email, password);
      if (user != null) {
        final appUser = AppUser(
          id: user.uid,
          name: name,
          email: email,
          role: role,
          chapterId: 'default_chapter',
          teamIds: [],
        );
        await _firestoreService.createUser(appUser);
        currentUser.value = appUser;
        return true;
      }
      errorMessage.value = 'Sign up failed';
      return false;
    } on FirebaseAuthException catch (e) {
      errorMessage.value = e.message ?? 'Sign up failed';
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    currentUser.value = null;
  }

  bool get isLoggedIn => currentUser.value != null;
  bool get isChapterLead => currentUser.value?.isChapterLead ?? false;
  bool get isTeamLead => currentUser.value?.isTeamLead ?? false;
  bool get isMember => currentUser.value?.isMember ?? true;
}

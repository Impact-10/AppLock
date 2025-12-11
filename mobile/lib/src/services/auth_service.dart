class AuthService {
  bool isAdminLoggedIn = false;

  Future<bool> login(String username, String password) async {
    // stub; accept any non-empty for MVP
    if (username.isNotEmpty && password.isNotEmpty) {
      isAdminLoggedIn = true;
      return true;
    }
    return false;
  }
}

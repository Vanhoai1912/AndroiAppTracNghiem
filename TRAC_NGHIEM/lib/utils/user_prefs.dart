import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  /// Lưu thông tin người dùng
  static Future<void> saveUserData(String fullName, String email, String role, String createdAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullName', fullName);
    await prefs.setString('email', email);
    await prefs.setString('role', role);
    await prefs.setString('createdAt', createdAt);
  }

  /// Lấy tên đầy đủ
  static Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fullName');
  }

  /// Lấy email (username)
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  /// Lấy vai trò
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  /// Lấy ngày tạo
  static Future<String?> getCreatedAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('createdAt');
  }

  /// Xóa toàn bộ thông tin người dùng
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fullName');
    await prefs.remove('email');
    await prefs.remove('role');
    await prefs.remove('createdAt');
  }
}

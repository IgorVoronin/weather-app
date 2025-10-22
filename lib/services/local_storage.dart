import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorage {
  static const String _currentUserEmailKey = 'current_user_email';
  static const String _usersPrefix = 'user_';
  static const String _postsKey = 'posts';

  // Сохраняем данные пользователя по email
  Future<void> saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final email = userData['email'] as String;
    
    // Сохраняем данные пользователя
    await prefs.setString('$_usersPrefix$email', json.encode(userData));
    
    // Сохраняем email текущего пользователя
    await prefs.setString(_currentUserEmailKey, email);
  }

  // Загружаем данные текущего пользователя
  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentEmail = prefs.getString(_currentUserEmailKey);
    
    if (currentEmail != null) {
      final userData = prefs.getString('$_usersPrefix$currentEmail');
      if (userData != null) {
        return json.decode(userData);
      }
    }
    return null;
  }

  // Загружаем данные пользователя по email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('$_usersPrefix$email');
    if (userData != null) {
      return json.decode(userData);
    }
    return null;
  }

  Future<void> savePhoto(String photoPath) async {
    final prefs = await SharedPreferences.getInstance();
    final currentEmail = prefs.getString(_currentUserEmailKey);
    if (currentEmail != null) {
      await prefs.setString('${_usersPrefix}${currentEmail}_photo', photoPath);
    }
  }

  Future<String?> getPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final currentEmail = prefs.getString(_currentUserEmailKey);
    if (currentEmail != null) {
      return prefs.getString('${_usersPrefix}${currentEmail}_photo');
    }
    return null;
  }

  // При выходе только сбрасываем текущую сессию
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserEmailKey);
  }

  // Методы для работы с постами
  Future<void> savePosts(List<Map<String, dynamic>> posts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_postsKey, json.encode(posts));
  }

  Future<List<Map<String, dynamic>>> getPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final postsData = prefs.getString(_postsKey);
    if (postsData != null) {
      final List<dynamic> decoded = json.decode(postsData);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class AuthService extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;
  bool _isLoading = false;

  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _token = await _storage.read(key: 'auth_token');
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['auth_token'];
        await _storage.write(key: 'auth_token', value: _token);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String username, String email, String password, String rePassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          're_password': rePassword,
        }),
      );

      if (response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Register error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await http.post(
          Uri.parse(ApiConstants.logout),
          headers: {'Authorization': 'Token $_token'},
        );
      }
    } catch (e) {
      debugPrint('Logout error: $e');
    }

    _token = null;
    await _storage.delete(key: 'auth_token');
    notifyListeners();
  }

  Map<String, String> get authHeaders => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Token $_token',
      };
}

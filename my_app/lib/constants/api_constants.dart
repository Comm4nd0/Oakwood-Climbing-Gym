class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000';
  static const String apiUrl = '$baseUrl/api';
  static const String authUrl = '$baseUrl/auth';

  // API Endpoints
  static const String routes = '$apiUrl/routes/';
  static const String walls = '$apiUrl/walls/';
  static const String logs = '$apiUrl/logs/';
  static const String logStats = '$apiUrl/logs/stats/';
  static const String classes = '$apiUrl/classes/';
  static const String bookings = '$apiUrl/bookings/';
  static const String announcements = '$apiUrl/announcements/';
  static const String gymInfo = '$apiUrl/gym-info/';
  static const String profile = '$apiUrl/profile/me/';
  static const String memberships = '$apiUrl/memberships/';

  // Auth Endpoints
  static const String login = '$authUrl/token/login/';
  static const String logout = '$authUrl/token/logout/';
  static const String register = '$authUrl/users/';
  static const String userMe = '$authUrl/users/me/';
}

class ApiConstants {
  // Toggle between local dev and production server
  static const bool _useProduction = false;
  static const String _localUrl = 'http://127.0.0.1:8000';
  static const String _prodUrl = 'http://178.104.29.66:8001';
  static const String baseUrl = _useProduction ? _prodUrl : _localUrl;
  static const String apiUrl = '$baseUrl/api';
  static const String authUrl = '$baseUrl/auth';

  // Profile & Waivers
  static const String profile = '$apiUrl/profile/me/';
  static const String waivers = '$apiUrl/waivers/';
  static const String safetySignoffs = '$apiUrl/safety-signoffs/';

  // Memberships
  static const String membershipPlans = '$apiUrl/membership-plans/';
  static const String memberships = '$apiUrl/memberships/';
  static const String punchCards = '$apiUrl/punch-cards/';

  // Check-in & Capacity
  static const String checkins = '$apiUrl/checkins/';
  static const String capacity = '$apiUrl/checkins/capacity/';

  // Walls & Routes
  static const String walls = '$apiUrl/walls/';
  static const String routes = '$apiUrl/routes/';
  static const String logs = '$apiUrl/logs/';
  static const String logStats = '$apiUrl/logs/stats/';

  // Classes & Bookings
  static const String classes = '$apiUrl/classes/';
  static const String bookings = '$apiUrl/bookings/';
  static const String partyBookings = '$apiUrl/party-bookings/';

  // Staff
  static const String staffShifts = '$apiUrl/staff/shifts/';
  static const String myShifts = '$apiUrl/staff/shifts/my_shifts/';
  static const String staffQualifications = '$apiUrl/staff/qualifications/';

  // Announcements & Events
  static const String announcements = '$apiUrl/announcements/';
  static const String events = '$apiUrl/events/';
  static const String gymInfo = '$apiUrl/gym-info/';

  // Support
  static const String supportTickets = '$apiUrl/support-tickets/';

  // Auth Endpoints
  static const String login = '$authUrl/token/login/';
  static const String logout = '$authUrl/token/logout/';
  static const String register = '$authUrl/users/';
  static const String userMe = '$authUrl/users/me/';
}

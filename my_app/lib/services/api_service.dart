import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/climbing_route.dart';
import '../models/wall_section.dart';
import '../models/gym_class.dart';
import '../models/announcement.dart';
import '../models/route_log.dart';
import '../models/booking.dart';
import '../models/staff_shift.dart';
import '../models/capacity.dart';
import '../models/check_in.dart';

class ApiService {
  final String? Function() _getToken;

  ApiService(this._getToken);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_getToken() != null) 'Authorization': 'Token ${_getToken()}',
      };

  List<T> _parseResults<T>(String body, T Function(Map<String, dynamic>) fromJson) {
    final data = jsonDecode(body);
    final results = data['results'] as List? ?? data as List;
    return results.map((item) => fromJson(item as Map<String, dynamic>)).toList();
  }

  // ============ Profile ============

  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(Uri.parse(ApiConstants.profile), headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load profile');
  }

  // ============ Capacity (public) ============

  Future<Capacity> getCapacity() async {
    final response = await http.get(Uri.parse(ApiConstants.capacity), headers: _headers);
    if (response.statusCode == 200) {
      return Capacity.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load capacity');
  }

  // ============ Check-in (staff) ============

  Future<List<CheckInRecord>> getActiveCheckIns() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.checkins}?active=true'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return _parseResults(response.body, CheckInRecord.fromJson);
    }
    throw Exception('Failed to load check-ins');
  }

  Future<CheckInRecord> checkInMember({
    int? memberId,
    String? visitorName,
    required String entryType,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.checkins),
      headers: _headers,
      body: jsonEncode({
        if (memberId != null) 'member': memberId,
        if (visitorName != null) 'visitor_name': visitorName,
        'entry_type': entryType,
      }),
    );
    if (response.statusCode == 201) {
      return CheckInRecord.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to check in');
  }

  Future<CheckInRecord> checkOut(int checkInId) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.checkins}$checkInId/checkout/'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return CheckInRecord.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to check out');
  }

  // ============ Routes ============

  Future<List<ClimbingRoute>> getRoutes({int? wallSection}) async {
    String url = ApiConstants.routes;
    if (wallSection != null) url += '?wall_section=$wallSection';
    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      return _parseResults(response.body, ClimbingRoute.fromJson);
    }
    throw Exception('Failed to load routes');
  }

  Future<List<WallSection>> getWalls() async {
    final response = await http.get(Uri.parse(ApiConstants.walls), headers: _headers);
    if (response.statusCode == 200) {
      return _parseResults(response.body, WallSection.fromJson);
    }
    throw Exception('Failed to load wall sections');
  }

  // ============ Classes ============

  Future<List<GymClass>> getClasses({String? type, String? ageGroup}) async {
    String url = ApiConstants.classes;
    final params = <String>[];
    if (type != null) params.add('type=$type');
    if (ageGroup != null) params.add('age_group=$ageGroup');
    if (params.isNotEmpty) url += '?${params.join('&')}';
    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      return _parseResults(response.body, GymClass.fromJson);
    }
    throw Exception('Failed to load classes');
  }

  // ============ Announcements ============

  Future<List<Announcement>> getAnnouncements() async {
    final response = await http.get(Uri.parse(ApiConstants.announcements), headers: _headers);
    if (response.statusCode == 200) {
      return _parseResults(response.body, Announcement.fromJson);
    }
    throw Exception('Failed to load announcements');
  }

  // ============ Route Logs ============

  Future<List<RouteLog>> getRouteLogs() async {
    final response = await http.get(Uri.parse(ApiConstants.logs), headers: _headers);
    if (response.statusCode == 200) {
      return _parseResults(response.body, RouteLog.fromJson);
    }
    throw Exception('Failed to load route logs');
  }

  Future<RouteLog> createRouteLog({
    required int routeId,
    required String attemptType,
    int? rating,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.logs),
      headers: _headers,
      body: jsonEncode({
        'route': routeId,
        'attempt_type': attemptType,
        if (rating != null) 'rating': rating,
        if (notes != null) 'notes': notes,
      }),
    );
    if (response.statusCode == 201) {
      return RouteLog.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create route log');
  }

  Future<RouteStats> getRouteStats() async {
    final response = await http.get(Uri.parse(ApiConstants.logStats), headers: _headers);
    if (response.statusCode == 200) {
      return RouteStats.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load stats');
  }

  // ============ Bookings ============

  Future<List<Booking>> getBookings() async {
    final response = await http.get(Uri.parse(ApiConstants.bookings), headers: _headers);
    if (response.statusCode == 200) {
      return _parseResults(response.body, Booking.fromJson);
    }
    throw Exception('Failed to load bookings');
  }

  Future<Booking> createBooking({
    required int classScheduleId,
    required String date,
    int participants = 1,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.bookings),
      headers: _headers,
      body: jsonEncode({
        'class_schedule': classScheduleId,
        'date': date,
        'participants': participants,
        if (notes != null) 'notes': notes,
      }),
    );
    if (response.statusCode == 201) {
      return Booking.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create booking');
  }

  Future<Booking> cancelBooking(int bookingId) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.bookings}$bookingId/cancel/'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return Booking.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to cancel booking');
  }

  // ============ Staff Shifts ============

  Future<List<StaffShift>> getMyShifts() async {
    final response = await http.get(Uri.parse(ApiConstants.myShifts), headers: _headers);
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((s) => StaffShift.fromJson(s))
          .toList();
    }
    throw Exception('Failed to load shifts');
  }

  Future<List<StaffShift>> getShifts({String? date}) async {
    String url = ApiConstants.staffShifts;
    if (date != null) url += '?date=$date';
    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      return _parseResults(response.body, StaffShift.fromJson);
    }
    throw Exception('Failed to load shifts');
  }

  // ============ Gym Info ============

  Future<Map<String, dynamic>> getGymInfo() async {
    final response = await http.get(Uri.parse(ApiConstants.gymInfo), headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List? ?? [data];
      if (results.isNotEmpty) return results.first;
    }
    throw Exception('Failed to load gym info');
  }

  // ============ Memberships ============

  Future<List<Map<String, dynamic>>> getMemberships() async {
    final response = await http.get(Uri.parse(ApiConstants.memberships), headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List? ?? data as List;
      return results.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to load memberships');
  }

  Future<Map<String, dynamic>> freezeMembership(int id, String frozenUntil) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.memberships}$id/freeze/'),
      headers: _headers,
      body: jsonEncode({'frozen_until': frozenUntil}),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to freeze membership');
  }

  Future<Map<String, dynamic>> requestCancellation(int id) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.memberships}$id/request_cancellation/'),
      headers: _headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to request cancellation');
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/climbing_route.dart';
import '../models/wall_section.dart';
import '../models/gym_class.dart';
import '../models/announcement.dart';
import '../models/route_log.dart';
import '../models/booking.dart';

class ApiService {
  final String? Function() _getToken;

  ApiService(this._getToken);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_getToken() != null) 'Authorization': 'Token ${_getToken()}',
      };

  // Routes
  Future<List<ClimbingRoute>> getRoutes({int? wallSection}) async {
    String url = ApiConstants.routes;
    if (wallSection != null) {
      url += '?wall_section=$wallSection';
    }
    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List? ?? data as List;
      return results.map((r) => ClimbingRoute.fromJson(r)).toList();
    }
    throw Exception('Failed to load routes');
  }

  // Wall Sections
  Future<List<WallSection>> getWalls() async {
    final response = await http.get(
      Uri.parse(ApiConstants.walls),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List? ?? data as List;
      return results.map((w) => WallSection.fromJson(w)).toList();
    }
    throw Exception('Failed to load wall sections');
  }

  // Classes
  Future<List<GymClass>> getClasses() async {
    final response = await http.get(
      Uri.parse(ApiConstants.classes),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List? ?? data as List;
      return results.map((c) => GymClass.fromJson(c)).toList();
    }
    throw Exception('Failed to load classes');
  }

  // Announcements
  Future<List<Announcement>> getAnnouncements() async {
    final response = await http.get(
      Uri.parse(ApiConstants.announcements),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List? ?? data as List;
      return results.map((a) => Announcement.fromJson(a)).toList();
    }
    throw Exception('Failed to load announcements');
  }

  // Route Logs
  Future<List<RouteLog>> getRouteLogs() async {
    final response = await http.get(
      Uri.parse(ApiConstants.logs),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List? ?? data as List;
      return results.map((l) => RouteLog.fromJson(l)).toList();
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
    final response = await http.get(
      Uri.parse(ApiConstants.logStats),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return RouteStats.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load stats');
  }

  // Bookings
  Future<List<Booking>> getBookings() async {
    final response = await http.get(
      Uri.parse(ApiConstants.bookings),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List? ?? data as List;
      return results.map((b) => Booking.fromJson(b)).toList();
    }
    throw Exception('Failed to load bookings');
  }

  Future<Booking> createBooking({
    required int classScheduleId,
    required String date,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.bookings),
      headers: _headers,
      body: jsonEncode({
        'class_schedule': classScheduleId,
        'date': date,
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

  // Gym Info
  Future<Map<String, dynamic>> getGymInfo() async {
    final response = await http.get(
      Uri.parse(ApiConstants.gymInfo),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List? ?? [data];
      if (results.isNotEmpty) {
        return results.first;
      }
    }
    throw Exception('Failed to load gym info');
  }
}

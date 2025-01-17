import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl =
      'http://192.168.1.107:8080/auth'; // Replace with your server IP

  // Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Parse the response body for a custom error message
        final errorResponse = jsonDecode(response.body);
        // Throw a plain string for incorrect username/password
        if (response.statusCode == 400 || response.statusCode == 401) {
          throw "username or password incorrect"; // Plain string
        } else {
          throw errorResponse['message'] ?? 'Failed to login'; // Plain string
        }
      }
    } catch (e) {
      // Handle network or JSON parsing errors
      throw "username or password incorrect"; // Plain string
    }
  }

  // Verify 2FA
  Future<Map<String, dynamic>> verify2FA(String username, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/verify-2fa'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Parse the response body for a custom error message
        final errorResponse = jsonDecode(response.body);
        // Throw a plain string for incorrect 2FA code
        if (response.statusCode == 400 || response.statusCode == 401) {
          throw "code incorrect"; // Plain string
        } else {
          throw errorResponse['message'] ??
              'Failed to verify 2FA'; // Plain string
        }
      }
    } catch (e) {
      // Handle network or JSON parsing errors
      throw "code incorrect"; // Plain string
    }
  }

  // Signup
  Future<String> signup(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Parse the response body for a custom error message
        final errorResponse = jsonDecode(response.body);
        throw errorResponse['message'] ?? 'Failed to signup'; // Plain string
      }
    } catch (e) {
      throw 'Network error: $e'; // Plain string
    }
  }
}

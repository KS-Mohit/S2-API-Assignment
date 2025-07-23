import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_exception.dart'; // Make sure this file exists in the same directory

class ApiService {
  // IMPORTANT: Replace with your actual backend URL
  static const String _baseUrl = 'http://localhost:8000'; 

  // --- POST Method ---
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network Error: Could not connect to the server.');
    }
  }

  // --- GET Method ---
  static Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    final url = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParams);
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network Error: Could not connect to the server.');
    }
  }

  // --- DELETE Method (FIXED) ---
  // The return type is changed to Future<Map<String, dynamic>> to return the response body.
  static Future<Map<String, dynamic>> delete(String endpoint, {Map<String, dynamic>? data}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: data != null ? json.encode(data) : null,
      );
      
      // This will now return the response body or throw an error.
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network Error: Could not connect to the server.');
    }
  }

  // --- Private method to handle all API responses ---
  static Map<String, dynamic> _handleResponse(http.Response response) {
    // Handle empty responses (like HTTP 204 No Content)
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'message': 'Success'}; // Return a default success message
      } else {
        throw ApiException(response.statusCode, 'Request failed with status code ${response.statusCode}');
      }
    }
    
    final responseBody = json.decode(utf8.decode(response.bodyBytes));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      throw ApiException.fromJson(response.statusCode, responseBody);
    }
  }
}

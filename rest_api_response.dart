import 'dart:convert';
import 'package:http/http.dart' as http;

class RestApiResponse {
  static const String baseUrl = 'https://api.example.com';
  String? _jwtToken; // Private variable to store the JWT token
  static RestApiResponse? _instance; // Singleton instance

  // Private constructor to enforce the singleton pattern
  RestApiResponse._();

  // Factory constructor to return the singleton instance
  factory RestApiResponse() {
    if (_instance == null) {
      _instance = RestApiResponse._();
    }
    return _instance!;
  }

  // Getter for the JWT token
  String? get jwtToken => _jwtToken;

  // Setter for the JWT token
  set jwtToken(String? token) {
    _jwtToken = token;
  }

  Future<dynamic> get<T>(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final response = await http.get(
        uri.replace(queryParameters: params),
        headers: _buildHeaders(),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (T == Map<String, dynamic> || T == dynamic) {
          return decodedResponse;
        } else if (T == List<dynamic>) {
          if (decodedResponse is List<dynamic>) {
            return decodedResponse;
          } else {
            throw Exception('Expected a List<dynamic> but received: $decodedResponse');
          }
        } else {
          throw Exception('Unsupported type: $T');
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
        throw Exception('Failed to make GET request');
      }
    } catch (e) {
      print('Error occurred while making GET request: $e');
      throw Exception('Failed to make GET request: $e');
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, dynamic data) async {
    return _sendRequest('POST', endpoint, data);
  }

  Future<Map<String, dynamic>> put(String endpoint, dynamic data) async {
    return _sendRequest('PUT', endpoint, data);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    return _sendRequest('DELETE', endpoint, null);
  }

  Future<Map<String, dynamic>> _sendRequest(String method, String endpoint, dynamic data) async {
    try {
      final response = await http.request(
        Uri.parse('$baseUrl/$endpoint'),
        method: method,
        body: json.encode(data),
        headers: _buildHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Request failed with status: ${response.statusCode}');
        throw Exception('Failed to make $method request');
      }
    } catch (e) {
      print('Error occurred while making $method request: $e');
      throw Exception('Failed to make $method request: $e');
    }
  }

  Map<String, String> _buildHeaders() {
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    if (_jwtToken != null) {
      headers['Authorization'] = 'Bearer $_jwtToken';
    }
    return headers;
  }
}

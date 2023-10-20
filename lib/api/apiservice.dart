import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl; // Your backend API base URL

  ApiService(this.baseUrl);

  Future<http.Response> signUp(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      body: data,
    );
    return response;
  }

  Future<http.Response> login(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: data,
    );
    return response;
  }

  Future<http.Response> getProfile(Map<String, dynamic> data) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profilepage'),
      
    );
    return response;
  }

  Future<http.Response> updateProfile(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/profilepage'),
      body: data,
    );
    return response;
  }
  Future<http.Response> getFriendsList(Map<String, dynamic> data) async {
    final response = await http.get(
      Uri.parse('$baseUrl/friendslist'),
      
    );
    return response;
  }

}
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
}
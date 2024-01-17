import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

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

  Future<http.Response> getProfile(String email, String username) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profilepage?email=$email&username=$username'),
      
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

  Future<http.Response> addPlan(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/plan'),
      body: data,
    );
    return response;
  }

   Future<http.Response> editPlan(Map<String, dynamic> data, String planid) async {
    final response = await http.put(
      Uri.parse('$baseUrl/plan/:planid'),
      body: data,
    );
    return response;
  }

  Future<http.Response> deletePlan(Map<String, dynamic> data) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/plan/:planid'),
     
    );
    return response;
  }

  Future<http.Response> viewPlans(String userId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/plans/$userId'), 
  );
  return response;
}



}
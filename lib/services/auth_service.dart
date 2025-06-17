import 'dart:convert';
import 'package:dahab_app/models/Property';
import 'package:dahab_app/models/chatMessage';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; 

class AuthService {
  final String baseUrl = 'https://ahmed-cmgfbvavf6c2c6dg.polandcentral-01.azurewebsites.net';

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/Account/Login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token']; 
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('userId', data['id']);

      print("Login Success: $token");
      return true;
    } else {
      print("Login Failed: ${response.statusCode} - ${response.body}");
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    required String phoneNumber,
  }) async {
    final url = Uri.parse('$baseUrl/api/Account/Regisiter');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'displayName': displayName,
        'phoneNumber': phoneNumber,
      }),
    );

    print('Register response: ${response.statusCode}');
    print('Register body: ${response.body}');

    return response.statusCode == 200;
  }

  Future<List<Property>> fetchProperties() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/api/Properties');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token', 
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((e) => Property.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load properties');
    }
  }

  
  Future<List<ChatMessage>> getChatHistory(String senderId, String receiverId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('$baseUrl/api/Chat/history/$senderId/$receiverId');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ChatMessage.fromJson(e, senderId)).toList();
    } else {
      throw Exception('404 Failed to load chat history');
    }
  }

  Future<bool> sendMessage(ChatMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('$baseUrl/api/Chat/send');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(message.toJson()),
    );

    return response.statusCode == 200;
  }

  Future<bool> purchaseInvestment(int propertyId, int numberOfShares) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final url = Uri.parse('$baseUrl/api/Investment/purchase');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'propertyId': propertyId,
      'numberOfShares': numberOfShares,
    }),
  );

  print('Purchase response: ${response.statusCode}');
  print('Response body: ${response.body}');

  return response.statusCode == 200;
}

  Future<List<Map<String, dynamic>>> getUserInvestments() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final url = Uri.parse('$baseUrl/api/Investment/user');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List<dynamic> investments = data['investments'];
    return investments.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load user investments');
  }
}

}



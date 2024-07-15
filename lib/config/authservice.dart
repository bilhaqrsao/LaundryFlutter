import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:new_laundry/config/app_endpoint.dart';

class AuthService {
  Future<String> loginUser(String username, String password) async {
    try {
      var url = Uri.parse(ApiEndPoint.baseUrl + ApiEndPoint.authEndPoint.login);
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        String token = jsonResponse['data']['access_token'];
        await GetStorage().write('token', token);

        // Simpan informasi pengguna
        var userData = jsonResponse['data']['user'];
        await GetStorage().write('userData', userData);

        return token;
      } else {
        var error = jsonDecode(response.body)['error'] ?? 'Failed to login';
        print('Gagal login: $error');
        throw Exception(error);
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to login');
    }
  }

  Future<void> logout() async {
    try {
      var url = Uri.parse(ApiEndPoint.baseUrl + ApiEndPoint.authEndPoint.logout);
      var token = await GetStorage().read('token');

      if (token == null) {
        throw Exception('No token found');
      }

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await GetStorage().remove('token');
        await GetStorage().remove('userData');
      } else if (response.statusCode == 401) {
        // Handle Unauthorized: Clear local token and user data, redirect to login
        await GetStorage().remove('token');
        await GetStorage().remove('userData');
        throw Exception('Unauthorized: Token expired or invalid');
      } else {
        print('Gagal logout: ${response.body}');
        throw Exception('Logout failed');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Logout failed');
    }
  }
}

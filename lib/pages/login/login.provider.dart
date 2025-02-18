import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider extends ChangeNotifier {
  bool _isRegistering = false;
  bool get isRegistering => _isRegistering;
  String? _token;
  String? get token => _token;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  void toggleAuthMode() {
    _isRegistering = !_isRegistering;
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> registerUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String email = emailController.text;
    final String password = passwordController.text;
    final String name = nameController.text;

    final user = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "nome": name,
      "email": email,
      "password": password,
    };

    await prefs.setString('user_$email', jsonEncode(user));
    toggleAuthMode();
  }

  Future<bool> loginUser(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String email = emailController.text;
    final String password = passwordController.text;

    final String? userData = prefs.getString('user_$email');

    if (userData != null) {
      final Map<String, dynamic> user = jsonDecode(userData);
      if (user['password'] == password) {
        final tokenData = {
          "id": user['id'],
          "email": user['email'],
          "nome": user['nome'],
          "password": user['password'], 
          "token": "fake_jwt_token_${user['id']}",
        };

        _token = jsonEncode(tokenData);
        _errorMessage = null;

        await prefs.setString('auth_token', jsonEncode(tokenData));
        notifyListeners();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Redirecionando...")),
        );

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/home');
        });

        return true;
      }
    }

    _errorMessage = "E-mail ou senha incorretos";
    notifyListeners();
    return false;
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String? id;
  String? nome;
  String? email;
  String? token;
  String? idReferencia;
  bool isLoggedIn = false; // 🔹 Indica se o usuário está logado

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString('auth_token');

    if (storedData != null) {
      final Map<String, dynamic> userData = jsonDecode(storedData);
      id = userData['id'];
      nome = userData['nome'];
      email = userData['email'];
      token = userData['token'];
      idReferencia = userData['id'];
      isLoggedIn = true; // 🔹 Mantém a sessão ativa

      notifyListeners();
    }
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', jsonEncode(userData));

    id = userData['id'];
    nome = userData['nome'];
    email = userData['email'];
    token = userData['token'];
    idReferencia = userData['id'];
    isLoggedIn = true; 

    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    id = null;
    nome = null;
    email = null;
    token = null;
    idReferencia = null;
    isLoggedIn = false;

    notifyListeners();
  }

  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }
}
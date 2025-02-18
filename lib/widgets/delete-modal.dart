import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste_uex_font/pages/user-provider.dart';

class DeleteAccountModal extends StatefulWidget {
  const DeleteAccountModal({super.key});

  @override
  _DeleteAccountModalState createState() => _DeleteAccountModalState();
}

class _DeleteAccountModalState extends State<DeleteAccountModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _confirmDeletion() async {
    final prefs = await SharedPreferences.getInstance();
    final String? authData = prefs.getString('auth_token');

    if (authData == null || authData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro: Nenhum usuário logado ou dados ausentes!")),
      );
      return;
    }

    final Map<String, dynamic> userData = jsonDecode(authData);
    debugPrint("🔍 Dados armazenados: $userData");

    if (userData['email'] == _emailController.text &&
        userData['password'] == _passwordController.text) {
      _showFinalConfirmation(userData);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("E-mail ou senha incorretos!")),
      );
    }
  }

  void _showFinalConfirmation(Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tem certeza?"),
        content: const Text("Todas as suas informações salvas serão excluídas permanentemente."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => _deleteAccount(userData),
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final String? cadastrosString = prefs.getString('cadastros');

    if (cadastrosString != null) {
      List<Map<String, dynamic>> cadastros = List<Map<String, dynamic>>.from(jsonDecode(cadastrosString));

      cadastros.removeWhere((cadastro) => cadastro['idReference'] == userData['id']);

      await prefs.setString('cadastros', jsonEncode(cadastros)); 
    }

    await prefs.remove('auth_token'); 
    await prefs.remove('user_${userData['email']}'); 

    Provider.of<UserProvider>(context, listen: false).logout();

    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Conta excluída com sucesso!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550), // 🔹 Define a largura máxima
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Excluir Conta",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildOutlinedTextField(
                      controller: _emailController,
                      label: "E-mail",
                      icon: Icons.email,
                      validatorMessage: "E-mail obrigatório",
                    ),
                    const SizedBox(height: 12),
                    _buildOutlinedTextField(
                      controller: _passwordController,
                      label: "Senha",
                      icon: Icons.lock,
                      validatorMessage: "Senha obrigatória",
                      obscureText: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar"),
                  ),
                  ElevatedButton(
                    onPressed: _confirmDeletion,
                    child: const Text("Confirmar"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String validatorMessage,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => value!.isEmpty ? validatorMessage : null,
      ),
    );
  }
}

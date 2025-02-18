import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teste_uex_font/pages/login/login.provider.dart';
import 'package:teste_uex_font/pages/user-provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<LoginProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Image.asset('assets/uex.png'),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        authProvider.isRegistering ? "Cadastro" : "Login",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (authProvider.errorMessage != null) ...[
                        Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 10),
                      ],

                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            if (authProvider.isRegistering) ...[
                              _buildOutlinedTextField(
                                controller: authProvider.nameController,
                                label: "Nome",
                                icon: Icons.person,
                                validatorMessage: "Nome obrigatório",
                              ),
                              const SizedBox(height: 12),
                            ],
                            _buildOutlinedTextField(
                              controller: authProvider.emailController,
                              label: "E-mail",
                              icon: Icons.email,
                              validatorMessage: "E-mail obrigatório",
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),
                            _buildOutlinedTextField(
                              controller: authProvider.passwordController,
                              label: "Senha",
                              icon: Icons.lock,
                              validatorMessage: "Senha obrigatória",
                              obscureText: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      _buildButton(
                        text:
                            authProvider.isRegistering ? "Cadastrar" : "Entrar",
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (authProvider.isRegistering) {
                              await authProvider.registerUser();
                            } else {
                              bool success = await authProvider.loginUser(
                                context,
                              );
                              if (success) {
                                await userProvider
                                    .loadUserData(); // 🔹 Atualiza idReferencia após login
                              }
                            }
                          }
                        },
                      ),

                      const SizedBox(height: 10),

                      TextButton(
                        onPressed: authProvider.toggleAuthMode,
                        child: Text(
                          authProvider.isRegistering
                              ? "Já tem uma conta? Faça login"
                              : "Não tem conta? Cadastre-se",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) => value!.isEmpty ? validatorMessage : null,
    );
  }

  Widget _buildButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: 250,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}

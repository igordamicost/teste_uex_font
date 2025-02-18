// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste_uex_font/pages/user-provider.dart';

class AddUserModal extends StatefulWidget {
  final VoidCallback atualizarLista;

  const AddUserModal({super.key, required this.atualizarLista});

  @override
  _AddUserModalState createState() => _AddUserModalState();
}

class _AddUserModalState extends State<AddUserModal> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _logradouroController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _complementoController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();

  String? idReference;
  bool _isLoadingCep = false;
  final bool _possuiComplemento = false;
  bool _enderecoCarregado = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _loadUserData);
  }

  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUserData();

    setState(() {
      idReference = userProvider.idReferencia;
    });
  }

  Future<void> _buscarEndereco(String cep) async {
    setState(() {
      _isLoadingCep = true;
      _enderecoCarregado = false;
    });

    try {
      final response = await http.get(Uri.parse("https://viacep.com.br/ws/$cep/json"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey("erro")) {
          throw Exception("CEP inválido");
        }

        setState(() {
          _logradouroController.text = data['logradouro'] ?? '';
          _bairroController.text = data['bairro'] ?? '';
          _cidadeController.text = data['localidade'] ?? '';
          _estadoController.text = data['uf'] ?? '';
          _enderecoCarregado = true;
        });
      } else {
        throw Exception("Erro ao buscar CEP");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("CEP não encontrado!")),
      );
    } finally {
      setState(() => _isLoadingCep = false);
    }
  }

  Future<void> _salvarCadastro() async {
    if (_formKey.currentState!.validate()) {
      if (idReference == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro: ID do usuário não carregado! Tente novamente.")),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final String? cadastrosString = prefs.getString('cadastros');
      List<Map<String, dynamic>> cadastros = cadastrosString != null
          ? List<Map<String, dynamic>>.from(jsonDecode(cadastrosString))
          : [];

      final novoCadastro = {
        "idReference": idReference,
        "nome": _nameController.text,
        "email": _emailController.text,
        "cpf": _cpfController.text,
        "telefone": _telefoneController.text,
        "endereco": {
          "cep": _cepController.text,
          "logradouro": _logradouroController.text,
          "numero": _numeroController.text,
          "complemento": _possuiComplemento ? _complementoController.text : "",
          "bairro": _bairroController.text,
          "localidade": _cidadeController.text,
          "uf": _estadoController.text,
        }
      };

      cadastros.add(novoCadastro);
      await prefs.setString('cadastros', jsonEncode(cadastros));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário cadastrado com sucesso!")),
      );

      widget.atualizarLista();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Cadastrar Usuário", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildOutlinedTextField(_nameController, "Nome", Icons.person, "Nome obrigatório"),
                    _buildOutlinedTextField(_emailController, "E-mail", Icons.email, "E-mail obrigatório"),
                    _buildOutlinedTextField(_cpfController, "CPF", Icons.badge, "CPF obrigatório"),
                    _buildOutlinedTextField(_telefoneController, "Telefone", Icons.phone, "Telefone obrigatório"),
                    _buildOutlinedTextField(_cepController, "CEP", Icons.location_on, "CEP obrigatório", onChanged: (value) {
                      if (value.length == 8) _buscarEndereco(value);
                    }),
                    if (_isLoadingCep) 
                      const Center(child: CircularProgressIndicator()),
                    if (_enderecoCarregado) ...[
                      _buildOutlinedTextField(_logradouroController, "Logradouro", Icons.location_city, "Logradouro obrigatório"),
                      _buildOutlinedTextField(_numeroController, "Número", Icons.numbers, "Número obrigatório"),
                      _buildOutlinedTextField(_bairroController, "Bairro", Icons.home, "Bairro obrigatório"),
                      _buildOutlinedTextField(_cidadeController, "Cidade", Icons.location_city, "Cidade obrigatória"),
                      _buildOutlinedTextField(_estadoController, "Estado", Icons.map, "Estado obrigatório"),
                    ],
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
                    onPressed: _salvarCadastro,
                    child: const Text("Cadastrar"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    String validatorMessage, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
  }) {
    return SizedBox(
      width: 250,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => validatorMessage.isNotEmpty && value!.isEmpty ? validatorMessage : null,
      ),
    );
  }
}

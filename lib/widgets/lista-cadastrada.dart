import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CadastroListWidget extends StatefulWidget {
  final String idUsuario;
  final Function(double, double) atualizarMapa;

  const CadastroListWidget({super.key, required this.idUsuario, required this.atualizarMapa});

  @override
  _CadastroListWidgetState createState() => _CadastroListWidgetState();
}

class _CadastroListWidgetState extends State<CadastroListWidget> {
  List<Map<String, dynamic>> _cadastros = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCadastros();
  }

  Future<void> _fetchCadastros() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cadastrosString = prefs.getString('cadastros');

      if (cadastrosString != null) {
        final List<dynamic> cadastrosList = jsonDecode(cadastrosString);

        final List<Map<String, dynamic>> filteredCadastros = cadastrosList
            .where((cadastro) => cadastro["idReference"] == widget.idUsuario)
            .map((cadastro) => Map<String, dynamic>.from(cadastro))
            .toList();

        setState(() {
          _cadastros = filteredCadastros;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar cadastros: ${e.toString()}")),
      );
    }
  }

  Future<void> _buscarEndereco(Map<String, dynamic> endereco) async {
    String enderecoCompleto =
        "${endereco["logradouro"]}, ${endereco["numero"]}, ${endereco["bairro"]}, ${endereco["localidade"]}, ${endereco["uf"]}";

    final url = Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$enderecoCompleto');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      if (data.isNotEmpty) {
        double latitude = double.parse(data[0]['lat']);
        double longitude = double.parse(data[0]['lon']);

        widget.atualizarMapa(latitude, longitude);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Endereço não encontrado.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao buscar coordenadas.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Usuários Cadastrados",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _cadastros.isEmpty
                ? const Center(child: Text("Nenhum usuário cadastrado."))
                : Expanded(
                    child: ListView.builder(
                      itemCount: _cadastros.length,
                      itemBuilder: (context, index) {
                        final cadastro = _cadastros[index];
                        return _buildCadastroTile(cadastro);
                      },
                    ),
                  ),
      ],
    );
  }

  Widget _buildCadastroTile(Map<String, dynamic> cadastro) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cadastro["nome"],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Telefone: ${cadastro["telefone"]}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            TextButton(
              onPressed: () {
                _buscarEndereco(cadastro["endereco"]);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: const Text(
                "Buscar Endereço",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        children: [
          _buildCadastroDetail("Email", cadastro["email"]),
          _buildCadastroDetail("CPF", cadastro["cpf"]),
          _buildCadastroDetail("Endereço", "${cadastro["endereco"]["logradouro"]}, Nº ${cadastro["endereco"]["numero"]}"),
          _buildCadastroDetail("Bairro", cadastro["endereco"]["bairro"]),
          _buildCadastroDetail("Cidade", cadastro["endereco"]["localidade"]),
          _buildCadastroDetail("Estado", cadastro["endereco"]["uf"]),
        ],
      ),
    );
  }

  Widget _buildCadastroDetail(String title, String value) {
    return ListTile(
      title: Text("$title: $value", style: const TextStyle(fontSize: 14)),
    );
  }
}

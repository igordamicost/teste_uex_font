import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste_uex_font/widgets/cadastro.dart';
import 'package:teste_uex_font/widgets/lista-cadastrada.dart';
import 'package:teste_uex_font/widgets/mapa-widget.dart';
import 'package:teste_uex_font/widgets/topmenu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? idUsuario;
  double? latitude;
  double? longitude;
  Key _mapKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tokenData = prefs.getString('auth_token');
    if (tokenData != null) {
      final Map<String, dynamic> token = jsonDecode(tokenData);
      setState(() {
        idUsuario = token['id'];
      });
    }
  }

  void _fetchCadastros() {
    setState(() {});
  }

  void _updateMapLocation(double lat, double lon) {
    setState(() {
      latitude = lat;
      longitude = lon;
      _mapKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height; 
    double appBarHeight = 60;
    double padding = 16 * 2; 
    double availableHeight = screenHeight - appBarHeight - padding; 

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: TopMenu(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => AddUserModal(atualizarLista: _fetchCadastros),
                  );
                  _fetchCadastros();
                },
                tooltip: "Adicionar novo Cadastro",
                backgroundColor: Colors.blue,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return constraints.maxWidth >= 800
                      ? Row(
                          children: [
                            _buildCadastroCard(availableHeight),
                            const SizedBox(width: 16),
                            _buildMapaCard(availableHeight),
                          ],
                        )
                      : Column(
                          children: [
                            _buildCadastroCard(availableHeight / 2), 
                            const SizedBox(height: 16),
                            _buildMapaCard(availableHeight / 2),
                          ],
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCadastroCard(double height) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: idUsuario != null
              ? SizedBox(
                  height: height,
                  child: CadastroListWidget(idUsuario: idUsuario!, atualizarMapa: _updateMapLocation),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildMapaCard(double height) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: latitude != null && longitude != null
                ? MapaWidget(key: _mapKey, latitude: latitude!, longitude: longitude!)
                : const Center(child: Text("Nenhuma localização disponível.")),
          ),
        ),
      ),
    );
  }
}

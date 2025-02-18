import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teste_uex_font/pages/user-provider.dart';
import 'package:teste_uex_font/widgets/delete-modal.dart';

class TopMenu extends StatelessWidget {
  const TopMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 4,
      shadowColor: Colors.black26,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 40,
            child: Image.asset('assets/uex.png'),
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "profile") {
                showDialog(
                  context: context,
                  builder: (context) => DeleteAccountModal(),
                );
              } else if (value == "logout") {
                Provider.of<UserProvider>(context, listen: false).logout();
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "profile",
                child: Text("Perfil"),
              ),
              const PopupMenuItem(
                value: "logout",
                child: Text("Sair"),
              ),
            ],
            icon: const Icon(Icons.menu, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}

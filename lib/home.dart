import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:green_messenger/pages/contatos.dart';
import 'package:green_messenger/pages/conversas.dart';

import 'login.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {

  String _emailUsuario = "";
  TabController _tabController;
  List<String> _itensMenu = ["Configurações", "Logout"];

  Future _jaEstaLogado() async {

    User usuarioLogado = await _auth.currentUser;
    if (usuarioLogado == null) {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  void initState() {
    _jaEstaLogado();
    _usuarioLogado();
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  Future _usuarioLogado() async {
    //_auth.signOut();
    User usuarioLogado = await _auth.currentUser;
    setState(() {
      _emailUsuario = usuarioLogado.email;
    });
  }

  _escolhaMenuItem(String itemEscolhido) {
    switch(itemEscolhido) {
      case "Configurações":
        Navigator.pushNamed(context, "/configuracoes");
        break;
      case "Logout":
        _logout();
        break;
    }
  }

  _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Whatsapp"),
          bottom: TabBar(
            indicatorWeight: 4,
            labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Conversas"),
              Tab(text: "Contatos")
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: _escolhaMenuItem,
              itemBuilder: (context) {
                return _itensMenu.map((item) => PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                )).toList();
              },
            )
          ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Conversas(),
          Contatos()
        ],
      )
    );
  }
}

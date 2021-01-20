import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_messenger/model/usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Contatos extends StatefulWidget {
  @override
  _ContatosState createState() => _ContatosState();
}

class _ContatosState extends State<Contatos> {

  String _emailUsuarioLogado;
  String _idUsuarioLogado;

  Future<List<Usuario>> _recuperarContatos() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await db.collection("usuarios").get();
    List<Usuario> usuarios = List();
    for (DocumentSnapshot item in querySnapshot.docs) {
      var dados = item.data();
      Usuario usuario = Usuario();
      usuario.id = item.id;
      usuario.nome = dados["nome"];
      usuario.email = dados["email"];
      usuario.urlImagem = dados["urlImagem"];
      final FirebaseAuth _auth = FirebaseAuth.instance;
      User user = _auth.currentUser;
      if (_emailUsuarioLogado != usuario.email) {
        usuarios.add(usuario);
      }
    }
    return Future.value(usuarios);
  }

  _recuperarDadosUsuario() {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    _idUsuarioLogado = user.uid;
    _emailUsuarioLogado = user.email;
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _recuperarContatos(),
      builder: (context, snapshot) {
        List<Usuario> usuarios = snapshot.data;
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: [
                  Text("Carregando contatos..."),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            return ListView.builder(
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                Usuario u = usuarios[index];
                return ListTile(
                  contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  leading: CircleAvatar(
                      maxRadius: 32,
                      backgroundColor: Colors.grey,
                      backgroundImage: u.urlImagem != null ? NetworkImage(u.urlImagem) : null,
                  ),
                  title: Text(u.nome, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  onTap: () => Navigator.pushNamed(context, "/mensagens", arguments: u),
                );
              },
            );
            break;
        }
      },
    );
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:green_messenger/model/conversa.dart';
import 'package:green_messenger/model/usuario.dart';

class Conversas extends StatefulWidget {
  @override
  _ConversasState createState() => _ConversasState();
}

class _ConversasState extends State<Conversas> {

  List<Conversa> conversas = [

  ];

  final _controller = StreamController<QuerySnapshot>.broadcast();
  FirebaseFirestore db = FirebaseFirestore.instance;
  User _user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Conversa conversa = Conversa();
    conversa.nome = "Amanda Siqueira Dutra";
    conversa.mensagem = "Oi pai";
    conversa.pathImageAvatar = "https://firebasestorage.googleapis.com/v0/b/green-messenger-ef01e.appspot.com/o/perfil%2Famanda.jpg?alt=media&token=e94845cc-6fa8-4eb7-b27b-cb0fcc8d268b";
    conversas.add(conversa);
    final FirebaseAuth _auth = FirebaseAuth.instance;
    _user = _auth.currentUser;
    _adicionarListenerConversas();
  }

  Stream<QuerySnapshot> _adicionarListenerConversas() {
    final stream = db
        .collection("conversas")
        .doc(_user.uid)
        .collection("ultima_conversa")
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
        stream: _controller.stream,
        builder: (context, snapshot) {
          if (snapshot == null) {
            return Container(child: Text("Fudeu"));
          }
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                children: [
                  Text("Sem conversas..."),

                ],
              ),
            );
          }
          if (snapshot.hasError) {
            return Text("Erro ao carregar dados");
          }
          if (snapshot.hasData) {

            return ListView.builder(
              itemCount: snapshot.data.docs.length ,
              itemBuilder: (context, index) {
                List<DocumentSnapshot> conversas = snapshot.data.docs.toList();
                DocumentSnapshot item = conversas[index];
                String imagem = item["pathImageAvatar"];
                String tipo = item["tipoMensagem"];
                String nome = item["nome"];
                String mensagem = item["mensagem"];
                String idDestinatario = item["idDestinatario"];

                Usuario u = Usuario();
                u.nome = nome;
                u.urlImagem = imagem;
                u.id = idDestinatario;

                return ListTile(
                  contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  leading: CircleAvatar(
                    maxRadius: 32,
                    backgroundColor: Colors.grey,
                    backgroundImage: imagem != null ? NetworkImage(imagem) : null,
                  ),
                  title: Text(nome),
                  subtitle: Text(tipo == "texto" ? mensagem : "Imagem..."),
                  onTap: () => Navigator.pushNamed(context, "/mensagens", arguments: u),
                );
              },
            );
          }
        }
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.close();
  }
}

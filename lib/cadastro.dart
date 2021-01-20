import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home.dart';
import 'model/usuario.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;


class Cadastro extends StatefulWidget {
  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String msgErro = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
      ),
      body: Container(
        decoration: BoxDecoration(color: Color(0xff075E54)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Image.asset("assets/images/usuario.png",
                        width: 200, height: 150),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextField(
                        controller: _controllerNome,
                        autofocus: true,
                        keyboardType: TextInputType.text,
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Nome",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32)),
                        ),
                      )),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextField(
                        controller: _controllerEmail,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "E-mail",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32)),
                        ),
                      )),
                  TextField(
                    controller: _controllerSenha,
                    obscureText: true,
                    style: TextStyle(fontSize: 20),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Password",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 10),
                    child: RaisedButton(
                      child: Text("Cadastrar",
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      color: Colors.green,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      onPressed: () {
                        _validarCampos();
                      },
                    ),
                  ),
                  Center(
                      child: Text(msgErro,
                          style: TextStyle(color: Colors.red, fontSize: 20)))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _validarCampos() {
    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if (nome.length > 2) {
      if (email.isNotEmpty && email.contains("@")) {
        if (senha.length > 5) {
          setState(() {
            msgErro = '';
          });
          Usuario usuario = Usuario();
          usuario.nome = nome;
          usuario.email = email;
          usuario.senha = senha;
          _cadastrarUsuario(usuario);
        } else {
          setState(() {
            msgErro = "Senha deve possuir no mínimo 6 caracteres";
          });
        }
      } else {
        setState(() {
          msgErro = "E-mail não preenchido ou inválido";
        });
      }
    } else {
      setState(() {
        msgErro = "Preencha o Nome";
      });
    }
  }

  _cadastrarUsuario(Usuario usuario) async {
    final User user = (await _auth.createUserWithEmailAndPassword(
            email: usuario.email, password: usuario.senha))
        .user;
    if (user != null) {
      FirebaseFirestore db = FirebaseFirestore.instance;
      db.collection("usuarios").doc(user.uid).set(usuario.toMap());
      Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
    } else {
      setState(() {
        msgErro =
            "Erro ao cadastrar usuário, verifique os campos e tente novamente.";
      });
    }
  }
}

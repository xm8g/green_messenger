import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'cadastro.dart';
import 'home.dart';
import 'model/usuario.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String msgErro = '';

  @override
  void initState() {
    _jaEstaLogado();
    super.initState();
  }

  Future _jaEstaLogado() async {

    User usuarioLogado = await _auth.currentUser;
    if (usuarioLogado != null) {
      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    child:
                        Image.asset("assets/images/logo.png", width: 200, height: 150),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextField(
                        controller: _controllerEmail,
                        autofocus: true,
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
                    style: TextStyle(fontSize: 20),
                    keyboardType: TextInputType.text,
                    obscureText: true,
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
                      child: Text("Login",
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
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Cadastro()));
                      },
                      child: Text("Não tem conta? Cadastre-se",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Center(child: Text(msgErro, style: TextStyle(color: Colors.red, fontSize: 20))),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _validarCampos() {
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

      if (email.isNotEmpty && email.contains("@")) {
        if (senha.isNotEmpty) {
          setState(() {
            msgErro = '';
          });
          Usuario usuario = Usuario();
          usuario.email = email;
          usuario.senha = senha;
          _logar(usuario);
        } else {
          setState(() {
            msgErro = "Preencha a senha.";
          });
        }
      } else {
        setState(() {
          msgErro = "E-mail não preenchido ou inválido";
        });
      }
  }

  void _logar(Usuario usuario) async {
    try {
      final User user = (await _auth.signInWithEmailAndPassword(
          email: usuario.email, password: usuario.senha)).user;
      if (user != null) {
        Navigator.pushReplacementNamed(context, "/home");
      }
    } catch (error) {
      setState(() {
        msgErro =
        "Erro ao autenticar usuário, verifique e-mail e senha e tente novamente.";
      });
    }
  }
}

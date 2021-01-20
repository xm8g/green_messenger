import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:green_messenger/cadastro.dart';
import 'package:green_messenger/pages/configuracoes.dart';
import 'package:green_messenger/pages/mensagens.dart';

import '../home.dart';
import '../login.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {

    switch(settings.name) {
      case "/":
        return MaterialPageRoute(builder: (context) => Login());
      case "/login":
        return MaterialPageRoute(builder: (context) => Login());
      case "/cadastro":
        return MaterialPageRoute(builder: (context) => Cadastro());
      case "/home":
        return MaterialPageRoute(builder: (context) => Home());
      case "/configuracoes":
        return MaterialPageRoute(builder: (context) => Configuracoes());
      case "/mensagens":
        return MaterialPageRoute(builder: (context) => Mensagens(settings.arguments));
      default:
        _erroRota();
    }
  }

  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(title: Text("Tela não encontrada")),
        body: Center(
          child: Text("Tela não encontrada"),
        ),
      );
    });
  }
}
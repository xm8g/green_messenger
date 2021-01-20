import 'package:cloud_firestore/cloud_firestore.dart';

class Conversa {

  String _idRemetente;
  String _idDestinatario;
  String _nome;
  String _mensagem;
  String _pathImageAvatar;
  String _tipoMensagem; //texto ou imagem

  Conversa();

  salvar() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("conversas")
    .doc(this.idRemetente)
    .collection("ultima_conversa")
    .doc(this.idDestinatario)
    .set(this.toMap());
  }

  String get pathImageAvatar => _pathImageAvatar;

  set pathImageAvatar(String value) {
    _pathImageAvatar = value;
  }

  String get idRemetente => _idRemetente;

  set idRemetente(String value) {
    _idRemetente = value;
  }

  String get mensagem => _mensagem;

  set mensagem(String value) {
    _mensagem = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get idDestinatario => _idDestinatario;

  String get tipoMensagem => _tipoMensagem;

  set tipoMensagem(String value) {
    _tipoMensagem = value;
  }

  set idDestinatario(String value) {
    _idDestinatario = value;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idRemetente": this.idRemetente,
      "idDestinatario": this.idDestinatario,
      "nome": this.nome,
      "mensagem": this.mensagem,
      "pathImageAvatar": this.pathImageAvatar,
      "tipoMensagem": this.tipoMensagem
    };
    return map;
  }

}
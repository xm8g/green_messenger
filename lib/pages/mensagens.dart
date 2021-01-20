import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:green_messenger/model/conversa.dart';
import 'package:green_messenger/model/mensagem.dart';
import 'package:green_messenger/model/usuario.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class Mensagens extends StatefulWidget {
  Usuario contato;

  Mensagens(this.contato);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  TextEditingController _controllerMensagem = TextEditingController();
  FirebaseFirestore db = FirebaseFirestore.instance;
  final _controller = StreamController<QuerySnapshot>.broadcast();
  final _scrollController = ScrollController();
  Usuario get getContato => widget.contato;
  PickedFile _imageFile;
  String idUser;
  bool subindoImagem = false;

  _enviarMensgem() {
    String textoMensagem = _controllerMensagem.text;
    if (textoMensagem.isNotEmpty) {
      Mensagem msg = Mensagem();
      msg.idUsuario = idUser;
      msg.mensagem = textoMensagem;
      msg.tipo = "texto";
      msg.data = Timestamp.now().toString();

      //Salvar msg no Store do remetente
      salvarMensagem(idUser, getContato.id, msg);
      //Salvar msg no Store do Destinatário
      salvarMensagem(getContato.id, idUser, msg);
      //Salvar Conversa
      _salvarConversa(msg);
    }
  }

  _salvarConversa(Mensagem m) {
    //Salvar conversa remetente
    Conversa cRememtente = Conversa();
    cRememtente.idRemetente = idUser;
    cRememtente.idDestinatario = getContato.id;
    cRememtente.mensagem = m.mensagem;
    cRememtente.nome = getContato.nome;
    cRememtente.pathImageAvatar = getContato.urlImagem;
    cRememtente.tipoMensagem = m.tipo;
    cRememtente.salvar();
    //Salvar conversa destinatário
    Conversa cDestinatario = Conversa();
    cDestinatario.idRemetente = getContato.id;
    cDestinatario.idDestinatario = idUser;
    cDestinatario.mensagem = m.mensagem;
    cDestinatario.nome = getContato.nome;
    cDestinatario.pathImageAvatar = getContato.urlImagem;
    cDestinatario.tipoMensagem = m.tipo;
    cDestinatario.salvar();
  }

  void salvarMensagem(String idRemetente, String idDestinatario, Mensagem m) {
    db
        .collection("mensagens")
        .doc(idRemetente)
        .collection(idDestinatario)
        .add(m.toMap());
    _controllerMensagem.clear();
  }

  _enviarFoto() async {
    PickedFile _imagemSelecionada;
    final ImagePicker _picker = ImagePicker();
    _imagemSelecionada = await _picker.getImage(source: ImageSource.gallery);

    String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    StorageReference pastaRaiz =  firebaseStorage.ref();
    StorageReference arquivo = pastaRaiz
        .child("mensagens")
        .child(idUser)
        .child(nomeImagem + ".jpg");

    //upload da imagem
    File file = File(_imagemSelecionada.path);
    StorageUploadTask task = arquivo.putFile(file);

    task.events.listen((StorageTaskEvent e) {
      if (e.type == StorageTaskEventType.progress) {
        setState(() {
          subindoImagem = true;
        });
      } else if (e.type == StorageTaskEventType.success) {
        setState(() {
          subindoImagem = false;
        });
      }
    });

    task.onComplete.then((StorageTaskSnapshot snapshot) {
      _recuperarUrlImagem(snapshot);
    });
  }

  Future _recuperarUrlImagem(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    Mensagem msg = Mensagem();
    msg.idUsuario = idUser;
    msg.mensagem = "";
    msg.urlImagem = url;
    msg.tipo = "imagem";
    msg.data = Timestamp.now().toString();

    //Salvar msg no Store do remetente
    salvarMensagem(idUser, getContato.id, msg);
    //Salvar msg no Store do Destinatário
    salvarMensagem(getContato.id, idUser, msg);

  }

  @override
  void initState() {
    super.initState();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    idUser = user.uid;
    _adicionarListenerMensagens();
  }

  Stream<QuerySnapshot> _adicionarListenerMensagens() {
    Stream<QuerySnapshot> stream = db
        .collection("mensagens")
        .doc(idUser)
        .collection(getContato.id)
        .orderBy("data", descending: false)
        .snapshots();
    stream.listen((dados) {
      _controller.add(dados);
      Timer(Duration(seconds: 1), () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
    });
  }

  @override
  Widget build(BuildContext context) {
    var caixaMensagem = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Padding(
                padding: EdgeInsets.only(right: 8),
                child: TextField(
                  controller: _controllerMensagem,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                      hintText: "Digite uma mensagem...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32)),
                      prefixIcon: IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: () => _enviarFoto(),
                      )),
                )),
          ),
          FloatingActionButton(
            backgroundColor: Color(0xFF075E54),
            child: Icon(Icons.send, color: Colors.white),
            mini: true,
            onPressed: () => _enviarMensgem(),
          )
        ],
      ),
    );

    var streamBuilder = StreamBuilder(
        stream: _controller.stream,
        builder: (context, snapshot) {
          if (snapshot == null) {
            return Container(child: Text("Fudeu"));
          }
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                children: [
                  Text("Carregando mensagens..."),
                  CircularProgressIndicator()
                ],
              ),
            );
          }
          if (snapshot.hasError) {
            return Expanded(child: Text("Erro ao carregar dados"));
          }
          if (snapshot.hasData) {
            QuerySnapshot data = snapshot.data;
            return Expanded(
              child: ListView.builder(
                  controller: _scrollController,
                  itemCount: data.docs.length,
                  itemBuilder: (context, index) {
                    //obtendo as mensgens
                    List<QueryDocumentSnapshot> mensagens = data.docs.toList();
                    QueryDocumentSnapshot msg = mensagens[index];
                    double larguraContainer =
                        MediaQuery.of(context).size.width * 0.8;
                    //Define cores e alinhamntos
                    Alignment alinhamento = Alignment.centerRight;
                    Color cor = Color(0xFFd2ffa5);
                    if (idUser != msg["_idUsuario"]) {
                      cor = Colors.white;
                      alinhamento = Alignment.centerLeft;
                    }

                    return Align(
                      alignment: alinhamento,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Container(
                          width: larguraContainer,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: cor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: msg["tipo"] == "imagem"
                              ? Image.network(msg["_urlImagem"])
                              : Text(msg["_mensagem"], style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    );
                  }),
            );
          }
        });

    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          CircleAvatar(
            maxRadius: 24,
            backgroundColor: Colors.grey,
            backgroundImage: widget.contato.urlImagem != null
                ? NetworkImage(widget.contato.urlImagem)
                : null,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(widget.contato.nome),
          ),
        ],
      )),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/bg.png"), fit: BoxFit.cover)),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [streamBuilder, caixaMensagem],
            ),
          ),
        ),
      ),
    );
  }
}

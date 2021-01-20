import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Configuracoes extends StatefulWidget {
  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {

  TextEditingController _controllerNome = TextEditingController();
  PickedFile _imageFile;
  String _idUsuarioLogado;
  bool subindoImagem = false;
  String _urlImagemPerfil;

  Future _recuperarImagem(String origemImagem) async {
    PickedFile _imagemSelecionada;
    dynamic _pickImageError;
    final ImagePicker _picker = ImagePicker();
    try {
      switch (origemImagem) {
        case "camera" :
          _imagemSelecionada = await _picker.getImage(source: ImageSource.camera);
          break;
        case "galeria" :
          _imagemSelecionada = await _picker.getImage(
              source: ImageSource.gallery);
          break;
      }
      setState(() {
        _imageFile = _imagemSelecionada;
        if (_imageFile != null) {
          subindoImagem = true;
          _uploadImagem();
        }
      });
    } catch (e) {
        setState(() {
          _pickImageError = e;
        });
    }
  }

  Future _uploadImagem() async {

    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    StorageReference pastaRaiz =  firebaseStorage.ref();
    StorageReference arquivo = pastaRaiz.child("perfil").child(_idUsuarioLogado + ".jpg");

    //upload da imagem
    File file = File(_imageFile.path);
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

    return Future.value(task);
  }

  Future _recuperarUrlImagem(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    _atualizarUrlImagemFirestore(url);
    setState(() {
      _urlImagemPerfil = url;
    });
  }

  _atualizarNomeFirestore() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Map<String, dynamic> dadosAtualizar = {
      "nome": _controllerNome.text
    };
    db.collection("usuarios").doc(_idUsuarioLogado).update(dadosAtualizar);
  }

  _atualizarUrlImagemFirestore(String url) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Map<String, dynamic> dadosAtualizar = {
      "urlImagem": url
    };
    db.collection("usuarios").doc(_idUsuarioLogado).update(dadosAtualizar);
  }

  _recuperarDadosUsuario() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    _idUsuarioLogado = user.uid;
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snapshot = await db.collection("usuarios").doc(_idUsuarioLogado).get();
    Map<String, dynamic> dados = snapshot.data();
    _controllerNome.text = dados["nome"];
    if (dados["urlImagem"] != null) {
      setState(() {
        _urlImagemPerfil = dados["urlImagem"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Configurações")),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    child: subindoImagem ? CircularProgressIndicator() : Container()
                  ),
                ),
                CircleAvatar(
                  radius: 100,
                  backgroundImage: _urlImagemPerfil != null ? NetworkImage(_urlImagemPerfil) : null,
                  backgroundColor: Colors.grey,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                        onPressed: () {
                          _recuperarImagem("camera");
                        },
                        child: Text("Câmera")
                    ),
                    FlatButton(
                        onPressed: () {
                          _recuperarImagem("galeria");
                        },
                        child: Text("Galeria")
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                      controller: _controllerNome,
                      autofocus: true,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          hintText: "Nome",
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32)
                          )
                      ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                    child: Text("Salvar",
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                    color: Colors.green,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                    onPressed: () {
                      _atualizarNomeFirestore();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Contato {
  String _nome;
  String _numero;
  String _pathImageAvatar;

  Contato(this._nome, this._numero, this._pathImageAvatar);

  String get pathImageAvatar => _pathImageAvatar;

  set pathImageAvatar(String value) {
    _pathImageAvatar = value;
  }

  String get numero => _numero;

  set numero(String value) {
    _numero = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }
}
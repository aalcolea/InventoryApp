class ListenerremoverOL{
  bool _change = false;
  final List<Function(bool)> _observadores = [];

  void setChange(bool value){
    _change = value;
    notificarObservadores();
  }

  void registrarObservador(Function(bool) callback){
    _observadores.add(callback);
  }

  void notificarObservadores(){
    for (var callback in _observadores){
      callback(_change);
    }
  }

  bool get change => _change;
}
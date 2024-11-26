class ListenerCatBox{
  bool _lock = false;
  final List<Function(bool)> _observadores = [];

  void setChange(bool value){
    _lock = value;
    notificarObservadores();
  }

  void registrarObservador(Function(bool) callback){
    _observadores.add(callback);
  }

  void notificarObservadores(){
    for (var callback in _observadores){
      callback(_lock);
    }
  }

  bool get lock => _lock;
}
class Listenerblurr{
  bool _blurr = false;
  final List<Function(bool)> _observadores = [];

  void setChange(bool value){
    _blurr = value;
    notificarObservadores();
  }

  void registrarObservador(Function(bool) callback){
    _observadores.add(callback);
  }

  void eliminarObservador(void Function(bool) observador) {
    _observadores.remove(observador);
  }

  void notificarObservadores(){
    for (var callback in _observadores){
      callback(_blurr);
    }
  }

  bool get change => _blurr;
}
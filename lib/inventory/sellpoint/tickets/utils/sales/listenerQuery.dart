class ListenerQuery{
  String? _query;
  final List<Function(String?)> _observadores = [];

  void setChange(String? query){
    _query = query;
    notificarObservadores();
  }

  void registrarObservador(Function(String?) callback){
    _observadores.add(callback);
  }

  void notificarObservadores(){
    for (var callback in _observadores){
      callback(_query);
    }
  }
  String? get query => _query;
}
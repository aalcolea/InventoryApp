class ListenerOnDateChanged{
  bool _change = false;
  String? _dateInit;
  String? _dateFinal;
  final List<Function(bool, String?, String?)> _observadores = [];

  void setChange(bool value, String? dateInit, String? dateFinal){
    _change = value;
    _dateInit = dateInit;
    _dateFinal = dateFinal;
    notificarObservadores();
  }

  void registrarObservador(Function(bool, String?, String?) callback){
    _observadores.add(callback);
  }

  void notificarObservadores(){
    for (var callback in _observadores){
      callback(_change, _dateInit, _dateFinal);
    }
  }

  bool get change => _change;
  String? get dateInit => _dateInit;
  String? get dateFinal => _dateFinal;
}
class ListenerPrintService {

  int _printServiceActivated = 0;
  bool? _isConnect;
  final List<Function(int, bool?)> _observadores = [];

  void setChange(int value, bool? val) {
    _printServiceActivated = value;
    _isConnect = val;
    notificarObservadores();
  }

  void registrarObservador(Function(int, bool?) callback) {
    _observadores.add(callback);
  }

  void notificarObservadores() {
    for (var callback in _observadores) {
      callback(_printServiceActivated, _isConnect);
    }
  }

  int get printServiceActivated => _printServiceActivated;
  bool? get isConnect => _isConnect;
}

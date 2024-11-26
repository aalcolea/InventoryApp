class Listenerslidable{
  bool _slide = false;
  int _dragIndex = 0;
  final List<Function(bool, int)> _observadores = [];

  void setChange(bool slideValue, int dragIndexValue){
    _slide = slideValue;
    _dragIndex =  dragIndexValue;
    notificarObservadores();
  }

  void registrarObservador(Function(bool, int) callback){
    _observadores.add(callback);
  }

  void notificarObservadores(){
    for (var callback in _observadores){
      callback(_slide, _dragIndex);
    }
  }

  bool get slide => _slide;
  int get dragIndex => _dragIndex;
}
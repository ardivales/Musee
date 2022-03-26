
import 'dart:async';
import 'package:tp_musee/Models/Moment.dart';
import '../Repository/MomentRepository.dart';

class MomentBloc {
  //Get instance of the Repository
  final _momentRepository = MomentRepository();

  final _paysController = StreamController<List<Moment>>.broadcast();

  get moment => _paysController.stream;

  MomentBloc() {
    getMoment();
  }

  Future<List<Moment>> getMoment() async {
    _paysController.sink.add(await _momentRepository.getAllMoment());
    return _momentRepository.getAllMoment();
  }

  addMoment(Moment moment) async {
    await _momentRepository.insertMoment(moment);
    getMoment();
  }

  dispose() {
    _paysController.close();
  }
}
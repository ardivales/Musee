import 'package:tp_musee/Dao/MomentDao.dart';
import 'package:tp_musee/Models/Moment.dart';

class MomentRepository{
  final momentDao = MomentDao();

  Future<List<Moment>> getAllMoment() => momentDao.getMoment();

  Future insertMoment(Moment moment) => momentDao.insertMoment(moment);

}
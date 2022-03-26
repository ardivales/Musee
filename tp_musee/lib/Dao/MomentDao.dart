
import 'package:tp_musee/Models/Moment.dart';

import '../Database/DatabaseProvider.dart';

class MomentDao{
  final databaseProvider = DatabaseProvider.databaseProvider;

  Future close() async{
    final db = await databaseProvider.database;
    db.close();
  }

  Future<List<Moment>> getMoment() async{
    final db = await databaseProvider.database;
    List result = await db.query("MOMENT");
    print ('result getMoment $result');
    
    return result.map((json)=>Moment.fromJson(json)).toList();

  }

  Future<int> insertMoment(Moment moment) async {
    final db = await databaseProvider.database;
    return await db.insert("MOMENT", moment.toJson());
  }

}
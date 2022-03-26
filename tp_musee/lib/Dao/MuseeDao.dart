import 'package:tp_musee/Models/Musee.dart';

import '../Database/DatabaseProvider.dart';

class MuseeDao{
  final databaseProvider = DatabaseProvider.databaseProvider;

  Future close() async{
    final db = await databaseProvider.database;
    db.close();
  }

  Future<int> insertMusee(Musee musee) async {
    final db = await databaseProvider.database;
    return await db.insert("MUSEE", musee.toJsonWithNumMus());
  }

  Future<List<Musee>> getMusees() async{
    final db = await databaseProvider.database;
    // final result = await db.rawQuery('SELECT * FROM $tableBase ORDER BY $orderBy');
    List result = await db.query("MUSEE", orderBy: 'numMus ASC');
    print ('result getMusees $result');
    
    return result.map((json)=>Musee.fromJson(json)).toList();
    
  }

  Future<int> updateMusee(Musee musee) async{
    final db = await databaseProvider.database;
    print(musee.numMus);
    return await db.update(
      "MUSEE", musee.toJsonWithNumMus(),
      where: 'numMus = ?', 
      whereArgs: [musee.numMus]);
    
  }

  Future<int> deleteMusee(Musee musee) async {
    final db = await databaseProvider.database;

    return await db.delete(
      "MUSEE", 
      where: 'numMus = ?', 
      whereArgs: [musee.numMus]);
  }

  Future<bool> getMuseeFromOtherTables(int numMus) async{
    final db = await databaseProvider.database;
    var maps = await db.query("BIBLIOTHEQUE",
      where: 'NumMus = ?', 
      whereArgs: [numMus]);

    if(maps.isNotEmpty){
      return true;
    }else{
      maps = await db.query("VISITER",
      where: 'NumMus = ?', 
      whereArgs: [numMus]);

      if(maps.isNotEmpty){
        return true;
      }else{
        print("Ce musée n'a pas été utilisé dans une autre table");
        return false;
      }
    }
  }
}
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider{
  static final DatabaseProvider databaseProvider = DatabaseProvider._init();
  static Database? _database;
  DatabaseProvider._init();

  Future<Database> get database async {

    Directory path = await getApplicationDocumentsDirectory();
    String dbPath = join(path.path, "musee.db");

    _database = await openDatabase(dbPath, version: 1, onCreate: _create);

    return _database!;
  }
  
  Future _create(Database db, int version) async {
    /*
    Pays[codePays, nbhabitant]
    Musee[numMus, nomMus, nblivres, codePays#]
    Visiter[numMus#, jour#, nbvisiteurs]
    Moment[jour]
    Ouvrage[ISBN, nbPage, titre, codePays#]
    Bibliotheque[numMus#, ISBN#, dateAchat]
    */

    await db.execute("""
            CREATE TABLE PAYS (
              codePays TEXT PRIMARY KEY, 
              nbhabitant INTEGER NOT NULL
            )""");

    await db.execute("""
            CREATE TABLE MUSEE (
              numMus INTEGER PRIMARY KEY AUTOINCREMENT,
              nomMus TEXT NOT NULL,
              nblivres INTEGER NOT NULL,
              codePays TEXT NOT NULL,
              FOREIGN KEY (codePays) REFERENCES PAYS (codePays)
            )""");

    await db.execute("""
            CREATE TABLE OUVRAGE (
              isbn TEXT PRIMARY KEY,
              nbPage INTEGER NOT NULL,
              titre TEXT NOT NULL,
              codePays TEXT NOT NULL,
              FOREIGN KEY (codePays) REFERENCES PAYS (codePays)
            )""");

    await db.execute("""
            CREATE TABLE BIBLIOTHEQUE (
              dateAchat TEXT NOT NULL,
              numMus INTEGER NOT NULL,
              isbn TEXT NOT NULL,
              FOREIGN KEY (numMus) REFERENCES MUSEE (numMus),
              FOREIGN KEY (isbn) REFERENCES PAYS (isbn)
              CONSTRAINT pk_numMus_isbn PRIMARY KEY(numMus, isbn)
            )""");

    await db.execute("""
            CREATE TABLE MOMENT (
              jour TEXT PRIMARY KEY
            )""");    
        
    await db.execute("""
            CREATE TABLE VISITER (
              jour TEXT NOT NULL,
              numMus INTEGER NOT NULL,
              nbvisiteurs INTEGER NOT NULL,
              FOREIGN KEY (numMus) REFERENCES MUSEE (numMus),
              FOREIGN KEY (jour) REFERENCES MOMENT (jour)
              CONSTRAINT pk_numMus_jour PRIMARY KEY(numMus, jour)
            )""");

  }

  Future close() async{
    final db = await databaseProvider.database;
    db.close();
  }

}
import 'package:cachdatabase/module/extension.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

import '../datamodel/user_model.dart';

class DBProvider{
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database? _database;

  Future<Database> get database async{
    _database ??= await initDB();
    return _database!;
  }

  initDB() async{
    var databasePath = await getDatabasesPath();
    String path = '$databasePath/database.db';
    return await openDatabase(path, version: 1, 
      onOpen: (db){}, 
      onCreate: (db, version) async{
        await db.execute('Create Table TBUser(id Integer Primary Key, firstname Text, lastname Text, phone Text, image Text)');
      }, 
      onUpgrade: (db, oldver, newver){},      
    );
  }

  void addUsers(List<User> users)async{
    final db = await database;
    db.transaction((txn)async{
      for(var itm in users){
        await txn.delete('TBUser', where: 'id = ?', whereArgs: [itm.id]);
        await txn.rawInsert('Insert Into TBUser(id, firstname, lastname, phone, image) Values(${itm.id}, "${itm.firstName}", "${itm.lastName}", "${itm.phone}", "${itm.image}")');
      }
    });
  }

  Future<List<User>> loadUsers()async{
    final db = await database;
    List<Map<String, dynamic>> rows = await db.rawQuery('Select id, firstName, lastName, phone From TBUser');
    debugPrint('cach loaded');
    return rows.map((e) => User.fromJson(e.toLower())).toList();
  }
}
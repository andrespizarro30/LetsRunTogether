
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper{

  static final DBHelper singleton = new DBHelper.internal();
  factory DBHelper() => singleton;
  static Database? _db;
  DBHelper.internal();
  static DBHelper shared() => singleton;

  static final String tblRaces = "tblRaces";

  static final Map tables = {
    tblRaces: ["raceId","raceData"],
  };

  Future<Database?> get db async{
    if(_db != null){
      return _db;
    }
    _db = await initDB();
    return _db;
  }

  initDB() async{

    String databasePath = await getDatabasesPath();

    /*var appDirectory = await getDownloadsDirectory();
    String appImagesPath = appDirectory!.path;
    Directory folderDir = Directory("${appImagesPath}/databases");*/

    String path = join(databasePath,'data.db');

    var isDBExists = await databaseExists(path);

    return await openDatabase(path,version: 1, onCreate: onCreate);

  }

  void onCreate(Database db,int newVersion) async{

    for(var tableName in tables.keys){

      List<String> tableFields = tables[tableName];

      String tableFieldsStruc = "";

      for (var i = 0; i < tableFields.length; i++) {
        if(i==0){
          tableFieldsStruc = "[${tableFields[i]}] TEXT PRIMARY KEY,";
        }else{
          tableFieldsStruc = "$tableFieldsStruc[${tableFields[i]}] TEXT,";
        }
      }

      tableFieldsStruc = tableFieldsStruc.substring(0, tableFieldsStruc.length - 1);

      await db.execute('CREATE TABLE $tableName($tableFieldsStruc)');

    }

  }

  static Future dbClearAll() async{
    if(_db==null){
      return;
    }

    // for(var tableName in tables.keys){
    //   await _db?.execute("DELETE FROM $tableName");
    // }

  }

  static Future bdClearTable(String tableName) async{
    if(_db==null){
      return;
    }
    await _db?.execute("DELETE FROM $tableName");
  }

  Future close() async{
    if(_db==null){
      return;
    }
    var dbClient = await db;

    return dbClient?.close();
  }

}
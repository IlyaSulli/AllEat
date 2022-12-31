import 'package:alleat/services/localprofiles_service.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLiteCartItems {
  // -------------------------------------
  // Cart Items Table
  // -------------------------------------

  static Future<void> createTableCartItems(sql.Database database) async {
    //Create cart table (Used to store items and their customised details)
    await database.execute("""CREATE TABLE cartItems(
        cartid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        itemid INT,
        customised TEXT,
        quantity INT
      )
      """);
  }

  static Future<sql.Database> cartdb() async {
    //If tables don't exist, create tables
    return sql.openDatabase(
      'alleatlocal.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await SQLiteLocalProfiles.createTableProfile(database);
        await createTableCartItems(database);
      },
    );
  }

  //------------------------------------------------------------
  // Edit Cart
  //------------------------------------------------------------

  // Add to Cart

  static Future<void> addToCart(
      int itemid, dynamic customised, int quantity) async {
    final db = await SQLiteCartItems.cartdb();
    db.insert("cartItems", {
      "itemid": itemid,
      "customised": customised,
      "quantity": quantity,
    });
  }
}

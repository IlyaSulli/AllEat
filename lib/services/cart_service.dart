import 'package:alleat/services/localprofiles_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLiteCartItems {
  // -------------------------------------
  // Cart Items Table
  // -------------------------------------

  static Future<void> createTableCartItems(sql.Database database) async {
    //Create cart table (Used to store items and their customised details)
    await database.execute("""CREATE TABLE cartItems(
        cartid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        profileid INTEGER,
        itemid INT,
        customised TEXT,
        quantity INT,
        FOREIGN KEY (profileid) REFERENCES localprofiles(profileid)
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

  static Future<bool> addToCart(
      int itemid, dynamic customised, int quantity) async {
    try {
      final db = await SQLiteCartItems.cartdb();
      final prefs = await SharedPreferences.getInstance();
      final String? profileid = prefs.getString(
          'serverprofileid'); //Try to get profileid of current user and convert
      if (profileid == null) {
        //If there is no current user selected
        return false;
      }
      int profileidInt = int.parse(profileid);
      await db.insert("cartItems", {
        "profileid": profileidInt,
        "itemid": itemid,
        "customised": customised,
        "quantity": quantity,
      });
      return true;
    } catch (e) {
      //If fails to add to cart
      return false;
    }
  }

  // Get a list of profiles which are in the cart

  static Future<List> getProfilesInCart() async {
    final db = await SQLiteCartItems.cartdb();
    List profilesInCart = await db.rawQuery("SELECT profileid FROM cartItems");
    List singleProfilesInCart = [];
    for (int i = 0; i < profilesInCart.length; i++) {
      if (!singleProfilesInCart.contains(profilesInCart[i]["profileid"])) {
        singleProfilesInCart.add(profilesInCart[i]["profileid"]);
      }
    }
    return singleProfilesInCart;
  }

  // Get a list of items that are under a profile ID

  static Future<List> getProfileCart(profileID) async { 
    final db = await SQLiteCartItems.cartdb();
    List itemsInCart = await db.rawQuery(
        "SELECT itemid, customised, quantity FROM cartItems WHERE profileid = $profileID");
    return itemsInCart;
  }
}

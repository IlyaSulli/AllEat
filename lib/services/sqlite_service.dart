import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLiteLocalDB {
  //------------------------------------------------------------
  // Default Database
  //------------------------------------------------------------

  static Future<void> createTableProfile(sql.Database database) async {
    //Create localprofiles table (Used to store local logged in profiles)
    await database.execute("""CREATE TABLE localprofiles(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        firstname TEXT,
        lastname TEXT,
        email TEXT,
        password TEXT,
        selected TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  static Future<void> createTablePreferences(sql.Database database) async {
    //Create systempreferebces table (Used to store app preferences including current location)
    await database.execute("""CREATE TABLE systempreferences(
        sysid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        profileid INT,
        apptheme TEXT,
        savedaddressextra TEXT,
        savedaddressstreet TEXT,
        savedaddresscity TEXT,
        savedaddresspostcode TEXT,
        FOREIGN KEY(profileid) REFERENCES localprofiles(id)
      )
      """);
  }

  static Future<sql.Database> db() async {
    //If tables don't exist, create tables
    return sql.openDatabase(
      'alleatlocal.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTableProfile(database);
        await createTablePreferences(database);
      },
    );
  }

  //------------------------------------------------------------
  // Address
  //------------------------------------------------------------

  static Future<List<Map<String, dynamic>>> getAddress() async {
    //Get saved address
    final db = await SQLiteLocalDB.db();
    List selectedProfile = await db.rawQuery(
        'SELECT id FROM localprofiles WHERE selected = True LIMIT 1'); //Get current profile so that it can check the saved address associated with it
    String selectedID = selectedProfile[0]["id"].toString();
    return await db.rawQuery(
        'SELECT savedaddressextra, savedaddressstreet, savedaddresscity, savedaddresspostcode FROM systempreferences WHERE profileid = $selectedID LIMIT 1'); //Get the saved address from the database
  }

  static Future<void> setAddress(String extraAddress, String streetAddress,
      String cityAddress, String postcodeAddress) async {
    //Save address to profile
    if (extraAddress.isEmpty) {
      //If a part of the address is null, replace with empty string
      extraAddress = "";
    }
    if (streetAddress.isEmpty) {
      streetAddress = "";
    }
    if (cityAddress.isEmpty) {
      cityAddress = "";
    }
    if (postcodeAddress.isEmpty) {
      postcodeAddress = "";
    }
    final db = await SQLiteLocalDB.db();
    List selectedProfile = await db.rawQuery(
        'SELECT id FROM localprofiles WHERE selected = True LIMIT 1'); //Get current selected profile so that saved address associated with current profile can be replaced with new one
    String selectedID = selectedProfile[0]["id"].toString();
    List<Map> profilesavedpreferences = await db.rawQuery(
        'SELECT sysid FROM systempreferences WHERE profileid = $selectedID ORDER BY sysid ASC LIMIT 1');
    if (profilesavedpreferences.isEmpty) {
      //If there is no preference record, create a new one
      await db.insert("systempreferences", {
        "profileid": selectedProfile[0]["id"],
        "savedaddressextra": extraAddress,
        "savedaddressstreet": streetAddress,
        "savedaddresscity": cityAddress,
        "savedaddresspostcode": postcodeAddress,
      });
    } else {
      //If there is a preference record associated with the selected profile, replace saved profile
      await db.rawUpdate(
          'UPDATE systempreferences SET savedaddressextra = "$extraAddress", savedaddressstreet = "$streetAddress", savedaddresscity = "$cityAddress", savedaddresspostcode = "$postcodeAddress" WHERE profileid = $selectedID');
    }
  }

  static Future<void> deletePreference(id) async {
    //Delete preference record associated with specified id
    final db = await SQLiteLocalDB.db();
    try {
      //Try to delete record
      await db
          .delete("systempreferences", where: "profileid = ?", whereArgs: [id]);
    } catch (err) {
      //If failed
      debugPrint(
          "Something went wrong when deleting an item: $err"); //print error
    }
  }

  //------------------------------------------------------------
  // Profile
  //------------------------------------------------------------

  // Create new profile
  static Future<void> createProfile(
      String firstname, String lastname, String email, String password) async {
    //Create profile using firstname, lastname, email and encrypted password
    final db = await SQLiteLocalDB.db();
    db.insert("localprofiles", {
      //Insert data into localprofiles table
      "firstname": firstname,
      "lastname": lastname,
      "email": email,
      "password": password
    });
  }

  // Get profiles
  static Future<List<Map<String, dynamic>>> getProfiles() async {
    final db = await SQLiteLocalDB.db();
    return db.query('localprofiles', orderBy: "id"); //get local profiles
  }

  // Get display profiles (Id, firstname, lastname, selected status)
  static Future<List> getDisplayProfiles() async {
    List checkSelected = await SQLiteLocalDB.getProfileSelected();
    if (checkSelected.length != 1) {
      //Check to make sure there is only one profile with the selected tag is true
      int index = (await SQLiteLocalDB.getFirstProfile())[0][
          "id"]; //Make reset the selected profile to be the first entry that is currently logged in
      await SQLiteLocalDB.setSelected(index);
    }
    final db = await SQLiteLocalDB.db();
    List<Map> result = await db.rawQuery(
        'SELECT id, firstname, lastname, selected FROM localprofiles ORDER BY id ASC'); //Get all the profiles logged in, sending id, firstname, lastname and selected status back
    return result;
  }

  // Set profile to be selected (returns profile)
  static Future<List<Map<String, dynamic>>> setProfileSelected(int id) async {
    //Set selected profile to the one inputted
    final db = await SQLiteLocalDB.db();
    db.execute(
        'UPDATE localprofiles SET selected = "FALSE"'); //Set all profiles selected status to false
    db.execute(
        'UPDATE localprofiles SET selected = "TRUE" WHERE id = "$id"'); //set inputted profile id to have selected status to true
    return db.rawQuery(
        'SELECT * FROM localprofiles WHERE selected = "TRUE" LIMIT 1'); //Get the profile info from the selected profile and send it back
  }

  // Get selected profile
  static Future<List> getProfileSelected() async {
    final db = await SQLiteLocalDB.db();

    List<Map> result = await db
        .rawQuery('SELECT * FROM localprofiles WHERE selected = 1 LIMIT 1');
    return result; //Return the first profile that has the selected status to true (should only be 1)
  }

  // Get profile info from id
  static Future<List<Map<String, dynamic>>> getProfileFromID(int id) async {
    final db = await SQLiteLocalDB.db();
    return db.query('localprofiles',
        where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Get profile info from email
  static Future<List<Map<String, dynamic>>> getProfileFromEmail(
      String email) async {
    final db = await SQLiteLocalDB.db();
    return db
        .rawQuery('SELECT * FROM localprofiles WHERE email = "$email" LIMIT 1');
  }

  // Get first profile in profiles table
  static Future<List<Map<String, dynamic>>> getFirstProfile() async {
    final db = await SQLiteLocalDB.db();
    return db.rawQuery('SELECT * FROM localprofiles ORDER BY id ASC LIMIT 1');
  }

  // Change selected to specific id (does not return)
  static Future<void> setSelected(int id) async {
    final db = await SQLiteLocalDB.db();
    db.rawUpdate(
        'UPDATE localprofiles SET selected = false'); //Set all profiles selected status to false
    db.rawUpdate(
        'UPDATE localprofiles SET selected = true WHERE id = "$id"'); //Set the inputted profile it to be true
  }

  // Update an profile by id
  static Future<void> updateProfile(int id, String firstname, String lastname,
      String email, String password) async {
    //Update profile using firstname, lastname, email and encrypted password
    final db = await SQLiteLocalDB.db();

    final data = {
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'password': password,
    };

    await db.update('localprofiles', data, where: "id = ?", whereArgs: [id]);
  }

  // Delete profile
  static Future<void> deleteProfile(int id) async {
    //Delete profile associated with the id inputted
    final db = await SQLiteLocalDB.db();
    try {
      //Try to delete profile
      await db.delete("localprofiles", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      // If it fails, prints the error to the console
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}

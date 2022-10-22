import 'package:alleat/services/queryserver.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetSelected {
  static Future<bool> selectProfile(id, firstname, lastname, email) async {
    dynamic favReataurantList = await QueryServer.query(
        'https://alleat.cpur.net/query/favouriterestaurantlist.php',
        {"profileemail": email});
    if (favReataurantList["Error"] == true) {
      return false;
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileid', id);
      await prefs.setString('firstname', firstname);
      await prefs.setString('lastname', lastname);
      await prefs.setString('email', email);
      await prefs.setString('favrestaurants',
          ((favReataurantList["message"])["restaurantids"]).toString());

      return true;
    }
  }
}

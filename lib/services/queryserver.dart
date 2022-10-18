import 'package:http/http.dart' as http;
import 'dart:convert' as converty;

class QueryServer {
  static Future<Map> query(phpurl, body) async {
    try {
      var res = await http.post(Uri.parse(phpurl), body: body);
      if (res.statusCode != 200) {
        return {"error": true, "message": "Error ${res.statusCode}"};
      } else {
        var data = converty.json.decode(res.body);
        if (data["error"]) {
          return {"error": true, "message": "Error 500"};
        } else {
          return {"error": false, "message": data};
        }
      }
    } catch (e) {
      return {"error": true, "message": "ERROR: $e"};
    }
  }
}

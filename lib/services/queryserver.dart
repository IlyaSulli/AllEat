import 'package:http/http.dart' as http;
import 'dart:convert' as converty;

class QueryServer {
  static Future<Map> query(phpurl, body) async { //Get url and data being sent
    try { //Try to send data to server
      var res = await http.post(Uri.parse(phpurl), body: body);
      if (res.statusCode != 200) { //If the server rejects the data return the error code
        return {"error": true, "message": "Error ${res.statusCode}"};
      } else { // If server successfully gets data
        var data = converty.json.decode(res.body); // Get the data sent back from the server and decode
        if (data["error"]) { //If the data has an error 
          return {"error": true, "message": "Error 500"}; //Return error 500 (server rejects data)
        } else { 
          return {"error": false, "message": data};
        }
      }
    } catch (e) { //If there is an error, return error message
      return {"error": true, "message": "ERROR: $e"};
    }
  }
}

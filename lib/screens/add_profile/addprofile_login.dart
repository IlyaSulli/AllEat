import 'package:alleat/widgets/navigationbar.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:alleat/services/sqlite_service.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as converty;
import 'dart:async';
import 'package:encrypt/encrypt.dart' as encrypty;
import 'package:crypto/crypto.dart' as cryptoy;

class AddProfileLogin extends StatelessWidget {
  const AddProfileLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Login to Profile';

    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop()),
      ),
      body: const AddProfileLoginPage(),
    );
  }
}

class AddProfileLoginPage extends StatefulWidget {
  const AddProfileLoginPage({Key? key}) : super(key: key);

  @override
  State<AddProfileLoginPage> createState() => _AddProfileLoginPageState();
}

class _AddProfileLoginPageState extends State<AddProfileLoginPage> {
  final _formKey = GlobalKey<FormState>();
  static TextEditingController email =
      TextEditingController(); //Create text controllers to allow for dynamic variable for form fields
  static TextEditingController password = TextEditingController();
  dynamic plainText;
  static dynamic encryptPassword;

  late bool error, sending, success, serverOffline;
  late String msg;
  late dynamic profileInfoImport;

  String phpurl =
      "https://alleat.cpur.net/query/login.php"; //Default values for sending data for logging in a user
  @override
  void initState() {
    error = false;
    sending = false;
    success = false;
    msg = "";
    super.initState();
  }

  Future<bool> loginUser() async {
    //send Data
    //On submit, start
    plainText = password.text;
    String strkey =
        'ZC8cegCGG45d1IjIACEtrfypDXtkgJ1rA+4JABPncUE='; //Static key and iv
    String striv = 'yvhsTTh739b2yUW9NNWrcKmHTtLTZNBjbiV3F/cSRzM=';
    var iv = cryptoy.sha256 //Grab the substring of the key and iv
        .convert(converty.utf8.encode(striv))
        .toString()
        .substring(0, 16);
    var key = cryptoy.sha256
        .convert(converty.utf8.encode(strkey))
        .toString()
        .substring(0, 16);
    encrypty.IV ivObj = encrypty.IV.fromUtf8(iv);
    encrypty.Key keyObj = encrypty.Key.fromUtf8(key);
    final encrypter =
        encrypty.Encrypter(encrypty.AES(keyObj, mode: encrypty.AESMode.cbc));
    encryptPassword = encrypter.encrypt(plainText,
        iv: ivObj); //Use the key and iv to encrypt the plaintext password
    encryptPassword = encryptPassword
        .base64; //Set password to be in base64 instead of type encrypted so that it can be sent
    try {
      var res = await http.post(Uri.parse(phpurl), body: {
        //Send data to login.php on server with email and encrypted password
        "email": email.text,
        "password": encryptPassword,
      }); //Sending post request with data
      if (res.statusCode == 200) {
        var data = converty.json.decode(res.body); //Decode to array
        if (data["error"]) {
          setState(() {
            //refresh the UI when error is recieved from server
            sending = false;
            error = true;
            msg = data["message"]; //error message from server
          });
          return success = false;
        } else {
          if (data["exists"]) {
            profileInfoImport = data["profile"];
            email.text = "";
            password.text = "";
            //clear form
            String profileInfoImportPassword = profileInfoImport[3].toString();

            await SQLiteLocalDB.createProfile(
                profileInfoImport[0],
                profileInfoImport[1],
                profileInfoImport[2],
                profileInfoImportPassword);
            List<Map> profileInfoTemp =
                await SQLiteLocalDB.getProfileFromEmail(profileInfoImport[2]);
            await SQLiteLocalDB.setSelected(profileInfoTemp[0]["id"]);

            setState(() {
              sending = false;
              success = true; //mark success and refresh UI with setState
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Successflully logged in.')),
              );
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Navigation()));
            });

            return success = true;
          } else {
            setState(() {
              sending = false;
              success = false;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Incorrect email or password')),
              );
            });
            return success = false;
          }
        }
      } else {
        //there is error
        setState(() {
          error = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to connect to server. Please try again')),
          );
          msg = "Connection to database failed.";
          sending = false;
          //mark error and refresh UI with setState
        });
        return success = false;
      }
    } catch (e) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to connect to server. Please try again')),
        );
        error = true;
        msg = "Connection to database failed.";
        sending = false;
        //mark error and refresh UI with setState
      });
      return success = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
                title: TextFormField(
              controller:
                  email, //Form data lastname collected and sent to database
              keyboardType: TextInputType.emailAddress,
              decoration: (const InputDecoration(
                  labelText: 'Email',
                  icon: Padding(
                      padding: EdgeInsets.only(top: 15.0),
                      child: Icon(Icons.email)))),
              inputFormatters: [
                //Only allows the input of letters a-z and A-Z and @,.-
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9@,.-]'))
              ],
              validator: (email) {
                //Required field and uses emailvalidator package to verify it is an email to simplify the code
                if (email == null || email.isEmpty) {
                  return "Required";
                }
                if (EmailValidator.validate(email) == false) {
                  return "Please enter valid email";
                }
                return null;
              },
            )),
            ListTile(
              title: TextFormField(
                keyboardType: TextInputType.visiblePassword,
                decoration: (const InputDecoration(
                    labelText: 'Password',
                    icon: Padding(
                        padding: EdgeInsets.only(top: 15.0),
                        child: Icon(Icons.lock)))),
                inputFormatters: [
                  //Password cannnot use " or ' in order to prevent SQL injection
                  FilteringTextInputFormatter.allow(
                      RegExp('[a-zA-Z0-9!@#%^&*(),.?:{}|<>]'))
                ],
                obscureText: true, //Password not visible
                controller:
                    password, //Password copied and checked by confirm password
                validator: (password) {
                  //Must be a minimum of 8 characters and contain a letter and number to make sure there is variety and make it harder to guess. Must be under 99 characters so that it reduces processing time on the system
                  if (password == null ||
                      password.isEmpty ||
                      password.length < 8 ||
                      password.length > 99 ||
                      !password.contains(RegExp(r'[0-9]')) ||
                      !password.contains(RegExp(r'[a-z]'))) {
                    return "Required";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 50), //Gap
            Center(
                child: Container(
              height: 70,
              width: 200,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                //submit button
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ))),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    loginUser();
                  }
                },
                child: const Text('Login to Profile'),
              ),
            ))
          ],
        ),
      ),
    );
  }
}

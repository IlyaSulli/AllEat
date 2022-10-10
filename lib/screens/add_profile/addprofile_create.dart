import 'package:alleat/services/sqlite_service.dart';
import 'package:alleat/widgets/navigationbar.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert' as converty;
import 'dart:async';
import 'package:encrypt/encrypt.dart' as encrypty;
import 'package:crypto/crypto.dart' as cryptoy;

class AddProfileCreate extends StatelessWidget {
  const AddProfileCreate({super.key});

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Register Profile';

    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop()),
      ),
      body: const AddProfileRegisterPage(),
    );
  }
}

// Create a Form widget.
class AddProfileRegisterPage extends StatefulWidget {
  const AddProfileRegisterPage({super.key});

  @override
  AddProfileRegisterPageState createState() {
    return AddProfileRegisterPageState();
  }
}

class AddProfileRegisterPageState extends State<AddProfileRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  static final passwordController = TextEditingController();

  static TextEditingController firstname =
      TextEditingController(); //Create text controllers to allow for dynamic variable for form fields
  static TextEditingController lastname = TextEditingController();
  static TextEditingController email = TextEditingController();
  static TextEditingController password = TextEditingController();
  dynamic plainText;
  static dynamic encryptPassword;

  late bool error, sending, success, serverOffline;
  late String msg;

  String phpurl =
      "https://alleat.cpur.net/query/register.php"; //Default values for sending data for registering a user
  @override
  void initState() {
    error = false;
    sending = false;
    success = false;
    msg = "";
    super.initState();
  }

  Future<bool> sendData() async {
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
    final encrypter = encrypty.Encrypter(encrypty.AES(keyObj,
        mode: encrypty.AESMode
            .cbc)); //Use the key and iv to encrypt the plaintext password
    encryptPassword = encrypter.encrypt(plainText, iv: ivObj);
    encryptPassword = encryptPassword
        .base64; //Set password to be in base64 instead of type encrypted so that it can be sent

    try {
      var res = await http.post(Uri.parse(phpurl), body: {
        //Send data to register.php on server with firstname, lastname, email and encrypted password
        "firstname": firstname.text,
        "lastname": lastname.text,
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
          await SQLiteLocalDB.createProfile(
              firstname.text, lastname.text, email.text, data["hash"]);

          List<Map> profileInfoTemp =
              await SQLiteLocalDB.getProfileFromEmail(email.text);
          await SQLiteLocalDB.setSelected(profileInfoTemp[0]["id"]);

          firstname.text = ""; //Clear the form fields
          lastname.text = "";
          email.text = "";
          passwordController.text = "";
          password.text = "";
          //clear form

          setState(() {
            sending = false;
            success = true; //mark success and refresh UI with setState
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile Successfully Created.')),
            );

            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Navigation()));
          });

          return success = true;
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
      //Create form
      key: _formKey,
      child: SingleChildScrollView(
        //Create scrollable page
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: ListTile(
                    title: TextFormField(
                  controller:
                      firstname, //Form data firstname collected and sent to database
                  keyboardType: TextInputType.name,
                  decoration: (const InputDecoration(
                    labelText: 'First Name',
                    icon: Padding(
                        padding: EdgeInsets.only(top: 15.0),
                        child: Icon(Icons.person)),
                  )),
                  inputFormatters: [
                    //Only allows the input of letters a-z and A-Z and . and -
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z.-]'))
                  ],
                  validator: (forename) {
                    //Required field with a minimum of 2 characters. Cannot be over 50 to prevent display issues
                    if (forename == null || forename.isEmpty) {
                      return "Required";
                    }
                    if (forename.length > 50) {
                      return "Name too long";
                    }
                    if (forename.length < 2) {
                      return "Name must be a minimum of 2 characters";
                    }
                    return null;
                  },
                )),
              ),
              Expanded(
                  child: ListTile(
                      title: TextFormField(
                controller:
                    lastname, //Form data lastname collected and sent to database
                keyboardType: TextInputType.name,
                decoration: (const InputDecoration(
                  labelText: 'Surname',
                )),
                inputFormatters: [
                  //Only allows the input of letters a-z and A-Z and . and -
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z.-]'))
                ],
                validator: (surname) {
                  //Required field with a minimum of 2 characters. Cannot be over 50 to prevent display issues
                  if (surname == null || surname.isEmpty) {
                    return "Required";
                  }
                  if (surname.length > 50) {
                    return "Surname too long";
                  }
                  return null;
                },
              )))
            ]),
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
                autofillHints: const [AutofillHints.newPassword],
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
                    passwordController, //Password copied and checked by confirm password
                validator: (password) {
                  //Must be a minimum of 8 characters and contain a letter and number to make sure there is variety and make it harder to guess. Must be under 99 characters so that it reduces processing time on the system
                  if (password == null || password.isEmpty) {
                    return "Required";
                  }
                  if (password.length < 7) {
                    return "Password under 7 characters";
                  }
                  if (password.length > 99) {
                    return "Password must be under 99 characters";
                  }
                  if (!password.contains(RegExp(r'[0-9]')) ||
                      !password.contains(RegExp(r'[a-z]'))) {
                    return "Password must contain at least 1 number and a letter";
                  }
                  return null;
                },
              ),
            ),
            ListTile(
              title: TextFormField(
                keyboardType: TextInputType.visiblePassword,
                autofillHints: const [AutofillHints.newPassword],
                decoration: (const InputDecoration(
                    labelText: 'Confirm Password',
                    icon: Padding(
                        padding: EdgeInsets.only(top: 15.0),
                        child: Icon(Icons.lock)))),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp('[a-zA-Z0-9!@#%^&*(),.?:{}|<>]'))
                ],
                obscureText: true, //Password not visible
                controller: password,
                validator: (confirmPassword) {
                  //Checked to make sure that the password is the same as the other password. Has to follow password rules
                  if (confirmPassword == null || confirmPassword.isEmpty) {
                    return "Required";
                  }
                  if (confirmPassword != passwordController.text) {
                    return "Passwords not the same";
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
                    //If fields have no errors
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Creating profile...')),
                    );
                    setState(() {
                      //Change status to sending to verify
                      sending = true;
                    });
                    sendData(); //run
                  }
                },

                child: const Text('Create Profile'),
              ),
            ))
          ],
        ),
      ),
    );
  }
}

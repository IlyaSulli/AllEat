import 'package:alleat/services/dataencryption.dart';
import 'package:alleat/services/localprofiles_service.dart';
import 'package:alleat/services/queryserver.dart';
import 'package:alleat/services/setselected.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'dart:async';

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
  static dynamic encryptPassword;
  late dynamic profileInfoImport;

  Future<void> loginUser() async {
    encryptPassword = await DataEncryption.encrpyt(password.text);
    var recievedServerData =
        await QueryServer.query("https://alleat.cpur.net/query/login.php", {
      //Send data to login.php on server with email and encrypted password
      "email": email.text,
      "password": encryptPassword,
    });
    if (recievedServerData["error"] == true) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(recievedServerData["message"] +
                " : Failed to login. Please try again")));
      });
      password.text = "";
    } else {
      if ((recievedServerData["message"])["exists"] == true) {
        Map importedProfile = (recievedServerData["message"])["profile"];
        bool trySelect = await SetSelected.selectProfile(importedProfile[0],
            importedProfile[1], importedProfile[2], importedProfile[3]);
        if (trySelect == false) {
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Failed to select profile")));
          });
        } else {
          await SQLiteLocalProfiles.createProfile(
              importedProfile[0],
              importedProfile[1],
              importedProfile[2],
              importedProfile[3],
              password.text);

          email.text = "";
          password.text = "";
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Successflully logged in.')),
            );
            //   Navigator.push(context,
            //       MaterialPageRoute(builder: (context) => const Navigation()));
          });
        }
      } else {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Incorrect email or password")));
        });
      }
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

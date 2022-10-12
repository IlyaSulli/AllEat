import 'package:alleat/services/dataencryption.dart';
import 'package:alleat/services/localprofiles_service.dart';
import 'package:alleat/services/queryserver.dart';
import 'package:alleat/services/setselected.dart';
import 'package:alleat/theme/theme.dart';
import 'package:alleat/widgets/elements/elements.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class AddProfileLogin extends StatelessWidget {
  const AddProfileLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AddProfileLoginPage(),
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
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;
    return SingleChildScrollView(
        physics: const PageScrollPhysics(),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const ScreenBackButton(),
                Padding(
                    padding:
                        const EdgeInsets.only(left: 50, right: 50, top: 30),
                    child: Image.asset((darkModeOn)
                        ? 'lib/assets/images/screens/profilesetup/login-illustration-dark.png'
                        : 'lib/assets/images/screens/profilesetup/login-illustration-light.png')),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: Align(
                        alignment: Alignment.center,
                        child: Text("Welcome back.",
                            style: Theme.of(context).textTheme.headline1))),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                        child: Column(children: [
                      Column(
                        children: [
                          ListTile(
                              title: TextFormField(
                            controller:
                                email, //Form data lastname collected and sent to database
                            keyboardType: TextInputType.emailAddress,
                            style: Theme.of(context).textTheme.bodyText2,
                            decoration: (InputDecoration(
                                hintText: "Email",
                                contentPadding: Theme.of(context)
                                    .inputDecorationTheme
                                    .contentPadding,
                                border: Theme.of(context)
                                    .inputDecorationTheme
                                    .border,
                                focusedBorder: Theme.of(context)
                                    .inputDecorationTheme
                                    .focusedBorder,
                                enabledBorder: Theme.of(context)
                                    .inputDecorationTheme
                                    .enabledBorder,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never)),
                            inputFormatters: [
                              //Only allows the input of letters a-z and A-Z and @,.-
                              FilteringTextInputFormatter.allow(
                                  RegExp('[a-zA-Z0-9@,.-]'))
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
                          const SizedBox(
                            height: 10,
                          ),
                          ListTile(
                            title: TextFormField(
                              keyboardType: TextInputType.visiblePassword,
                              style: Theme.of(context).textTheme.bodyText2,
                              decoration: (InputDecoration(
                                  hintText: "Password",
                                  contentPadding: Theme.of(context)
                                      .inputDecorationTheme
                                      .contentPadding,
                                  border: Theme.of(context)
                                      .inputDecorationTheme
                                      .border,
                                  focusedBorder: Theme.of(context)
                                      .inputDecorationTheme
                                      .focusedBorder,
                                  enabledBorder: Theme.of(context)
                                      .inputDecorationTheme
                                      .enabledBorder,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never)),
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
                        ],
                      ),
                    ])),
                  ),
                )
              ]),
              Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(
                        left: 30,
                        right: 30,
                        bottom: 60,
                      ),
                      child: Center(
                          child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          //submit button
                          style: Theme.of(context).elevatedButtonTheme.style,

                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              loginUser();
                            }
                          },
                          child: const Text('Login to Profile'),
                        ),
                      ))),
                ],
              )
            ]));
  }
}

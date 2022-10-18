import 'package:alleat/services/dataencryption.dart';
import 'package:alleat/services/localprofiles_service.dart';
import 'package:alleat/services/queryserver.dart';
import 'package:alleat/services/setselected.dart';
import 'package:alleat/widgets/elements/elements.dart';
import 'package:alleat/widgets/navigationbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';

class AddProfileCreationPageName extends StatefulWidget {
  const AddProfileCreationPageName({Key? key}) : super(key: key);

  @override
  State<AddProfileCreationPageName> createState() =>
      _AddProfileCreationPageNameState();
}

class _AddProfileCreationPageNameState
    extends State<AddProfileCreationPageName> {
  final _formKey = GlobalKey<FormState>();
  static TextEditingController firstnameText = TextEditingController();
  static TextEditingController lastnameText = TextEditingController();
  final data = [firstnameText.text = "", lastnameText.text = ""];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: [
      SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                    flex: 2,
                    fit: FlexFit.loose,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ScreenBackButton(),
                        Padding(
                            padding: const EdgeInsets.only(
                                top: 20, left: 20, right: 20, bottom: 5),
                            child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Step 1 of 3",
                                  style: Theme.of(context).textTheme.headline6,
                                  textAlign: TextAlign.center,
                                ))),
                        Padding(
                            padding: const EdgeInsets.only(
                                bottom: 20, left: 20, right: 20),
                            child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Let's Get Started.",
                                  style: Theme.of(context).textTheme.headline1,
                                  textAlign: TextAlign.center,
                                ))),
                        const SizedBox(
                          height: 20,
                        )
                      ],
                    )),
                Flexible(
                    flex: 2,
                    fit: FlexFit.loose,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  ListTile(
                                      title: TextFormField(
                                    controller:
                                        firstnameText, //Form data lastname collected and sent to database
                                    keyboardType: TextInputType.name,
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                    decoration: (InputDecoration(
                                        hintText: "Forename",
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
                                    validator: (firstname) {
                                      //Required field and uses emailvalidator package to verify it is an email to simplify the code
                                      if (firstname == null ||
                                          firstname.isEmpty) {
                                        return "Required";
                                      }

                                      return null;
                                    },
                                  )),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ListTile(
                                      title: TextFormField(
                                    controller:
                                        lastnameText, //Form data lastname collected and sent to database
                                    keyboardType: TextInputType.name,
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                    decoration: (InputDecoration(
                                        hintText: "Surname",
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
                                    validator: (lastname) {
                                      //Required field and uses emailvalidator package to verify it is an email to simplify the code
                                      if (lastname == null ||
                                          lastname.isEmpty) {
                                        return "Required";
                                      }
                                      return null;
                                    },
                                  )),
                                  const SizedBox(
                                    height: 50,
                                  ),
                                ],
                              ))
                        ])),
                Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: Column(
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
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            //If fields have no errors
                                            Navigator.pop(context);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddProfileCreationPageEmail(
                                                          firstname:
                                                              firstnameText
                                                                  .text,
                                                          lastname:
                                                              lastnameText.text,
                                                        )));
                                          } else {
                                            null;
                                          }
                                        },
                                        child: const Text("Continue"))))),
                        const SizedBox(
                          height: 50,
                        )
                      ],
                    ))
              ]))
    ]));
  }
}

class AddProfileCreationPageEmail extends StatefulWidget {
  const AddProfileCreationPageEmail({Key? key, this.firstname, this.lastname})
      : super(key: key);
  final dynamic firstname;
  final dynamic lastname;

  @override
  State<AddProfileCreationPageEmail> createState() =>
      _AddProfileCreationPageEmailState();
}

class _AddProfileCreationPageEmailState
    extends State<AddProfileCreationPageEmail> {
  final _formKey = GlobalKey<FormState>();
  static TextEditingController emailText = TextEditingController();
  static TextEditingController confirmemailText = TextEditingController();
  dynamic data = [emailText.text = "", confirmemailText.text = ""];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: [
      SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                    flex: 2,
                    fit: FlexFit.loose,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScreenBackButton(data: data),
                        Padding(
                            padding: const EdgeInsets.only(
                                top: 20, left: 20, right: 20, bottom: 5),
                            child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Step 2 of 3",
                                  style: Theme.of(context).textTheme.headline6,
                                  textAlign: TextAlign.center,
                                ))),
                        Padding(
                            padding: const EdgeInsets.only(
                                bottom: 20, left: 20, right: 20),
                            child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Profile Setup.",
                                  style: Theme.of(context).textTheme.headline1,
                                  textAlign: TextAlign.center,
                                ))),
                        const SizedBox(
                          height: 20,
                        )
                      ],
                    )),
                Flexible(
                    flex: 2,
                    fit: FlexFit.loose,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  ListTile(
                                      title: TextFormField(
                                    controller:
                                        emailText, //Form data lastname collected and sent to database
                                    keyboardType: TextInputType.emailAddress,
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
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
                                      if (EmailValidator.validate(email) ==
                                          false) {
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
                                    controller:
                                        confirmemailText, //Form data lastname collected and sent to database
                                    keyboardType: TextInputType.emailAddress,
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                    decoration: (InputDecoration(
                                        hintText: "Confirm email",
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
                                    validator: (confirmemail) {
                                      //Required field and uses emailvalidator package to verify it is an email to simplify the code
                                      if (confirmemail == null ||
                                          confirmemail.isEmpty) {
                                        return "Required";
                                      } else if (confirmemail !=
                                          emailText.text) {
                                        return "Emails do not match";
                                      }
                                      return null;
                                    },
                                  )),
                                  const SizedBox(
                                    height: 50,
                                  ),
                                ],
                              ))
                        ])),
                Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: Column(
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
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            //If fields have no errors
                                            Navigator.pop(context);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddProfileCreationPagePassword(
                                                          email: emailText.text,
                                                          confirmemail:
                                                              confirmemailText
                                                                  .text,
                                                          firstname:
                                                              widget.firstname,
                                                          lastname:
                                                              widget.lastname,
                                                        )));
                                          } else {
                                            null;
                                          }
                                        },
                                        child: const Text("Continue")))))
                      ],
                    ))
              ]))
    ]));
  }
}

class AddProfileCreationPagePassword extends StatefulWidget {
  const AddProfileCreationPagePassword(
      {Key? key, this.email, this.confirmemail, this.firstname, this.lastname})
      : super(key: key);
  final dynamic email;
  final dynamic confirmemail;
  final dynamic firstname;
  final dynamic lastname;

  @override
  State<AddProfileCreationPagePassword> createState() =>
      _AddProfileCreationPagePasswordState();
}

class _AddProfileCreationPagePasswordState
    extends State<AddProfileCreationPagePassword> {
  final _formKey = GlobalKey<FormState>();
  static TextEditingController passwordText = TextEditingController();
  static TextEditingController confirmpasswordText = TextEditingController();
  static dynamic encryptPassword;
  dynamic data = [passwordText.text = "", confirmpasswordText.text = ""];
  bool _passwordVisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: [
      SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                    flex: 2,
                    fit: FlexFit.loose,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScreenBackButton(data: data),
                        Padding(
                            padding: const EdgeInsets.only(
                                top: 20, left: 20, right: 20, bottom: 5),
                            child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Step 3 of 3",
                                  style: Theme.of(context).textTheme.headline6,
                                  textAlign: TextAlign.center,
                                ))),
                        Padding(
                            padding: const EdgeInsets.only(
                                bottom: 20, left: 20, right: 20),
                            child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Secure Password.",
                                  style: Theme.of(context).textTheme.headline1,
                                  textAlign: TextAlign.center,
                                ))),
                        const SizedBox(
                          height: 20,
                        )
                      ],
                    )),
                Flexible(
                    flex: 2,
                    fit: FlexFit.loose,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  ListTile(
                                      title: TextFormField(
                                    controller:
                                        passwordText, //Form data lastname collected and sent to database
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: !_passwordVisible,
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
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
                                            FloatingLabelBehavior.never,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _passwordVisible
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.5),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _passwordVisible =
                                                  !_passwordVisible;
                                            });
                                          },
                                        ))),

                                    autofillHints: const [
                                      AutofillHints.newPassword
                                    ],
                                    inputFormatters: [
                                      //Only allows the input of letters a-z and A-Z and @,.-
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[a-zA-Z0-9@$&!#?]'))
                                    ],
                                    validator: (password) {
                                      //Required field and uses emailvalidator package to verify it is an email to simplify the code
                                      if (password == null ||
                                          password.isEmpty) {
                                        return "Required";
                                      } else if (!password
                                              .contains(RegExp(r'[0-9]')) ||
                                          !password
                                              .contains(RegExp(r'[a-z]'))) {
                                        return "Password must contain at least 1 number and 1 letter";
                                      } else if (password.length < 8) {
                                        return "Password must be a minimum of 8 characters";
                                      } else if (password.length > 99) {
                                        return "Password must be a maximum of 99 characters";
                                      }
                                      return null;
                                    },
                                  )),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ListTile(
                                      title: TextFormField(
                                    controller:
                                        confirmpasswordText, //Form data lastname collected and sent to database
                                    keyboardType: TextInputType.visiblePassword,

                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                    decoration: (InputDecoration(
                                      hintText: "Confirm password",
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
                                          FloatingLabelBehavior.never,
                                    )),
                                    obscureText: true,
                                    autofillHints: const [
                                      AutofillHints.newPassword
                                    ],
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    inputFormatters: [
                                      //Only allows the input of letters a-z and A-Z and @,.-
                                      FilteringTextInputFormatter.allow(
                                          RegExp('[a-zA-Z0-9@,.-]'))
                                    ],
                                    validator: (confirmpassword) {
                                      //Required field and uses emailvalidator package to verify it is an email to simplify the code
                                      if (confirmpassword == null ||
                                          confirmpassword.isEmpty) {
                                        return "Required";
                                      } else if (confirmpassword !=
                                          passwordText.text) {
                                        return "Passwords do not match";
                                      }
                                      return null;
                                    },
                                  )),
                                  const SizedBox(
                                    height: 50,
                                  ),
                                ],
                              ))
                        ])),
                Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: Column(
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
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            //If fields have no errors
                                            _createProfile();
                                          } else {
                                            null;
                                          }
                                        },
                                        child: const Text("Create Profile")))))
                      ],
                    ))
              ]))
    ]));
  }

  Future<void> _createProfile() async {
    encryptPassword = await DataEncryption.encrpyt(passwordText.text);
    var recievedServerData =
        await QueryServer.query("https://alleat.cpur.net/query/register.php", {
      //Send data to login.php on server with email and encrypted password
      "firstname": widget.firstname,
      "lastname": widget.lastname,
      "email": widget.email,
      "password": encryptPassword
    });
    if (recievedServerData["error"] == true) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(recievedServerData["message"] +
                " : Failed to create profile. Please try again")));
      });
      passwordText.text = "";
      confirmpasswordText.text = "";
    } else {
      try {
        List importedProfile = (recievedServerData["message"])["profile"];

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
              importedProfile[4]);

          passwordText.text = "";
          confirmpasswordText.text = "";

          setState(() {
            Navigator.pop(context);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Successflully created profile.')),
            );
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Navigation()));
          });
        }
      } catch (e) {
        setState(() {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("ERROR: $e")));
        });
      }
    }
  }
}

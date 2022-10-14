import 'package:alleat/widgets/elements/elements.dart';
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
  static TextEditingController firstname = TextEditingController();
  static TextEditingController lastname = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: [
      SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ScreenBackButton(),
                    Padding(
                        padding: const EdgeInsets.only(
                            top: 20, left: 20, right: 20, bottom: 5),
                        child: Align(
                            alignment: Alignment.center,
                            child: Text("Step 1 of 3",
                                style: Theme.of(context).textTheme.headline6))),
                    Padding(
                        padding: const EdgeInsets.only(
                            bottom: 20, left: 20, right: 20),
                        child: Align(
                            alignment: Alignment.center,
                            child: Text("Let's Get Started.",
                                style: Theme.of(context).textTheme.headline1))),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                )),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          ListTile(
                              title: TextFormField(
                            controller:
                                firstname, //Form data lastname collected and sent to database
                            keyboardType: TextInputType.emailAddress,
                            style: Theme.of(context).textTheme.bodyText2,
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
                                  RegExp('[a-zA-Z.-]'))
                            ],
                            validator: (firstname) {
                              //Required field and uses emailvalidator package to verify it is an email to simplify the code
                              if (firstname == null || firstname.isEmpty) {
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
                                lastname, //Form data lastname collected and sent to database
                            keyboardType: TextInputType.emailAddress,
                            style: Theme.of(context).textTheme.bodyText2,
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
                                  RegExp('[a-zA-Z,.-]'))
                            ],
                            validator: (lastname) {
                              //Required field and uses emailvalidator package to verify it is an email to simplify the code
                              if (lastname == null || lastname.isEmpty) {
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
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        //If fields have no errors

                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const AddProfileCreationPageEmail()));
                                      } else {
                                        null;
                                      }
                                    },
                                    child: const Text("Continue")))))
                  ],
                )
              ]))
    ]));
  }
}

class AddProfileCreationPageEmail extends StatefulWidget {
  const AddProfileCreationPageEmail({super.key});

  @override
  State<AddProfileCreationPageEmail> createState() =>
      _AddProfileCreationPageEmailState();
}

class _AddProfileCreationPageEmailState
    extends State<AddProfileCreationPageEmail> {
  final _formKey = GlobalKey<FormState>();
  static TextEditingController emailText = TextEditingController();
  static TextEditingController confirmemailText = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: [
      SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ScreenBackButton(),
                    Padding(
                        padding: const EdgeInsets.only(
                            top: 20, left: 20, right: 20, bottom: 5),
                        child: Align(
                            alignment: Alignment.center,
                            child: Text("Step 2 of 3",
                                style: Theme.of(context).textTheme.headline6))),
                    Padding(
                        padding: const EdgeInsets.only(
                            bottom: 20, left: 20, right: 20),
                        child: Align(
                            alignment: Alignment.center,
                            child: Text("Profile Setup.",
                                style: Theme.of(context).textTheme.headline1))),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                )),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          ListTile(
                              title: TextFormField(
                            controller:
                                emailText, //Form data lastname collected and sent to database
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
                            controller:
                                confirmemailText, //Form data lastname collected and sent to database
                            keyboardType: TextInputType.emailAddress,
                            style: Theme.of(context).textTheme.bodyText2,
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
                                  RegExp('[a-zA-Z,.-]'))
                            ],
                            validator: (confirmemail) {
                              //Required field and uses emailvalidator package to verify it is an email to simplify the code
                              if (confirmemail == null ||
                                  confirmemail.isEmpty) {
                                return "Required";
                              } else if (confirmemail != emailText.text) {
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
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        //If fields have no errors

                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const AddProfileCreationPageEmail()));
                                      } else {
                                        null;
                                      }
                                    },
                                    child: const Text("Continue")))))
                  ],
                )
              ]))
    ]));
  }
}

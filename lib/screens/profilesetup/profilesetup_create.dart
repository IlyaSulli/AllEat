import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        body: SingleChildScrollView(
            physics: const PageScrollPhysics(),
            child: Form(
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
                          border: Theme.of(context).inputDecorationTheme.border,
                          focusedBorder: Theme.of(context)
                              .inputDecorationTheme
                              .focusedBorder,
                          enabledBorder: Theme.of(context)
                              .inputDecorationTheme
                              .enabledBorder,
                          floatingLabelBehavior: FloatingLabelBehavior.never)),
                      inputFormatters: [
                        //Only allows the input of letters a-z and A-Z and @,.-
                        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z.-]'))
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
                          border: Theme.of(context).inputDecorationTheme.border,
                          focusedBorder: Theme.of(context)
                              .inputDecorationTheme
                              .focusedBorder,
                          enabledBorder: Theme.of(context)
                              .inputDecorationTheme
                              .enabledBorder,
                          floatingLabelBehavior: FloatingLabelBehavior.never)),
                      inputFormatters: [
                        //Only allows the input of letters a-z and A-Z and @,.-
                        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z,.-]'))
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
                      height: 10,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            //If fields have no errors
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Creating profile...')),
                            );
                          } else {
                            null;
                          }
                        },
                        child: const Text("Continue"))
                  ],
                ))));
  }
}

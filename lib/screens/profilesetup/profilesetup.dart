import 'package:alleat/screens/profilesetup/profilesetup_login.dart';
import 'package:flutter/material.dart';

class ProfileSetupExisting extends StatefulWidget {
  const ProfileSetupExisting({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProfileSetupExisting();
  }
}

class _ProfileSetupExisting extends State<ProfileSetupExisting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Create new screen
      resizeToAvoidBottomInset: false, //Allow resize

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            //Create 2 buttons which allows you to either create a new profile or login with an existing profile
            children: [
              Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                      style: Theme.of(context).elevatedButtonTheme.style,
                      onPressed: () => (Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AddProfileLoginPage()))),
                      child: const Text("Login"))),
            ],
          )
        ],
      ),
    );
  }
}

import 'package:alleat/screens/profilesetup/profilesetup_login.dart';
import 'package:flutter/material.dart';

class FreshProfile extends StatefulWidget {
  const FreshProfile({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FreshProfile();
  }
}

class _FreshProfile extends State<FreshProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Create new screen
      resizeToAvoidBottomInset: false, //Allow resize
      appBar: AppBar(
        title: const Text('Welcome to All Eat.'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            //Create 2 buttons which allows you to either create a new profile or login with an existing profile
            children: [
              ElevatedButton(
                  onPressed: () => (Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddProfileLogin()))),
                  child: const Text("Login")),
            ],
          )
        ],
      ),
    );
  }
}
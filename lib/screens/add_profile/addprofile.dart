import 'package:alleat/screens/add_profile/addprofile_create.dart';
import 'package:alleat/screens/add_profile/addprofile_login.dart';
import 'package:flutter/material.dart';

class AddProfile extends StatefulWidget {
  const AddProfile({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddProfile();
  }
}

class _AddProfile extends State<AddProfile> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Add New Profile.',
        //Create new screen
        home: Scaffold(
          resizeToAvoidBottomInset: false, //Allow resize
          appBar: AppBar(
            title: const Text('Add New Profile'),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop()),
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
                              builder: (context) => const AddProfileCreate()))),
                      child: const Text("New Profile")),
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
        ));
  }
}

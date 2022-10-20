import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String edit = "Edit";
  Future<void> getProfileInfo() async {
    
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
            padding:
                const EdgeInsets.only(left: 30, right: 30, top: 50, bottom: 50),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Profiles",
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  ElevatedButton(
                      onPressed: null,
                      child: Row(
                        children: [
                          Icon(Icons.edit,
                              color: Theme.of(context).primaryColor),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(edit,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  ?.copyWith(
                                      color: Theme.of(context).primaryColor)),
                        ],
                      ))
                ],
              ),
              const SizedBox(
                height: 50,
              ),
            ])));
  }
}

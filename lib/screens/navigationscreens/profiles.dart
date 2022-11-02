import 'package:alleat/widgets/elements/profiles_buttons.dart';
import 'package:alleat/widgets/elements/profiles_selection.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: CustomScrollView(slivers: [
      SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
              padding: const EdgeInsets.only(top: 50, bottom: 50),
              child: Column(children: [
                Padding(
                    padding: const EdgeInsets.only(left: 40, right: 40),
                    child: Row(
                      //Display text with title Profiles
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Profiles",
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ],
                    )),
                const SizedBox(
                  height: 50,
                ),
                const ProfileList(), //Display slidable row of profiles
                const SizedBox(
                  height: 35,
                ),
                const ProfileButton(
                  // Display buttons for favourites, orders, settings and profile settings with an icon using the widget ProfileButton
                  icon: (Icons.favorite),
                  name: "Favourites",
                  action: null,
                ),
                const ProfileButton(
                  icon: (Icons.local_mall),
                  name: "Orders",
                  action: null,
                ),
                const ProfileButton(
                  icon: (Icons.settings),
                  name: "Settings",
                  action: null,
                ),
                const ProfileButton(
                  icon: (Icons.person),
                  name: "Profile Settings",
                  action: null,
                ),
              ])))
    ])));
  }
}

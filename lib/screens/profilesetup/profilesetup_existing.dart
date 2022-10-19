import 'package:alleat/screens/profilesetup/profilesetup_create.dart';
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

      body: Stack(children: [
        Image.asset(
          //Fullscreen image of food
          'lib/assets/images/screens/existingsetup/existingsetupscreenfood.jpg',
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
        ),
        Column(
          children: [
            Padding(
                //Image of All Eat logo
                padding: const EdgeInsets.only(
                    top: 50, left: 30, right: 30, bottom: 200),
                child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).backgroundColor,
                    ),
                    child: IconButton(
                        color: Theme.of(context).textTheme.headline1?.color,
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop())))
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment
              .end, //Create content at the bottom of the screen
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  //Bottom container with login and register actions
                  decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(
                              20))), // Round the top corners of container
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(children: [
                    const SizedBox(
                      height: 40,
                    ),
                    Text("Add New Profile.",
                        style: Theme.of(context).textTheme.headline2),
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 50, right: 50, top: 10, bottom: 10),
                        child: Text(
                          "Enhance your experience by using multiple profiles",
                          style: Theme.of(context).textTheme.headline6,
                          textAlign: TextAlign.center,
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      //Button actions
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(children: [
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                style:
                                    Theme.of(context).elevatedButtonTheme.style,
                                onPressed: () => (Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AddProfileCreationPageName()))),
                                child: const Text("Create a profile"))),
                        SizedBox(
                            width: 250,
                            child: TextButton(
                                style: Theme.of(context).textButtonTheme.style,
                                onPressed: () => (Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AddProfileLoginPage()))),
                                child: const Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "I already have a profile",
                                      textAlign: TextAlign.center,
                                    ))))
                      ]),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                  ]),
                ))
          ],
        )
      ]),
    );
  }
}

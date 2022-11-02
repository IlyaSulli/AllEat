import 'package:alleat/screens/profilesetup/profilesetup_create.dart';
import 'package:alleat/screens/profilesetup/profilesetup_login.dart';
import 'package:flutter/material.dart';

class ProfileSetupWelcome extends StatefulWidget {
  const ProfileSetupWelcome({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProfileSetupWelcome();
  }
}

class _ProfileSetupWelcome extends State<ProfileSetupWelcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Create new screen
      resizeToAvoidBottomInset: false, //Allow resize

      body: Stack(children: [
        Image.asset(
          //Fullscreen image of food
          'lib/assets/images/screens/welcomescreen/welcomescreenfood.jpg',
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
                    top: 70, left: 40, right: 40, bottom: 200),
                child: Image.asset(
                  'lib/assets/images/logo/logodark.png',
                  width: 58,
                  height: 58,
                ))
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
                    Text("Let's Get Started.",
                        style: Theme.of(context).textTheme.headline2),
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 50, right: 50, top: 10, bottom: 10),
                        child: Text(
                          "A food delivery app with you in mind",
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
                                onPressed: () => (Navigator.push( //Button to go to profile creation page
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AddProfileCreationPageName()))),
                                child: const Text("Create a profile"))),
                        SizedBox(
                            width: 250,
                            child: TextButton(
                                style: Theme.of(context).textButtonTheme.style,
                                onPressed: () => (Navigator.push( //Text button to go to login page
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

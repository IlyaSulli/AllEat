import 'package:flutter/material.dart';

class AppError extends StatefulWidget {
  const AppError({super.key});

  @override
  State<AppError> createState() => _AppErrorState();
}

class _AppErrorState extends State<AppError> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Error Page", //Error page
        home: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Center(
                child: Padding(
                    padding: const EdgeInsets.all(50),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment
                            .center, //Align text to center of the screen
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Text(
                            "All Eat.",
                            style: TextStyle(
                                fontSize: 21, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            //Display app failed
                            "The app has failed to perform an action.  \nPlease reopen the app to try again.",
                            textAlign: TextAlign.center,
                          )
                        ])))));
  }
}

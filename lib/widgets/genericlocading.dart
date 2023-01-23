import 'package:flutter/material.dart';

class GenericLoading extends StatefulWidget {
  const GenericLoading({super.key});

  @override
  State<GenericLoading> createState() => _GenericLoadingState();
}

class _GenericLoadingState extends State<GenericLoading> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Loading",
        home: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [CircularProgressIndicator()])),
        theme: Theme.of(context)); //Show blank page with circular loading circle
  }
}

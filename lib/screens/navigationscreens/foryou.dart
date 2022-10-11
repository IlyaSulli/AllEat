import 'package:flutter/material.dart';

class ForYouPage extends StatelessWidget {
  const ForYouPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'For You',
        style: Theme.of(context).textTheme.headline1,
      ),
    );
  }
}

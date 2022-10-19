import 'package:alleat/widgets/topbar.dart';
import 'package:flutter/material.dart';

class ForYouPage extends StatelessWidget {
  const ForYouPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const MainAppBar(
        height: 150,
      ),
      Center(
        child: Text(
          'For You',
          style: Theme.of(context).textTheme.headline1,
        ),
      )
    ]);
  }
}

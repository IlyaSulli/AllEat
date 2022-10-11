import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<List> getName() async {
      final prefs = await SharedPreferences.getInstance();
      final String? firstname = prefs.getString('firstname');
      final String? lastname = prefs.getString('lastname');
      return [firstname, lastname];
    }

    return Padding(
        padding:
            const EdgeInsets.only(left: 40, top: 40, right: 60, bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back',
              style: Theme.of(context).textTheme.headline6,
            ),
            FutureBuilder<List>(
              future: getName(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List? name = snapshot.data;
                  if (name![0] != null) {
                    return Text(
                      ('${name[0]}  ${name[1]}'),
                      style: Theme.of(context).textTheme.headline1,
                    );
                  } else {
                    return Text(
                      'Are you hungry?',
                      style: Theme.of(context).textTheme.headline2,
                    );
                  }
                } else {
                  return Text(
                    'Hungry?.',
                    style: Theme.of(context).textTheme.headline2,
                  );
                }
              },
            )
          ],
        ));
  }
}

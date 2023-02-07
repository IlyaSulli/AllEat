import 'package:alleat/services/localprofiles_service.dart';
import 'package:alleat/widgets/topbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<List> getName() async {
      // Get the name of the profile that is selected from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final String? firstname = prefs.getString('firstname');
      final String? lastname = prefs.getString('lastname');
      return [firstname, lastname];
    }

    return Column(children: [
      const MainAppBar(
        //Display main app bar at the top
        height: 150,
      ),
      Padding(
          padding: const EdgeInsets.only(left: 40, top: 40, right: 60, bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // Display welcome back
                'Welcome back',
                style: Theme.of(context).textTheme.headline6,
              ),
              FutureBuilder<List>(
                // run future to get the name from shared preferences
                future: getName(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    //If the data is recieved
                    List? name = snapshot.data; //Asign recieved data to name
                    if (name![0] != null) {
                      // If the data is not null
                      return Text(
                        // Display firstname and lastname
                        ('${name[0]} ${name[1]}'),
                        style: Theme.of(context).textTheme.headline1,
                      );
                    } else {
                      // If the data is null or anything else
                      return Text(
                        // Display Profile Unknown
                        'Profile Unknown.',
                        style: Theme.of(context).textTheme.headline1,
                      );
                    }
                  } else {
                    // While waiting to get data or there is an error while getting the data, display loading profile
                    return Text(
                      'Loading Profile...',
                      style: Theme.of(context).textTheme.headline1,
                    );
                  }
                },
              ),
            ],
          ))
    ]);
  }
}

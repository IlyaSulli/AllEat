import 'package:alleat/screens/locationselection.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  const MainAppBar({Key? key, required this.height}) : super(key: key);

  Future<String> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedLocationText =
        prefs.getStringList('locationPlacemark');
    if (savedLocationText != null) {
      return savedLocationText[1];
    } else {
      return ("No Location Set");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        //Container of height 120px
        height: 120,
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        child: SafeArea(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                    onTap: () {
                      Navigator.push(
                          //go to profile creation page
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SelectLocation()));
                    },
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          //Location icon
                          Icons.location_on_outlined,
                          color: Theme.of(context).textTheme.headline1?.color,
                        ))),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  //Column that will display the destination the food will be delivered to
                  Text(
                    "Location",
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  FutureBuilder<String>(
                      future: getSavedLocation(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text("Location loading");
                        }
                        if (snapshot.hasData) {
                          var location = snapshot.data ?? [];
                          return Text(location.toString());
                        } else {
                          return const Text("No Location Set");
                        }
                      })
                ]),
                Icon(
                  //Cart icon
                  Icons.shopping_cart_outlined,
                  color: Theme.of(context).textTheme.headline1?.color,
                ),
              ]),
        ));
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

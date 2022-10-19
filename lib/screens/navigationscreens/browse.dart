//import 'package:alleat/widgets/locationbutton.dart';
//import 'package:alleat/widgets/restaurantlist.dart';
import 'package:alleat/widgets/topbar.dart';
import 'package:flutter/material.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({Key? key}) : super(key: key);

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const MainAppBar(
        height: 150,
      ),
      Center(
        child: Text(
          'Browse',
          style: Theme.of(context).textTheme.headline1,
        ),
      )
    ]);
    //return SingleChildScrollView(
    //Enable scrollable screen
    //    child: Column(children: const [
    //  CurrentLocation(), //Show current location button widget
    //  RestaurantList(), //Show list of restaurants widget
    //]));
  }
}

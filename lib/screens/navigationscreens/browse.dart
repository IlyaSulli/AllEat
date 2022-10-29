import 'package:alleat/widgets/elements/browse_categories.dart';
import 'package:alleat/widgets/elements/search.dart';
import 'package:alleat/widgets/restaurants_list.dart';
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
    return SafeArea(
        child: Scaffold(
            body: SingleChildScrollView(
                child: Column(children: [
      const MainAppBar(
        height: 150,
      ),
      const SizedBox(height: 20),
      const SearchBar(),
      const SizedBox(height: 40),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Popular Categories.",
                style: Theme.of(context).textTheme.headline2,
              ),
              InkWell(
                  child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Icon(
                        Icons.chevron_right,
                        size: 30,
                        color: Theme.of(context).colorScheme.onBackground,
                      )),
                  onTap: () => (Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoriesPage(),
                      ))))
            ],
          )),
      const SizedBox(height: 40),
      const Categories(),
      const SizedBox(height: 40),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Restaurants.",
                style: Theme.of(context).textTheme.headline2,
              ),
              InkWell(
                  child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Icon(
                        Icons.tune,
                        size: 30,
                        color: Theme.of(context).colorScheme.onBackground,
                      )),
                  onTap: () => (null))
            ],
          )),
      const SizedBox(height: 30),
      const RestaurantList(),
    ]))));
  }
}

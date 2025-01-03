import 'package:alleat/screens/navigationscreens/browse.dart';
import 'package:alleat/screens/navigationscreens/foryou.dart';
import 'package:alleat/screens/navigationscreens/homepage.dart';
import 'package:alleat/screens/navigationscreens/profiles.dart';
import 'package:flutter/material.dart';

class Navigation extends StatefulWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0; //Start at Home page

  final List _screens = [
    {"screen": const HomePage()},
    {"screen": const ForYouPage()},
    {"screen": const BrowsePage()},
    {"screen": const ProfilePage()}
  ];

  void _onItemTapped(int index) {
    //When user click button on bottom navigation bar, change to that index
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: MaterialApp(
            title: "All Eat.",
            theme: Theme.of(context),
            home: Scaffold(
                body: _screens[_selectedIndex]["screen"],
                bottomNavigationBar: Theme(
                  data: Theme.of(context).copyWith(
                      canvasColor: Theme.of(context)
                          .bottomNavigationBarTheme
                          .backgroundColor),
                  child: BottomNavigationBar(
                    // If button is selected, show purple. If button is not selected show greyed out text and icon
                    selectedItemColor: Theme.of(context)
                        .bottomNavigationBarTheme
                        .selectedItemColor,
                    unselectedItemColor: Theme.of(context)
                        .bottomNavigationBarTheme
                        .unselectedItemColor,
                    backgroundColor: Theme.of(context)
                        .bottomNavigationBarTheme
                        .backgroundColor,
                    items: <BottomNavigationBarItem>[
                      //Bottom navigation bar items
                      BottomNavigationBarItem(
                        icon: Container(
                            padding: const EdgeInsets.only(
                                bottom:
                                    3), //Each have padding to separate from the text
                            child: const Icon(Icons
                                .home_outlined)), //Unselected icon is outlined
                        label: 'Home',
                        activeIcon: Container(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: const Icon(
                                Icons.home)), // Selected icon is filled
                      ),
                      BottomNavigationBarItem(
                        //Bottom navigation bar options
                        icon: Container(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: const Icon(Icons.assistant_outlined)),
                        label: 'For You',
                        activeIcon: Container(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: const Icon(Icons.assistant)),
                      ),
                      BottomNavigationBarItem(
                        icon: Container(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: const Icon(Icons.manage_search_rounded)),
                        label: 'Browse',
                        activeIcon: Container(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: const Icon(Icons.manage_search)),
                      ),
                      BottomNavigationBarItem(
                        icon: Container(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: const Icon(Icons.person_outlined)),
                        label: 'Profile',
                        activeIcon: Container(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: const Icon(Icons.person)),
                      ),
                    ],
                    onTap: _onItemTapped, //On tap, change selected option
                    currentIndex:
                        _selectedIndex, //Make current index the one last selected (defaults to home)
                  ),
                ))));
  }
}

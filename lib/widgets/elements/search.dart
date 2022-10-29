import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Container(
      width: double.infinity,
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Theme.of(context).colorScheme.onSurface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.05),
            spreadRadius: 10,
            blurRadius: 45,
            offset: const Offset(0, 30), // changes position of shadow
          ),
        ],
      ),
      child: Row(children: [
        Icon(
          Icons.search,
          color: Theme.of(context).textTheme.headline1?.color,
        ),
        const SizedBox(
          width: 20,
        ),
        Text(
          'Try searching "Pizza"',
          style: Theme.of(context).textTheme.bodyText2,
        )
      ]),
    ));
  }
}

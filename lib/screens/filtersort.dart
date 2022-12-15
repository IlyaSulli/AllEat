import 'package:alleat/widgets/elements/elements.dart';
import 'package:flutter/material.dart';

class FilterSort extends StatefulWidget {
  const FilterSort({super.key});

  @override
  State<FilterSort> createState() => _FilterSortState();
}

class _FilterSortState extends State<FilterSort> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const ScreenBackButton(),
        Text("Sort", style: Theme.of(context).textTheme.headline2),
        ElevatedButton(
            onPressed: null,
            child: Row(
              children: [
                const Icon(Icons.assistant_outlined),
                const SizedBox(width: 20),
                Text(
                  "Recommended (Default)",
                  style: Theme.of(context).textTheme.headline4,
                )
              ],
            )),
        ElevatedButton(
            onPressed: null,
            child: Row(
              children: [
                const Icon(Icons.star_border_outlined),
                const SizedBox(width: 20),
                Text(
                  "Top Rated",
                  style: Theme.of(context).textTheme.headline4,
                )
              ],
            )),
        ElevatedButton(
            onPressed: null,
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_outlined),
                const SizedBox(width: 20),
                Text(
                  "Popular",
                  style: Theme.of(context).textTheme.headline4,
                )
              ],
            )),
        ElevatedButton(
            onPressed: null,
            child: Row(
              children: [
                const Icon(Icons.straighten_outlined),
                const SizedBox(width: 20),
                Text(
                  "Distance",
                  style: Theme.of(context).textTheme.headline4,
                )
              ],
            ))
      ]),
    );
  }
}

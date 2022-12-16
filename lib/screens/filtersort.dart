import 'package:alleat/widgets/elements/elements.dart';
import 'package:flutter/material.dart';

class FilterSort extends StatefulWidget {
  const FilterSort({super.key});

  @override
  State<FilterSort> createState() => _FilterSortState();
}

class _FilterSortState extends State<FilterSort> {
  Map customiseSelected = {
    "sort": "default",
    "favourite": false,
    "price": [1, 2, 3, 4],
    "maxDelivery": 4,
    "minOrder": 40
  };
  List sortOptions = [
    ["Recommended", Icons.assistant_outlined, "default"],
    ["Top Rated", Icons.star_border_outlined, "top"],
    ["Popular", Icons.local_fire_department_outlined, "hot"],
    ["Distance", Icons.straighten_outlined, "distance"]
  ];
  List priceRangeOptions = [
    ["£", 1],
    ["££", 2],
    ["£££", 3],
    ["£££", 4]
  ];
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const ScreenBackButton(),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(
              height: 20,
            ),
            Text("Sort", style: Theme.of(context).textTheme.headline2),
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: sortOptions.length, //For each restaurant
                itemBuilder: (context, index) {
                  return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              side: customiseSelected["sort"] ==
                                      sortOptions[index][2]
                                  ? BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 2)
                                  : BorderSide.none,
                              backgroundColor:
                                  Theme.of(context).colorScheme.onSurface,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 25)),
                          onPressed: () {
                            setState(() {
                              customiseSelected["sort"] = sortOptions[index][2];
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                sortOptions[index][1],
                                color: customiseSelected["sort"] ==
                                        sortOptions[index][2]
                                    ? Theme.of(context)
                                        .textTheme
                                        .headline1
                                        ?.color
                                    : Theme.of(context)
                                        .textTheme
                                        .headline5
                                        ?.color,
                              ),
                              const SizedBox(width: 20),
                              Flexible(
                                  child: Text(
                                sortOptions[index][0],
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                      color: customiseSelected["sort"] ==
                                              sortOptions[index][2]
                                          ? Theme.of(context)
                                              .textTheme
                                              .headline1
                                              ?.color
                                          : Theme.of(context)
                                              .textTheme
                                              .headline5
                                              ?.color,
                                    ),
                              ))
                            ],
                          )));
                }),
            const SizedBox(
              height: 20,
            ),
            Text("Filter", style: Theme.of(context).textTheme.headline2),
            Row(
              children: [
                Flexible(
                    child: CheckboxListTile(
                  //Checkbox with text
                  title: Text(
                    "Show only favourites",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  checkColor: Colors.white,
                  activeColor: Theme.of(context).primaryColor,
                  contentPadding: EdgeInsets.all(0),
                  value: isChecked,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (newValue) {
                    setState(() {
                      isChecked = !isChecked;
                    });
                    if (isChecked) {
                      customiseSelected["favourite"] = true;
                    } else {
                      customiseSelected["filters"] = false;
                    }
                  },
                )),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Text("Price Range", style: Theme.of(context).textTheme.headline3),
            const SizedBox(
              height: 20,
            ),
            Container(
                color: Theme.of(context).colorScheme.onSurface,
                height: 50,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: priceRangeOptions.length, //For each restaurant
                    itemBuilder: (context, index) {
                      return ElevatedButton(
                        child: Text(
                          priceRangeOptions[index][0],
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        onPressed: null,
                      );
                    })),
          ])),
    ])));
  }
}

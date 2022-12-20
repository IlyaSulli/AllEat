import 'package:alleat/widgets/genericlocading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class FilterSort extends StatefulWidget {
  const FilterSort({super.key});

  @override
  State<FilterSort> createState() => _FilterSortState();
}

class _FilterSortState extends State<FilterSort> {
  List sortOptions = [
    //Sort options [Visual button text, icon, option saved in customiseSelected]
    ["Recommended", Icons.assistant_outlined, "default"],
    ["Top Rated", Icons.star_border_outlined, "top"],
    ["Popular", Icons.local_fire_department_outlined, "hot"],
    ["Distance", Icons.straighten_outlined, "distance"]
  ];
  List priceRangeOptions = [
    //Price range options [Visual Text, Option Saved in customiseSelected]
    ["£", 1],
    ["££", 2],
    ["£££", 3],
    ["££££", 4]
  ];
  bool isChecked = false; //Favourites selector
  double _currentMaxDeliveryFeeValue = 4;
  double _currentMinOrderPriceValue = 40;
  String? encodedCustomiseSelected;
  Map customiseSelected = {
    "sort": "default",
    "favourite": false,
    "price": [1, 2, 3, 4],
    "maxDelivery": 4.0,
    "minOrder": 40.0
  };

  @override
  void initState() {
    super.initState();
    _loadFilter();
  }

  _loadFilter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      encodedCustomiseSelected = prefs.getString('filtersort');
    });
    if (encodedCustomiseSelected != null) {
      customiseSelected = json.decode(encodedCustomiseSelected.toString());
      _currentMaxDeliveryFeeValue = customiseSelected["maxDelivery"];
      _currentMinOrderPriceValue = customiseSelected["minOrder"];
      isChecked = customiseSelected["favourite"];
    } else {
      customiseSelected = {
        "sort": "default",
        "favourite": false,
        "price": [1, 2, 3, 4],
        "maxDelivery": 4.0,
        "minOrder": 40.0
      };
      _currentMaxDeliveryFeeValue = 4;
      _currentMinOrderPriceValue = 40;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(left: 40, right: 20, top: 50),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Sort", style: Theme.of(context).textTheme.headline2),
                LayoutBuilder(builder: (context, constraints) {
                  if (customiseSelected["sort"] != "default" ||
                      customiseSelected["favourite"] != false ||
                      !customiseSelected["price"].contains(1) ||
                      !customiseSelected["price"].contains(2) ||
                      !customiseSelected["price"].contains(3) ||
                      !customiseSelected["price"].contains(4) ||
                      customiseSelected["maxDelivery"] != 4.0 ||
                      customiseSelected["minOrder"] != 40.0) {
                    return InkWell(
                        onTap: () {
                          setState(() {
                            customiseSelected = {
                              "sort": "default",
                              "favourite": false,
                              "price": [1, 2, 3, 4],
                              "maxDelivery": 4.0,
                              "minOrder": 40.0
                            };
                            _currentMaxDeliveryFeeValue = 4;
                            _currentMinOrderPriceValue = 40;
                            isChecked = false;
                          });
                        },
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 20),
                            child: Text(
                              "Clear all",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(
                                      color:
                                          Theme.of(context).colorScheme.error),
                            )));
                  } else {
                    return InkWell(
                        onTap: () {
                          setState(() {
                            customiseSelected = {
                              "sort": "default",
                              "favourite": false,
                              "price": [1, 2, 3, 4],
                              "maxDelivery": 4.0,
                              "minOrder": 40.0
                            };
                            _currentMaxDeliveryFeeValue = 4;
                            _currentMinOrderPriceValue = 40;
                          });
                        },
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 20),
                            child: Text(
                              "Clear all",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error
                                          .withOpacity(0.1)),
                            )));
                  }
                })
              ])),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(
              height: 20,
            ),
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
              height: 40,
            ),
            Text("Filter", style: Theme.of(context).textTheme.headline2),
            const SizedBox(
              height: 20,
            ),
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
                  contentPadding: const EdgeInsets.all(0),
                  value: isChecked,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (newValue) {
                    setState(() {
                      isChecked = !isChecked;
                    });
                    if (isChecked) {
                      customiseSelected["favourite"] = true;
                    } else {
                      customiseSelected["favourite"] = false;
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
                padding: const EdgeInsets.symmetric(horizontal: 10),
                color: Theme.of(context).colorScheme.onSurface,
                height: 70,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: priceRangeOptions.length, //For each restaurant
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 10),
                          child: SizedBox(
                              width: 70,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    side: customiseSelected["price"].contains(
                                            priceRangeOptions[index][1])
                                        ? BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 2)
                                        : BorderSide.none,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.onSurface,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 10)),
                                onPressed: () {
                                  if (customiseSelected["price"]
                                      .contains(priceRangeOptions[index][1])) {
                                    setState(() {
                                      customiseSelected["price"]
                                          .remove(priceRangeOptions[index][1]);
                                    });
                                  } else {
                                    setState(() {
                                      customiseSelected["price"]
                                          .add(priceRangeOptions[index][1]);
                                    });
                                  }
                                },
                                child: Text(
                                  priceRangeOptions[index][0],
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                        color: customiseSelected["price"]
                                                .contains(
                                                    priceRangeOptions[index][1])
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context)
                                                .textTheme
                                                .headline6
                                                ?.color,
                                      ),
                                ),
                              )));
                    })),
            const SizedBox(
              height: 40,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Max Delivery Fee",
                  style: Theme.of(context).textTheme.headline3),
              LayoutBuilder(builder: (context, constraints) {
                if (_currentMaxDeliveryFeeValue == 0) {
                  return const Text("FREE");
                } else if (_currentMaxDeliveryFeeValue == 4) {
                  return const Text("£4.00+");
                } else {
                  return Text("£${_currentMaxDeliveryFeeValue}0");
                }
              })
            ]),
            const SizedBox(
              height: 20,
            ),
            Slider(
              value: _currentMaxDeliveryFeeValue,
              max: 4,
              min: 0,
              thumbColor: Theme.of(context).primaryColor,
              activeColor: Theme.of(context).primaryColor,
              inactiveColor:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.2),
              divisions: 4,
              onChanged: (double value) {
                setState(() {
                  _currentMaxDeliveryFeeValue = value;
                });
                customiseSelected["maxDelivery"] = _currentMaxDeliveryFeeValue;
              },
            ),
            const SizedBox(
              height: 40,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Min Order Price",
                  style: Theme.of(context).textTheme.headline3),
              LayoutBuilder(builder: (context, constraints) {
                if (_currentMinOrderPriceValue == 0) {
                  return const Text("None");
                } else if (_currentMinOrderPriceValue == 40) {
                  return const Text("£40.00+");
                } else {
                  return Text("£${_currentMinOrderPriceValue}0");
                }
              })
            ]),
            const SizedBox(
              height: 20,
            ),
            Slider(
              value: _currentMinOrderPriceValue,
              max: 40,
              min: 0,
              thumbColor: Theme.of(context).primaryColor,
              activeColor: Theme.of(context).primaryColor,
              inactiveColor:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.2),
              divisions: 4,
              onChanged: (double value) {
                setState(() {
                  _currentMinOrderPriceValue = value;
                });
                customiseSelected["minOrder"] = _currentMinOrderPriceValue;
              },
            ),
            const SizedBox(
              height: 40,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  String encodedCustomiseSelected =
                      json.encode(customiseSelected);
                  await prefs.setString('filtersort', encodedCustomiseSelected);
                  setState(() {
                    Navigator.of(context).pop();
                  });
                },
                child: const Text("Save"))
          ])),
      const SizedBox(
        height: 40,
      ),
    ])));
  }
}

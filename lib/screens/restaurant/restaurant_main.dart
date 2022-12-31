import 'package:alleat/screens/restaurant/restaurant_customise.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as converty;
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantMain extends StatefulWidget {
  final String resid;
  final String resname;
  final String reslogo;
  final String resbanner;
  final String resdistance;
  final String resdelivery;
  final String resordermin;

  const RestaurantMain(
      //Get restaurant info from the restaurant list widget (passed from the container)
      {
    Key? key,
    required this.resid,
    required this.resname,
    required this.reslogo,
    required this.resbanner,
    required this.resdistance,
    required this.resdelivery,
    required this.resordermin,
  }) : super(key: key);

  @override
  State<RestaurantMain> createState() => _RestaurantMainState();
}

class _RestaurantMainState extends State<RestaurantMain> {
  Future<List> getMenuCategories() async {
    String phpurl =
        "https://alleat.cpur.net/query/restaurantmenucategories.php"; //Get the list of menu categories associated with the restaurant id
    try {
      var res = await http.post(Uri.parse(phpurl), body: {
        "restaurantid": widget.resid,
      });
      if (res.statusCode == 200) {
        //If successfully sent
        var data = converty.json.decode(res.body); //Decode to array
        if (data["error"]) {
          //If failed to query
          List error = [
            {
              "error": "true",
              "restaurantcategories": "[]"
            } //Return no menu categories
          ];
          return error;
        } else {
          List listdata = [data];
          return listdata;
        }
      } else {
        List error = [
          {"error": "true", "restaurantcategories": "[]"}
        ];
        return error;
      }
    } catch (e) {
      List<Map<String, String>> error = [
        {"error": "true", "restaurantcategories": "[]"}
      ];
      return error;
    }
  }

  Future<String> favouriteRestaurant(restaurantID, action) async {
    String phpurl =
        "https://alleat.cpur.net/query/favouriterestaurant.php"; //Action of favourite/unfavourite restaurant by id (Unused in this version)
    final prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('email');

    try {
      var res = await http.post(Uri.parse(phpurl), body: {
        "action": action.toString(),
        "profileemail": email.toString(),
        "restaurantid": restaurantID,
      });
      if (res.statusCode == 200) {
        var data = converty.json.decode(res.body); //Decode to array
        if (data["error"]) {
          return "failed";
        } else {
          getFavourites();
          return "success";
        }
      } else {
        return "failed";
      }
    } catch (e) {
      return "failed";
    }
  }

  Future<List> getFavourites() async {
    String phpurl =
        "https://alleat.cpur.net/query/favouriterestaurantlist.php"; //Get favourite restaurant list associated with email of profile (unused in this version)
    final prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('email');
    try {
      var res = await http.post(Uri.parse(phpurl), body: {
        "profileemail": email.toString(),
      });
      if (res.statusCode == 200) {
        var data = converty.json.decode(res.body); //Decode to array
        if (data["error"]) {
          List error = [
            {"error": "true", "favouriterestaurants": "[]"}
          ];
          return error;
        } else {
          List listdata = [data];
          return listdata;
        }
      } else {
        List error = [
          {"error": "true", "favouriterestaurants": "[]"}
        ];
        return error;
      }
    } catch (e) {
      List<Map<String, String>> error = [
        {"error": "true", "favouriterestaurants": "[]"}
      ];
      return error;
    }
  }

  Future<List> getMenuItems(categoryid) async {
    String phpurl =
        "https://alleat.cpur.net/query/restaurantmenuitems.php"; //Get list of menu items, with the inforamtion associated with it. Grabs using the category id it falls under
    try {
      var res = await http.post(Uri.parse(phpurl), body: {
        "categoryid": categoryid,
      });
      if (res.statusCode == 200) {
        //If fails to send data
        var data = converty.json.decode(res.body); //Decode to array
        if (data["error"]) {
          //If fails the query
          List error = [
            {"error": "true", "menuitems": "[]"} //Send nothing
          ];
          return error;
        } else {
          List listdata = [
            data
          ]; //Send back the list of items associated with the category
          return listdata;
        }
      } else {
        List error = [
          {"error": "true", "menuitems": "[]"}
        ];
        return error;
      }
    } catch (e) {
      List error = [
        {"error": "true", "menuitems": "[]"}
      ];
      return error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            //Make page scrollable
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Stack(children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 240,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fitWidth,
              image: NetworkImage(widget.resbanner),
            ),
          ),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 215),
              width: double.infinity,
              height: 30,
              decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20))),
            )),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                margin: const EdgeInsets.only(top: 180),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).backgroundColor,
                ))),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                margin: const EdgeInsets.only(top: 185),
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(widget.reslogo.toString()),
                  ),
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.onSurface,
                ))),
        SafeArea(
            child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  margin: const EdgeInsets.only(top: 20, left: 20),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: Theme.of(context).colorScheme.onBackground,
                    size: 35,
                  ),
                ))),
        Align(
            alignment: Alignment.topRight,
            child: SafeArea(
                child: InkWell(
                    child: Container(
              margin: const EdgeInsets.only(top: 20, right: 80),
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
              child: Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.onBackground,
                size: 30,
              ),
            )))),
        FutureBuilder<List>(
            //Get favourites list from future
            future: getFavourites(),
            builder: ((context, snapshot) {
              if (!snapshot.hasData) {
                //While no data recieved, show loading bar
                return SafeArea(
                    child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                            margin: const EdgeInsets.only(top: 20, right: 20),
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.8),
                            ),
                            child: Icon(
                              Icons.cached,
                              color: Theme.of(context).colorScheme.onBackground,
                            ))));
              } else if (snapshot.hasError) {
                return SafeArea(
                    child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                            margin: const EdgeInsets.only(top: 20, right: 20),
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.8),
                            ),
                            child: Icon(
                              Icons.error,
                              color: Theme.of(context).colorScheme.error,
                            ))));
              } else {
                //If data recieved
                List restaurantFavourites = snapshot.data ?? [];
                if (restaurantFavourites[0]["error"] == true) {
                  return SafeArea(
                      child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                              margin: const EdgeInsets.only(top: 20, right: 20),
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.8),
                              ),
                              child: Icon(
                                Icons.error,
                                color: Theme.of(context).colorScheme.error,
                              ))));
                } else {
                  return SafeArea(
                      child: Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                              onTap: () {
                                if (restaurantFavourites[0]["restaurantids"]
                                    .contains(widget.resid)) {
                                  favouriteRestaurant(
                                      widget.resid.toString(), "unfavourite");
                                  setState(() {
                                    getFavourites();
                                  });
                                } else {
                                  favouriteRestaurant(
                                      widget.resid.toString(), "favourite");
                                  setState(() {
                                    getFavourites();
                                  });
                                }
                              },
                              child: Container(
                                  margin:
                                      const EdgeInsets.only(top: 20, right: 20),
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.8),
                                  ),
                                  child: restaurantFavourites[0]
                                              ["restaurantids"]
                                          .contains(widget.resid)
                                      ? Icon(Icons.favorite,
                                          size: 30, // ? = favourited
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary)
                                      : Icon(
                                          // : = unfavourited
                                          Icons.favorite_border_outlined,
                                          size: 30,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground)))));
                }
              }
            }))
      ]),
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: Container(
                        padding: const EdgeInsets.only(right: 13.0),
                        child: Text(
                          widget.resname,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline3,
                        ))),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      "N/A",
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
                alignment: Alignment.topLeft,
                child: Wrap(
                  children: [
                    Text("${widget.resdistance} km away",
                        style: Theme.of(context).textTheme.bodyText1),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      "·",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                        (widget.resdelivery == "0.00")
                            ? "Free Delivery"
                            : "£${widget.resdelivery} Delivery",
                        style: Theme.of(context).textTheme.bodyText1),
                    Text(
                      "·",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                        (widget.resordermin == "0")
                            ? "No Mimimum Order"
                            : "£${widget.resordermin} Order Minimum",
                        style: Theme.of(context).textTheme.bodyText1),
                  ],
                )),
          ])),
      FutureBuilder<List>(
          //Checks for updates in the restaurant menu category
          future: getMenuCategories(),
          builder: ((context, snapshot) {
            if (!snapshot.hasData) {
              //If no data has been recieved, show loading bar
              return LinearProgressIndicator(
                  color: Theme.of(context).primaryColor,
                  backgroundColor: const Color.fromARGB(0, 235, 224, 255));
            }
            if (snapshot.hasError) {
              //If there is an error, grabbing data, show error
              return const Text("An Error occured. Please try again");
            } else {
              //If the data has been recieved
              List restaurantcategories = snapshot.data ??
                  []; //Categories data associated with restaurantcategories
              if (restaurantcategories[0]["error"] == true) {
                return Text(
                  "Failed to get restaurant categories",
                  style: Theme.of(context).textTheme.headline6,
                );
              } else {
                return ListView.builder(
                    //For each category
                    physics:
                        const NeverScrollableScrollPhysics(), //Disable scrolling. Scroll with whole page
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: restaurantcategories[0]["restaurantcategories"]
                        .length, //For each restaurant
                    itemBuilder: (context, index) {
                      return LayoutBuilder(builder: (context, constraints) {
                        if (restaurantcategories[0]["restaurantcategories"]
                            .isEmpty) {
                          //If there is no categories, display menu unavailable
                          return const Text("Menu unavailable");
                        } else {
                          //If there are categories
                          return Column(children: [
                            //Add text of category name
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 30, top: 50, right: 10, bottom: 10),
                              child: Text(
                                  restaurantcategories[0]
                                      ["restaurantcategories"][index][0],
                                  style: Theme.of(context).textTheme.headline3),
                            ),
                            FutureBuilder<List>(
                                //For each category, use a future to get the list of items
                                future: getMenuItems(restaurantcategories[0]
                                    ["restaurantcategories"][index][1]),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    //While no data recieved, show loading bar
                                    return LinearProgressIndicator(
                                        color: Theme.of(context).primaryColor,
                                        backgroundColor: const Color.fromARGB(
                                            0, 235, 224, 255));
                                  }
                                  if (snapshot.hasError) {
                                    //If there is an error, show failed to get items
                                    return const Text("Failed to get items");
                                  } else {
                                    //List of items for category
                                    List restaurantitems = snapshot.data ??
                                        []; //Get data from Future

                                    if (restaurantitems[0]["menuitems"]
                                        .isEmpty) {
                                      return Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 30, horizontal: 20),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface),
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 30),
                                        child: Text(
                                          "Oh no! There are no items found under this category.",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6,
                                        ),
                                      );
                                    } else {
                                      return ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          itemCount: (restaurantitems[
                                                      0] //For each item, create a container
                                                  ["menuitems"]
                                              .length), //For each restaurant
                                          itemBuilder: (context, index) {
                                            return LayoutBuilder(builder:
                                                (context, constraints) {
                                              // If there is items to display
                                              return InkWell(
                                                  //Clickable items
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => RestaurantItemCustomisePage(
                                                                reslogo: widget
                                                                    .reslogo,
                                                                itemid: restaurantitems[0]["menuitems"]
                                                                    [index][0],
                                                                foodcategory: restaurantitems[0]
                                                                        ["menuitems"]
                                                                    [index][1],
                                                                subfoodcategory: restaurantitems[0]
                                                                        ["menuitems"]
                                                                    [index][2],
                                                                itemname: restaurantitems[0]
                                                                        ["menuitems"]
                                                                    [index][3],
                                                                description: restaurantitems[0]
                                                                    ["menuitems"][index][4],
                                                                price: restaurantitems[0]["menuitems"][index][5],
                                                                itemimage: restaurantitems[0]["menuitems"][index][6])));
                                                  },
                                                  child: Container(
                                                      //Create clickable container
                                                      width: double.infinity,
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 10,
                                                              top: 10,
                                                              bottom: 10),
                                                      child: Row(
                                                        //Create a row containing item image, name and price
                                                        children: [
                                                          Container(
                                                            width: 80,
                                                            height: 80,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            5)),
                                                                image: DecorationImage(
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    image: NetworkImage(restaurantitems[0]["menuitems"]
                                                                            [
                                                                            index][6]
                                                                        .toString()))),
                                                          ),
                                                          const SizedBox(
                                                              width: 15),
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  restaurantitems[0]
                                                                              [
                                                                              "menuitems"]
                                                                          [
                                                                          index][3]
                                                                      .toString(),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .headline6!
                                                                      .copyWith(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onBackground),
                                                                ),
                                                                Text(
                                                                  restaurantitems[0]
                                                                              [
                                                                              "menuitems"]
                                                                          [
                                                                          index][4]
                                                                      .toString(),
                                                                  maxLines: 3,
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyText2!
                                                                      .copyWith(
                                                                          color: Theme.of(context)
                                                                              .textTheme
                                                                              .headline5!
                                                                              .color,
                                                                          fontSize:
                                                                              14),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .clip,
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 15),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "£",
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .headline6!
                                                                    .copyWith(
                                                                        color: Theme.of(context)
                                                                            .primaryColor),
                                                              ),
                                                              const SizedBox(
                                                                  width: 2),
                                                              Text(
                                                                  restaurantitems[0]["menuitems"]
                                                                              [
                                                                              index]
                                                                          [5]
                                                                      .toString(),
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .headline6!
                                                                      .copyWith(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onBackground))
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                        ],
                                                      )));
                                            });
                                          });
                                    }
                                  }
                                })
                          ]);
                        }
                      });
                    });
              }
            }
          }))
    ])));
  }
}

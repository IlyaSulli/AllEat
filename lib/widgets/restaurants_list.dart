import 'package:alleat/screens/restaurant/restaurant_main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class RestaurantList extends StatefulWidget {
  const RestaurantList({Key? key}) : super(key: key);

  @override
  State<RestaurantList> createState() => _RestaurantListState();
}

class _RestaurantListState extends State<RestaurantList> {
  late bool error, sending, success, serverOffline;
  late String msg;
  Map metadataTemp = {
    "error": false,
    "sort": "default",
    "favourite": false,
    "price": [1, 2, 3, 4],
    "maxDelivery": 4.0,
    "minOrder": 40.0,
    "latitude": 0.0,
    "longitude": 0.0
  };

  @override
  void initState() {
    //Default values
    error = false;
    sending = false;
    success = false;
    msg = "";
    super.initState();
  }

  Future<Map> getUserMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    final String? filterSortEncoded = prefs.getString('filtersort');
    final double? locationLatitude = prefs.getDouble('locationLatitude');
    final double? locationLongitude = prefs.getDouble('locationLongitude');
    final String? profileid = prefs.getString("serverprofileid");
    metadataTemp["profileid"] = profileid;
    if (filterSortEncoded != null) {
      Map filterSort = json.decode(filterSortEncoded);
      metadataTemp["sort"] = filterSort["sort"];
      metadataTemp["favourite"] = filterSort["favourite"];
      metadataTemp["price"] = filterSort["price"];
      metadataTemp["maxDelivery"] = filterSort["maxDelivery"];
      metadataTemp["minOrder"] = filterSort["minOrder"];
    }
    if (locationLatitude == null ||
        locationLatitude == 0 ||
        locationLongitude == null ||
        locationLongitude == 0) {
      metadataTemp["error"] = true;
      return metadataTemp;
    } else {
      metadataTemp["latitude"] = locationLatitude;
      metadataTemp["longitude"] = locationLongitude;
      return metadataTemp;
    }
  }

  Future<List> getRestaurants() async {
    Map metadata = await getUserMetadata();

    if (metadata["error"] != true) {
      metadata.remove("error");
      switch (metadata["favourite"]) {
        case (true):
          metadata.remove("favourite");
          metadata["favourite"] = "true";
          break;
        case (false):
          metadata.remove("favourite");
          metadata["favourite"] = "false";
          break;
      }

      metadata["price"] = metadata["price"].join(",");
      metadata["maxDelivery"] = metadata["maxDelivery"].toString();
      metadata["profileid"] = metadata["profileid"].toString();
      metadata["minOrder"] = metadata["minOrder"].toString();
      metadata["latitude"] = metadata["latitude"].toString();
      metadata["longitude"] = metadata["longitude"].toString();
      String phpurl =
          "https://alleat.cpur.net/query/restaurantlist.php"; //Get restaurant list
      try {
        var res = await http.post(Uri.parse(phpurl), body: metadata);
        if (res.statusCode == 200) {
          //If sends successfully
          var data = json.decode(res.body); //Decode to array
          print(data);
          if (data["error"]) {
            //If fails to perform query
            List error = [
              {
                "error": true,
                "message": "Server Response: ${data["message"]}",
                "restaurants": "[]"
              } //Send blank list of restaurants
            ];
            return error;
          } else {
            List listdata = await getDistance(data);
            if (listdata[0] == false) {
              List error = [
                {
                  "error": true,
                  "message":
                      "Failed to get Location. \nTry changing your destination address",
                  "restaurants": "[]"
                } //Send blank list of restaurants
              ];
              return error;
            } else {
              return [listdata[1]];
            }
            //If success, send the list of restaurants back
          }
        } else {
          List error = [
            {
              "error": true,
              "message":
                  "Error ${res.statusCode}: Failed to connect to server.",
              "restaurants": "[]"
            }
          ];
          return error;
        }
      } catch (e) {
        List error = [
          {
            "error": true,
            "message":
                "An unexpected error occured.\n Try reopening the app. \n\n ERROR: $e",
            "restaurants": "[]"
          }
        ];
        return error;
      }
    } else {
      List error = [
        {
          "error": true,
          "message":
              "Failed to get Location. \nTry changing your destination address",
          "restaurants": "[]"
        } //Send blank list of restaurants
      ];
      return error;
    }
  }

  Future<List> getDistance(restaurantdata) async {
    var p = 0.017453292519943295; //Convert constant from degrees to radians
    final prefs = await SharedPreferences.getInstance();
    final double? savedLocationLat = prefs.getDouble('locationLatitude'); //lat2
    final double? savedLocationLng =
        prefs.getDouble('locationLongitude'); //lng2
    if (savedLocationLat != null && savedLocationLng != null) {
      for (var i = 0; i < restaurantdata["restaurants"].length; i++) {
        double latRestaurant =
            double.parse(restaurantdata["restaurants"][i][4]); //lat1
        double lngRestaurant =
            double.parse(restaurantdata["restaurants"][i][5]); //lng1
        double distance = 12742 *
            asin(sqrt(0.5 -
                cos((savedLocationLat - latRestaurant) * p) / 2 +
                cos(latRestaurant * p) *
                    cos(savedLocationLat * p) *
                    (1 - cos((savedLocationLng - lngRestaurant) * p)) /
                    2));
        restaurantdata["restaurants"][i].add(distance);
      }
      return [true, restaurantdata];
    } else {
      return [false, restaurantdata];
    }
  }

  Future<String> favouriteRestaurant(restaurantID, action) async {
    String phpurl =
        "https://alleat.cpur.net/query/favouriterestaurant.php"; //Favourite & unfavourite restaurant for sepcific profile using their email
    final prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('email');
    try {
      var res = await http.post(Uri.parse(phpurl), body: {
        "action": action
            .toString(), //Action determines if it will favourite or unfavourite depending on input
        "profileemail": email,
        "restaurantid": restaurantID,
      });
      if (res.statusCode == 200) {
        //On successfull send
        var data = json.decode(res.body); //Decode to array
        if (data["error"]) {
          return "failed";
        } else {
          getFavourites(); //get favourite restaurant list
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
        "https://alleat.cpur.net/query/favouriterestaurantlist.php"; //Get favourite restaurant ids using profile email
    final prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('email');
    try {
      var res = await http.post(Uri.parse(phpurl), body: {
        "profileemail": email.toString(),
      });
      if (res.statusCode == 200) {
        //If successfull send data
        var data = json.decode(res.body); //Decode to array
        if (data["error"]) {
          //If error querying data
          List error = [
            {
              "error": true,
              "favouriterestaurants": "[]"
            } //Send empty favourite restaurant ids list
          ];
          return error;
        } else {
          //If successful query
          List listdata = [data]; //Send list of restaurant ids back
          return listdata;
        }
      } else {
        List error = [
          {"error": true, "favouriterestaurants": "[]"}
        ];
        return error;
      }
    } catch (e) {
      List error = [
        {"error": true, "favouriterestaurants": "[]"}
      ];
      return error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      //Get list of restaurants data from future (rebuild on change of data)
      future: getRestaurants(),
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          //If recieved data
          List restaurantsdata =
              snapshot.data ?? []; //Data stored in restaurantsdata
          if (restaurantsdata[0]["error"] == true) {
            return Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 10, bottom: 10),
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        color: Theme.of(context).colorScheme.onSurface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(
                                0, 10), // changes position of shadow
                          ),
                        ]),
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: SizedBox(
                            width: double.infinity,
                            child: Center(
                                child: Column(children: [
                              Text(
                                "${restaurantsdata[0]["message"]}",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      getRestaurants();
                                    });
                                  },
                                  child: const Text("Retry"))
                            ]))),
                      )
                    ])));
          } else {
            try {
              List restaurants = restaurantsdata[0]["restaurants"];
              return FutureBuilder<List>(
                //Get favourites list from future
                future: getFavourites(),
                builder: ((context, snapshot) {
                  if (!snapshot.hasData) {
                    //While no data recieved, show loading bar
                    return const LinearProgressIndicator(
                        color: Color(0xff4100C4),
                        backgroundColor: Color(0xffEBE0FF));
                  } else {
                    //If data recieved
                    List restaurantFavourites = snapshot.data ?? [];
                    return ListView.builder(
                        //Show number of containers depending on number of restaurants
                        physics:
                            const NeverScrollableScrollPhysics(), //Dont allow scrolling (Done by main page)
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: restaurantsdata[0]["restaurants"]
                            .length, //For each restaurant
                        itemBuilder: (context, index) {
                          return Center(child:
                              LayoutBuilder(builder: (context, constraints) {
                            if (restaurants.isEmpty) {
                              //If there are no restaurants show container saying no restaurants

                              return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, top: 10, bottom: 10),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(20)),
                                          color: const Color(0xffffffff),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              spreadRadius: 2,
                                              blurRadius: 10,
                                              offset: const Offset(0,
                                                  10), // changes position of shadow
                                            ),
                                          ]),
                                      child: Column(children: const [
                                        Padding(
                                          padding: EdgeInsets.all(30),
                                          child: SizedBox(
                                              width: double.infinity,
                                              child: Center(
                                                  child: Text(
                                                      "No restaurants found"))), //Display no restaurants text
                                        )
                                      ])));
                            } else {
                              // If there is restaurant
                              return InkWell(
                                  //Create clickable container
                                  onTap: () {
                                    List restaurantinfodata = restaurantsdata[0]
                                        ["restaurants"][index];
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => //On tap, send restaurant data associated with container to main page and go to that new screen
                                                  RestaurantMain(
                                                      resid:
                                                          restaurantinfodata[0],
                                                      resname:
                                                          restaurantinfodata[1],
                                                      reslogo:
                                                          restaurantinfodata[2],
                                                      resbanner:
                                                          restaurantinfodata[3],
                                                      resdistance:
                                                          (restaurantsdata[0][
                                                                      "restaurants"]
                                                                  [index][6])
                                                              .toStringAsFixed(
                                                                  1)),
                                        ));
                                  },
                                  child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 20),
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                      child: Stack(
                                        children: [
                                          Container(
                                            //Container filled with restaurant banner
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 150,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                              ),
                                              image: DecorationImage(
                                                fit: BoxFit.fitWidth,
                                                image: NetworkImage(
                                                    restaurants[index][3]
                                                        .toString()),
                                              ),
                                            ),
                                          ),
                                          Align(
                                              alignment: Alignment.topCenter,
                                              child: Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 110),
                                                  width: 70,
                                                  height: 70,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                  ))),
                                          Align(
                                              alignment: Alignment.topCenter,
                                              child: Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 115),
                                                  width: 60,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: NetworkImage(
                                                          restaurants[index][2]
                                                              .toString()),
                                                    ),
                                                    shape: BoxShape.circle,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                  ))),
                                          Align(
                                              alignment: Alignment.topRight,
                                              child: InkWell(
                                                  onTap: () {
                                                    if (restaurantFavourites[0]
                                                            ["restaurantids"]
                                                        .contains(
                                                            restaurants[index]
                                                                    [0]
                                                                .toString())) {
                                                      favouriteRestaurant(
                                                          restaurants[index][0]
                                                              .toString(),
                                                          "unfavourite");
                                                      setState(() {
                                                        getFavourites();
                                                      });
                                                    } else {
                                                      favouriteRestaurant(
                                                          restaurants[index][0]
                                                              .toString(),
                                                          "favourite");
                                                      setState(() {
                                                        getFavourites();
                                                      });
                                                    }
                                                  },
                                                  child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 10,
                                                              right: 10),
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
                                                                  [
                                                                  "restaurantids"]
                                                              .contains(
                                                                  restaurants[index]
                                                                          [0]
                                                                      .toString())
                                                          ? Icon(Icons.favorite,
                                                              size:
                                                                  30, // ? = favourited
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .secondary)
                                                          : Icon(
                                                              // : = unfavourited
                                                              Icons
                                                                  .favorite_border_outlined,
                                                              size: 30,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onBackground)))),
                                          Align(
                                              alignment: Alignment.bottomLeft,
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 190,
                                                          left: 20,
                                                          right: 20),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Flexible(
                                                              child: Container(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      right:
                                                                          13.0),
                                                                  child: Text(
                                                                    restaurants[
                                                                        index][1],
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .headline4,
                                                                  ))),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                Icons.star,
                                                                size: 20,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                "N/A",
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyText1,
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Row(
                                                        children: [
                                                          Text(
                                                              "${(restaurantsdata[0]["restaurants"][index][6]).toStringAsFixed(1)} km away",
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyText1!
                                                                  .copyWith(
                                                                      fontSize:
                                                                          12)),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            "·",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyText1!
                                                                .copyWith(
                                                                    fontSize:
                                                                        12),
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text("£N/A Delivery",
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyText1!
                                                                  .copyWith(
                                                                      fontSize:
                                                                          12)),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 20),
                                                    ],
                                                  )))
                                        ],
                                      )));
                            }
                          }));
                        });
                  }
                }),
              );
            } catch (e) {
              return Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 10, bottom: 10),
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          color: Theme.of(context).colorScheme.onSurface,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(
                                  0, 10), // changes position of shadow
                            ),
                          ]),
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.all(30),
                          child: SizedBox(
                              width: double.infinity,
                              child: Center(
                                  child: Column(children: [
                                const Text(
                                  "An unexpected error occured. \nPlease try again",
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        getRestaurants();
                                      });
                                    },
                                    child: const Text("Retry"))
                              ]))),
                        )
                      ])));
            }
          }
        } else {
          return const LinearProgressIndicator(
              color: Color(0xff4100C4),
              backgroundColor: Color.fromARGB(0, 235, 224, 255));
        }
      }),
    );
  }
}

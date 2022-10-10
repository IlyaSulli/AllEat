import 'package:alleat/services/sqlite_service.dart';
import 'package:alleat/widgets/restaurant/restaurantmain.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as converty;

class RestaurantList extends StatefulWidget {
  const RestaurantList({Key? key}) : super(key: key);

  @override
  State<RestaurantList> createState() => _RestaurantListState();
}

class _RestaurantListState extends State<RestaurantList> {
  late bool error, sending, success, serverOffline;
  late String msg;

  @override
  void initState() {
    //Default values
    error = false;
    sending = false;
    success = false;
    msg = "";
    super.initState();
  }

  Future<List> getRestaurants() async {
    String phpurl =
        "https://alleat.cpur.net/query/restaurantlist.php"; //Get restaurant list
    try {
      var res = await http.post(Uri.parse(phpurl), body: {
        "sort": "id", //Send sort type (Currently permanently by id)
      });
      if (res.statusCode == 200) {
        //If sends successfully
        var data = converty.json.decode(res.body); //Decode to array
        if (data["error"]) {
          //If fails to perform query
          List error = [
            {
              "error": "true",
              "restaurants": "[]"
            } //Send blank list of restaurants
          ];
          return error;
        } else {
          List listdata = [
            data
          ]; //If success, send the list of restaurants back
          return listdata;
        }
      } else {
        List error = [
          {"error": "true", "restaurants": "[]"}
        ];
        return error;
      }
    } catch (e) {
      List<Map<String, String>> error = [
        {"error": "true", "restaurants": "[]"}
      ];
      return error;
    }
  }

  Future<String> favouriteRestaurant(restaurantID, action) async {
    String phpurl =
        "https://alleat.cpur.net/query/favouriterestaurant.php"; //Favourite & unfavourite restaurant for sepcific profile using their email
    var profile = await SQLiteLocalDB.getProfileSelected();
    String email = profile[0]["email"].toString();

    try {
      var res = await http.post(Uri.parse(phpurl), body: {
        "action": action
            .toString(), //Action determines if it will favourite or unfavourite depending on input
        "profileemail": email.toString(),
        "restaurantid": restaurantID,
      });
      if (res.statusCode == 200) {
        //On successfull send
        var data = converty.json.decode(res.body); //Decode to array
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
    var profile = await SQLiteLocalDB.getProfileSelected();
    String email = profile[0]["email"].toString();
    try {
      var res = await http.post(Uri.parse(phpurl), body: {
        "profileemail": email.toString(),
      });
      if (res.statusCode == 200) {
        //If successfull send data
        var data = converty.json.decode(res.body); //Decode to array
        if (data["error"]) {
          //If error querying data
          List error = [
            {
              "error": "true",
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      //Get list of restaurants data from future (rebuild on change of data)
      future: getRestaurants(),
      builder: ((context, snapshot) {
        List restaurantsdata =
            snapshot.data ?? []; //Data stored in restaurantsdata

        if (!snapshot.hasData) {
          //While no data recieved, show loading bar
          return const LinearProgressIndicator(
              color: Color(0xff4100C4), backgroundColor: Color(0xffEBE0FF));
        } else {
          //If recieved data
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
                                  List restaurantinfodata =
                                      restaurantsdata[0]["restaurants"][index];
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder:
                                              (context) => //On tap, send restaurant data associated with container to main page and go to that new screen
                                                  RestaurantMainPage(
                                                    resid:
                                                        restaurantinfodata[0],
                                                    resname:
                                                        restaurantinfodata[1],
                                                    reslogo:
                                                        restaurantinfodata[2],
                                                    resbanner:
                                                        restaurantinfodata[3],
                                                  )));
                                },
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        top: 10,
                                        bottom: 10),
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
                                      child: Column(children: [
                                        //Main restaurant data here
                                        Padding(
                                            //Restaurant Banner
                                            padding: const EdgeInsets.all(10),
                                            child: Container(
                                              //Container filled with restaurant banner
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 150,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                                image: DecorationImage(
                                                  fit: BoxFit.fitWidth,
                                                  image: NetworkImage(
                                                      restaurants[index][3]
                                                          .toString()),
                                                ),
                                              ),
                                            )),
                                        Padding(
                                            //Restaurant logo, text and favourites button below restaurant banner
                                            padding: const EdgeInsets.only(
                                                left: 20,
                                                right: 30,
                                                bottom: 15,
                                                top: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    ClipOval(
                                                        //Restaurant logo
                                                        child: Image.network(
                                                            restaurants[index]
                                                                    [2]
                                                                .toString(),
                                                            height: 50,
                                                            width: 50)),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      //Restaurant Text
                                                      restaurants[index][1],
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                                IconButton(
                                                    //Favourites button
                                                    onPressed: () {
                                                      if (restaurantFavourites[
                                                                  0]
                                                              ["restaurantids"]
                                                          .contains(restaurants[
                                                                  index][0]
                                                              .toString())) {
                                                        favouriteRestaurant(
                                                            restaurants[index]
                                                                    [0]
                                                                .toString(),
                                                            "unfavourite");
                                                        setState(() {
                                                          getFavourites();
                                                        });
                                                      } else {
                                                        favouriteRestaurant(
                                                            restaurants[index]
                                                                    [0]
                                                                .toString(),
                                                            "favourite");
                                                        setState(() {
                                                          getFavourites();
                                                        });
                                                      }
                                                    },
                                                    icon: (restaurantFavourites[
                                                                    0][
                                                                "restaurantids"]
                                                            .contains(restaurants[
                                                                    index][0]
                                                                .toString()))
                                                        ? const Icon(
                                                            Icons
                                                                .favorite, // ? = favourited
                                                            color: Color(
                                                                0xff33C496))
                                                        : const Icon(
                                                            // : = unfavourited
                                                            Icons
                                                                .favorite_border_outlined,
                                                            color: Color(
                                                                0xff000000))),
                                              ],
                                            ))
                                      ]),
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
                        color: const Color(0xffffffff),
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
                              const Text("Error 400: Connection failed"),
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
      }),
    );
  }
}

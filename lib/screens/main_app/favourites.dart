import 'package:alleat/services/sqlite_service.dart';
import 'package:alleat/widgets/navigationbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as converty;

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({Key? key}) : super(key: key);

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
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

  Future<List> getFavouriteRestaurants() async {
    String phpurl =
        "https://alleat.cpur.net/query/favouriterestaurantdata.php"; //Get list of favourites associated with profile email
    var profile = await SQLiteLocalDB.getProfileSelected();
    String email = profile[0]["email"].toString();
    try {
      var res = await http.post(Uri.parse(phpurl), body: {
        "profileemail": email.toString(),
      });
      if (res.statusCode == 200) {
        var data = converty.json.decode(res.body); //Decode to array
        if (data["error"]) {
          //If there is an error, return blank retaurants
          List error = [
            {"error": "true", "restaurants": "[]"}
          ];
          return error;
        } else {
          //If there is not an error, send the data in a list
          List listdata = [data];
          return listdata;
        }
      } else {
        //If there is an error, return blank retaurants
        List error = [
          {"error": "true", "restaurants": "[]"}
        ];
        return error;
      }
    } catch (e) {
      //If there is an error, return blank retaurants
      List<Map<String, String>> error = [
        {"error": "true", "restaurants": "[]"}
      ];
      return error;
    }
  }

  Future<String> favouriteRestaurant(restaurantID, action) async {
    String phpurl =
        "https://alleat.cpur.net/query/favouriterestaurant.php"; //Favourite/unfavourite a restaurant using email as an identifier
    var profile = await SQLiteLocalDB.getProfileSelected();
    String email = profile[0]["email"].toString();

    try {
      var res = await http.post(Uri.parse(phpurl), body: {
        "action": action.toString(), // Favourite or unfavourite
        "profileemail": email
            .toString(), // Profile's email for identification of who's profile to modify
        "restaurantid": restaurantID,
      });
      if (res.statusCode == 200) {
        //On successfull send
        var data = converty.json.decode(res.body); //Decode to array
        if (data["error"]) {
          //If error querying
          return "failed";
        } else {
          //If success, request the favourites list
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
    String phpurl = "https://alleat.cpur.net/query/favouriterestaurantlist.php";
    var profile = await SQLiteLocalDB.getProfileSelected();
    String email = profile[0]["email"].toString();
    try {
      var res = await http.post(Uri.parse(phpurl), body: {
        //Get fav restaurants list associated with profile's email
        "profileemail": email.toString(),
      });
      if (res.statusCode == 200) {
        //On successfull send
        var data = converty.json.decode(res.body); //Decode to array
        if (data["error"]) {
          //If error querying
          List error = [
            {"error": "true", "favouriterestaurants": "[]"} //Return blank list
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //Create favourites screen
        appBar: AppBar(
          title: const Text('Favourites'),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back), //Back button
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Navigation()));
              }),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: FutureBuilder<List>(
          //Listen for changes to future (favourite restaurants list )
          future: getFavouriteRestaurants(),
          builder: ((context, snapshot) {
            List restaurantsdata =
                snapshot.data ?? []; //Save list to restaurant data
            if (!snapshot.hasData) {
              //If nothing is recieved then showing loading bar
              return const LinearProgressIndicator(
                  color: Color(0xff4100C4), backgroundColor: Color(0xffEBE0FF));
            } else {
              // If there is data
              try {
                //Try to show list
                List restaurants = restaurantsdata[0]["restaurants"];
                return FutureBuilder<List>(
                  //Get status of which restaurants is favourited
                  future: getFavourites(),
                  builder: ((context, snapshot) {
                    if (!snapshot.hasData) {
                      //If there is no data, show loading bar
                      return const LinearProgressIndicator(
                          color: Color(0xff4100C4),
                          backgroundColor: Color(0xffEBE0FF));
                    } else {
                      List restaurantFavourites = snapshot.data ??
                          []; //Save favourite restaurant list to restaurantFavourites

                      return ListView.builder(
                          //For each restaurant in list of favourites create a container
                          physics: const AlwaysScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: restaurantsdata[0]["restaurants"].length,
                          itemBuilder: (context, index) {
                            return Center(child:
                                LayoutBuilder(builder: (context, constraints) {
                              if (restaurants.isEmpty) {
                                //If there is no restaurants in the list then show container with text 'No restaurants'
                                return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        top: 10,
                                        bottom: 10),
                                    child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(20)),
                                            color: const Color(0xffffffff),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
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
                                                        "No restaurants found"))),
                                          )
                                        ])));
                              } else {
                                //If there is a list of restaurants in favourites
                                return Padding(
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
                                        Padding(
                                            //
                                            padding: const EdgeInsets.all(10),
                                            child: Container(
                                              //Container with the restaurant image contained in it
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
                                                //Main area of restaurant container, with logo, name and favourite button icon
                                                Row(
                                                  children: [
                                                    ClipOval(
                                                        //Circular restaurant logo
                                                        child: Image.network(
                                                            restaurants[index]
                                                                    [2]
                                                                .toString(),
                                                            height: 50,
                                                            width: 50)),
                                                    const SizedBox(
                                                      //Empty space
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      //Restaurant Name
                                                      restaurants[index][1],
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                                IconButton(
                                                    //Favourite icon
                                                    onPressed: () {
                                                      if (restaurantFavourites[
                                                                  0]
                                                              ["restaurantids"]
                                                          .contains(restaurants[
                                                                  index][0]
                                                              .toString())) {
                                                        //If the restaurant id is in the list of favourite restaurant list
                                                        favouriteRestaurant(
                                                            //Send unfavourite action to future
                                                            restaurants[index]
                                                                    [0]
                                                                .toString(),
                                                            "unfavourite");
                                                        setState(() {
                                                          getFavourites();
                                                        });
                                                      } else {
                                                        //If the restuarnt is not on the list of favourite restaurants list
                                                        favouriteRestaurant(
                                                            //Send the favourite action to future
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
                                                            // ? = favourited
                                                            Icons.favorite,
                                                            color: Color(
                                                                0xff33C496))
                                                        : const Icon(
                                                            // : = not favourited
                                                            Icons
                                                                .favorite_border_outlined,
                                                            color: Color(
                                                                0xff000000))),
                                              ],
                                            ))
                                      ]),
                                    ));
                              }
                            }));
                          });
                    }
                  }),
                );
              } catch (e) {
                //If there is an error, show box container that allows the user to try requesting the data again
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
                                          getFavouriteRestaurants();
                                        });
                                      },
                                      child: const Text("Retry"))
                                ]))),
                          )
                        ])));
              }
            }
          }),
        ));
  }
}

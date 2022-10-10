import 'package:alleat/services/sqlite_service.dart';
import 'package:alleat/widgets/restaurant/restaurantitemcustomise.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as converty;

class RestaurantMainPage extends StatefulWidget {
  final String resid;
  final String resname;
  final String reslogo;
  final String resbanner;

  const RestaurantMainPage(
      //Get restaurant info from the restuarant list widget (passed from the container)
      {Key? key,
      required this.resid,
      required this.resname,
      required this.reslogo,
      required this.resbanner})
      : super(key: key);

  @override
  State<RestaurantMainPage> createState() => _RestaurantMainPageState();
}

class _RestaurantMainPageState extends State<RestaurantMainPage> {
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
    var profile = await SQLiteLocalDB.getProfileSelected();
    String email = profile[0]["email"].toString();

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
    var profile = await SQLiteLocalDB.getProfileSelected();
    String email = profile[0]["email"].toString();
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
      List<Map<String, String>> error = [
        {"error": "true", "menuitems": "[]"}
      ];
      return error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: widget.resname, //Set appbar title to restaurant name
        home: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(widget.resname),
              leading: IconButton(
                  //Back button
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop()),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            body: SingleChildScrollView(
                //Make page scrollable
                child: Column(children: [
              Padding(
                  //Restaurant banner
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                      image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: NetworkImage(widget.resbanner),
                      ),
                    ),
                  )),
              Padding(
                  //Restaurant info (including logo and name)
                  padding: const EdgeInsets.only(
                      left: 20, right: 30, bottom: 15, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ClipOval(
                              //Restaurant logo
                              child: Image.network(widget.reslogo,
                                  height: 50, width: 50)),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            //Restaurant Name
                            widget.resname,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  )),
              FutureBuilder<List>(
                  //Checks for updates in the restaurant menu category
                  future: getMenuCategories(),
                  builder: ((context, snapshot) {
                    if (!snapshot.hasData) {
                      //If no data has been recieved, show loading bar
                      return const LinearProgressIndicator(
                          color: Color(0xff4100C4),
                          backgroundColor: Color(0xffEBE0FF));
                    }
                    if (snapshot.hasError) {
                      //If there is an error, grabbing data, show error
                      return const Text("An Error occured. Please try again");
                    } else {
                      //If the data has been recieved
                      List restaurantcategories = snapshot.data ??
                          []; //Categories data associated with restaurantcategories
                      return ListView.builder(
                          //For each category
                          physics:
                              const NeverScrollableScrollPhysics(), //Disable scrolling. Scroll with whole page
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: restaurantcategories[0]
                                  ["restaurantcategories"]
                              .length, //For each restaurant
                          itemBuilder: (context, index) {
                            return LayoutBuilder(
                                builder: (context, constraints) {
                              if (restaurantcategories[0]
                                      ["restaurantcategories"]
                                  .isEmpty) {
                                //If there is no categories, display menu unavailable
                                return const Text("Menu unavailable");
                              } else {
                                //If there are categories
                                return Column(children: [
                                  //Add text of category name
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30,
                                          top: 30,
                                          right: 10,
                                          bottom: 10),
                                      child: Text(
                                        restaurantcategories[0]
                                            ["restaurantcategories"][index][0],
                                        style: const TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.w500),
                                      )),
                                  FutureBuilder<List>(
                                      //For each category, use a future to get the list of items
                                      future: getMenuItems(
                                          restaurantcategories[0]
                                                  ["restaurantcategories"]
                                              [index][1]),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          //While no data recieved, show loading bar
                                          return const LinearProgressIndicator(
                                              color: Color(0xff4100C4),
                                              backgroundColor:
                                                  Color(0xffEBE0FF));
                                        }
                                        if (snapshot.hasError) {
                                          //If there is an error, show failed to get items
                                          return const Text(
                                              "Failed to get items");
                                        } else {
                                          //List of items for category
                                          List restaurantitems =
                                              snapshot.data ??
                                                  []; //Get data from Future
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
                                                  if (restaurantitems[0]
                                                          ["menuitems"]
                                                      .isEmpty) {
                                                    //If there is no items for a category
                                                    return const Text(
                                                        "No items found");
                                                  } else {
                                                    // If there is items to display
                                                    return InkWell(
                                                        //Clickable items
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => RestaurantItemCustomisePage(
                                                                      itemid: restaurantitems[0]["menuitems"][index]
                                                                          [0],
                                                                      foodcategory: restaurantitems[0]["menuitems"]
                                                                              [index]
                                                                          [1],
                                                                      subfoodcategory: restaurantitems[0]
                                                                              ["menuitems"][index]
                                                                          [2],
                                                                      itemname: restaurantitems[0]["menuitems"][index]
                                                                          [3],
                                                                      description: restaurantitems[0]
                                                                              ["menuitems"][index]
                                                                          [4],
                                                                      price: restaurantitems[0]
                                                                              ["menuitems"][index]
                                                                          [5],
                                                                      itemimage:
                                                                          restaurantitems[0]["menuitems"][index]
                                                                              [6])));
                                                        },
                                                        child: Container(
                                                            //Create clickable container
                                                            width: double
                                                                .infinity,
                                                            margin:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 10,
                                                                    right: 10,
                                                                    top: 5,
                                                                    bottom: 5),
                                                            color: const Color(
                                                                0xffffffff),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              //Create a row containing item image, name and price
                                                              children: [
                                                                Flexible(
                                                                    flex:
                                                                        4, // 4/13 of container for item image
                                                                    child: Padding(
                                                                        //Item Image

                                                                        padding: const EdgeInsets.all(10),
                                                                        child: Container(
                                                                          width:
                                                                              70,
                                                                          height:
                                                                              70,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                const BorderRadius.all(Radius.circular(10)),
                                                                            image:
                                                                                DecorationImage(
                                                                              fit: BoxFit.cover,
                                                                              image: NetworkImage(restaurantitems[0]["menuitems"][index][6].toString()),
                                                                            ),
                                                                          ),
                                                                        ))),
                                                                Flexible(
                                                                    flex:
                                                                        6, // 6/13 of container for item name
                                                                    child: Align(
                                                                        alignment: Alignment.center,
                                                                        child: Padding(
                                                                            padding: const EdgeInsets.only(top: 10, bottom: 10, left: 5),
                                                                            child: Column(children: [
                                                                              //Item Name
                                                                              Text(
                                                                                restaurantitems[0]["menuitems"][index][3].toString(),
                                                                                textAlign: TextAlign.center,
                                                                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                                                              ),
                                                                              const SizedBox(height: 10),
                                                                              Text(overflow: TextOverflow.ellipsis, restaurantitems[0]["menuitems"][index][4].toString(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12))
                                                                            ])))),
                                                                Flexible(
                                                                    flex: 3,
                                                                    child: Align(
                                                                        alignment: Alignment.centerRight,
                                                                        child: Padding(
                                                                            padding: const EdgeInsets.only(left: 10, right: 20),
                                                                            child: Text(
                                                                              "£${restaurantitems[0]["menuitems"][index][5]}",
                                                                              textAlign: TextAlign.end,
                                                                            ))))
                                                              ],
                                                            )));
                                                  }
                                                });
                                              });
                                        }
                                      })
                                ]);
                              }
                            });
                          });
                    }
                  }))
            ]))));
  }
}

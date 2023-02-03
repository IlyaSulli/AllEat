import 'dart:async';
import 'package:alleat/services/cart_service.dart';
import 'package:alleat/services/queryserver.dart';
import 'package:alleat/widgets/elements/elements.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'dart:convert';

class Checkout extends StatefulWidget {
  final List cartInfo;
  const Checkout({Key? key, required this.cartInfo}) : super(key: key);

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  final Set<Marker> markers = {}; //markers for google map
  String selectedTip = "none"; //Percentage tip (15%, 20%, 25%, custom, none)
  double tipPrice = 0; //Tip price
  double subtotal = 0; //Subtotal for items
  static TextEditingController customAmount = TextEditingController(text: "£0.00"); //Custom price for tip (text field)

  Future<Map> sendCart(cart, tip, address, latitude, longitude) async {
    //Send cart to the server - formatted before sending
    int indexid = 0; //Index of the current item so that the customise 2D array can link to the item 2D array
    List iteminfo = []; //(profile id, item id, item quantity)
    List customiseinfo = []; //(index id, customise option id, option quantity)
    int restaurantid = 0; //restaurant id
    for (int i = 0; i < cart.length; i++) {
      //For each profile
      int profileid = cart[i][0]; //Save the profile id as profileid
      List itemkeys = cart[i][6].keys.toList();
      for (int j = 0; j < itemkeys.length; j++) {
        //For each item
        List item = cart[i][6][itemkeys[j]];
        restaurantid = int.parse(item[0][4]);
        int itemid = int.parse(item[0][12]); //Save item id as itemid
        int itemQuantity = item[0][6];
        iteminfo.add([
          profileid,
          itemid,
          itemQuantity,
        ]);

        List customisekeys = item[1].keys.toList();
        for (int k = 0; k < customisekeys.length; k++) {
          //For each customise title
          List customiseTitle = item[1][customisekeys[k]];
          for (int l = 0; l < customiseTitle[1].length; l++) {
            // For each option
            List customiseOption = customiseTitle[1][l];
            int customiseOptionid = int.parse(customiseOption[0]); //Save option id as customiseoptionid
            int optionQuantity = customiseOption[1];
            customiseinfo.add([indexid, customiseOptionid, optionQuantity]);
          }
        }
        indexid++; //Add one to index (incremental for each item)
      }
    }
    var res = await QueryServer.query("https://alleat.cpur.net/query/orders.php", {
      //Send data to orders.php . If there is an error, it returns back the error code
      "type": "add",
      "tip": tip,
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
      "restaurantid": restaurantid.toString(),
      "iteminfo": json.encode(iteminfo),
      "customiseinfo": json.encode(customiseinfo),
    });
    return res; //return result (contains basic message either with error=true and the error or error=false and success)
  }

  Future<List> getDeliveryDestination() async {
    final prefs = await SharedPreferences.getInstance(); // Get saved location from shared preferences
    final double? savedLocationLat = prefs.getDouble('locationLatitude');
    final double? savedLocationLng = prefs.getDouble('locationLongitude');
    final List<String>? savedLocationText = prefs.getStringList('locationPlacemark');
    if (savedLocationLat == null || savedLocationLng == null || savedLocationText == null) {
      //If either the latitude, longitude or the text is null return empty array to ensure that it cannot return a partial result ACID
      return [];
    } else {
      savedLocationText.addAll([savedLocationLat.toString(), savedLocationLng.toString()]);
      return savedLocationText.toList();
    }
  }

  Set<Marker> getmarkers(restaurantAddress, restaurantLat, restaurantLng, destination, destinationLat, destinationLng) {
    //Create the two markers on the map with their positions
    //markers to place on map
    BitmapDescriptor restaurantMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    BitmapDescriptor destinationMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
    markers.add(Marker(
        //add first marker
        markerId: const MarkerId("Restaurant"),
        position: LatLng(restaurantLat, restaurantLng), //position of restaurant
        infoWindow: const InfoWindow(
          //popup info
          title: 'Restaurant',
        ),
        icon: restaurantMarkerIcon //Icon for restaurant
        ));

    markers.add(Marker(
        markerId: const MarkerId("Delivery Address"),
        position: LatLng(destinationLat, destinationLng), //position of delivery address
        infoWindow: const InfoWindow(
          //popup info
          title: 'Delivery Address',
        ),
        icon: destinationMarkerIcon //Icon for delivery address
        ));

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const ScreenBackButton(),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: Text(
            "Checkout.",
            style: Theme.of(context).textTheme.headline1,
          )),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Location",
            style: Theme.of(context).textTheme.headline2,
          )),
      const SizedBox(
        height: 20,
      ),
      FutureBuilder<List>(
        future: getDeliveryDestination(), //Get the delivery location from shared preferences
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List destination = snapshot.data ?? [];
            if (destination != []) {
              List locationItemKeys = widget.cartInfo[0][6].keys
                  .toList(); //Get the item ids for the first profiles so that it can be used to get the restaurant info saved for it
              final List restaurantAddress =
                  widget.cartInfo[0][6][locationItemKeys[0]][0][9].split(','); //Split the restaurant address into seperate items in array
              final double restaurantLat = double.parse(widget.cartInfo[0][6][locationItemKeys[0]][0][10]);
              final double restaurantLng = double.parse(widget.cartInfo[0][6][locationItemKeys[0]][0][11]);
              final controllerMap = Completer<GoogleMapController>(); //Google Maps Controller
              final double destinationLat = double.parse(destination[4]);
              final double destinationLng = double.parse(destination[5]);

              return Column(children: [
                SizedBox(
                  //Create google map with height 200px without any movement controls centered around the destination of delivery
                  width: double.infinity,
                  height: 200,
                  child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                    return GoogleMap(
                        myLocationEnabled: false,
                        compassEnabled: false,
                        mapToolbarEnabled: false,
                        zoomGesturesEnabled: true,
                        // hide location button
                        myLocationButtonEnabled: false,
                        mapType: MapType.normal,
                        zoomControlsEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        //  camera position
                        initialCameraPosition: CameraPosition(target: LatLng(destinationLat, destinationLng), zoom: 12),
                        onMapCreated: (GoogleMapController controller) {
                          controllerMap.complete(controller);
                        },
                        markers: getmarkers(restaurantAddress, restaurantLat, restaurantLng, destination, destinationLat, destinationLng));
                  }),
                ),
                const SizedBox(
                  height: 20,
                ),
                //Column with the locations of the destination and restaurant using the colour coded markers as a key
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 30,
                          color: Color(0xffca458f),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Delivery Address",
                              style: Theme.of(context).textTheme.headline6?.copyWith(color: Theme.of(context).textTheme.headline1?.color),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "${destination[0]}, ${destination[1]}",
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            Text(
                              "${destination[2]}, ${destination[3]}",
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ))
                      ],
                    )),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 30,
                          color: Color(0xff4133e3),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Restaurant Address",
                              style: Theme.of(context).textTheme.headline6?.copyWith(color: Theme.of(context).textTheme.headline1?.color),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "${widget.cartInfo[0][6][locationItemKeys[0]][0][3]}: ${widget.cartInfo[0][6][locationItemKeys[0]][0][9]}",
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ))
                      ],
                    )),
              ]);
            } else {
              return const Text("Failed to get location");
            }
          } else {
            return const Text("Getting Destination");
          }
        },
      ),
      //Tipping section
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Divider(
            thickness: 2,
            color: Theme.of(context).textTheme.headline6?.color?.withOpacity(0.5),
            indent: 40,
            endIndent: 40,
          )),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: Text(
            "Tipping",
            style: Theme.of(context).textTheme.headline2,
          )),
      const SizedBox(
        height: 10,
      ),
      LayoutBuilder(builder: (p0, p1) {
        subtotal = 0;
        for (int i = 0; i < widget.cartInfo.length; i++) {
          //For each profile, get the profile item total price and add it to the current subtotal
          subtotal = (subtotal * 100 + widget.cartInfo[0][7] * 100) / 100;
        }
        //Tipping buttons
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(children: [
              Row(
                //Row of preset percentage tips
                children: [
                  Expanded(
                      //15% tip button
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: InkWell(
                              onTap: () {
                                //On button tap, change the selected tip to 15% so that the button colour changes and set the tip price to 15% of the subtotal
                                setState(() {
                                  selectedTip = "15%";
                                  tipPrice = double.parse((((subtotal * 100) * 0.15) / 100).toStringAsFixed(2));
                                });
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: (selectedTip == "15%") ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurface,
                                          width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.01),
                                          spreadRadius: 2,
                                          blurRadius: 10,
                                          offset: const Offset(0, 10), // changes position of shadow
                                        ),
                                      ]),
                                  child: AspectRatio(
                                      aspectRatio: 1 / 1,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "15%",
                                            style: Theme.of(context).textTheme.headline3,
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "+£${(((subtotal * 100) * 0.15) / 100).toStringAsFixed(2)}",
                                            style: Theme.of(context).textTheme.bodyText1,
                                          )
                                        ],
                                      )))))),
                  Expanded(
                      //20% tip button
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: InkWell(
                              onTap: () {
                                setState(() {
                                  //On button tap, change the selected tip to 20% so that the button colour changes and set the tip price to 20% of the subtotal
                                  selectedTip = "20%";
                                  tipPrice = double.parse((((subtotal * 100) * 0.20) / 100).toStringAsFixed(2));
                                });
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: (selectedTip == "20%") ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurface,
                                          width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.01),
                                          spreadRadius: 2,
                                          blurRadius: 10,
                                          offset: const Offset(0, 10), // changes position of shadow
                                        ),
                                      ]),
                                  child: AspectRatio(
                                      aspectRatio: 1 / 1,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "20%",
                                            style: Theme.of(context).textTheme.headline3,
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "+£${(((subtotal * 100) * 0.20) / 100).toStringAsFixed(2)}",
                                            style: Theme.of(context).textTheme.bodyText1,
                                          )
                                        ],
                                      )))))),
                  Expanded(
                      //25% tip button
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: InkWell(
                              onTap: () {
                                //On button tap, change the selected tip to 25% so that the button colour changes and set the tip price to 25% of the subtotal
                                setState(() {
                                  selectedTip = "25%";
                                  tipPrice = double.parse((((subtotal * 100) * 0.25) / 100).toStringAsFixed(2));
                                });
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: (selectedTip == "25%") ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurface,
                                          width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.01),
                                          spreadRadius: 2,
                                          blurRadius: 10,
                                          offset: const Offset(0, 10), // changes position of shadow
                                        ),
                                      ]),
                                  child: AspectRatio(
                                      aspectRatio: 1 / 1,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "25%",
                                            style: Theme.of(context).textTheme.headline3,
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "+£${(((subtotal * 100) * 0.25) / 100).toStringAsFixed(2)}",
                                            style: Theme.of(context).textTheme.bodyText1,
                                          )
                                        ],
                                      )))))),
                ],
              ),
              Padding(
                  //Custom tip price
                  padding: const EdgeInsets.all(10),
                  child: InkWell(
                      onTap: () {
                        //On button press, change the selectedTip to be "custom" so that it displays the custom tip price text field instead of the title
                        setState(() {
                          selectedTip = "custom";

                          try {
                            //Try to set the tip price to be the price inputted by the user but if it fails because it is null or a letter is typed, return it as 0
                            tipPrice = double.parse((double.parse((customAmount.text.toString().split("£"))[1])).toStringAsFixed(2));
                          } catch (e) {
                            tipPrice = 0;
                          }
                        });
                      },
                      child: Container(
                          alignment: Alignment.center,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onSurface,
                              border: Border.all(
                                  color: (selectedTip == "custom") ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurface,
                                  width: 2),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.01),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: const Offset(0, 10), // changes position of shadow
                                ),
                              ]),
                          child: (selectedTip == "custom") //If the selected button is "custom" display text field that is in the currency format
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Tip:",
                                        style: Theme.of(context).textTheme.headline6?.copyWith(color: Theme.of(context).textTheme.headline1?.color),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                            onChanged: (value) {
                                              try {
                                                tipPrice =
                                                    double.parse((double.parse((customAmount.text.toString().split("£"))[1])).toStringAsFixed(2));
                                              } catch (e) {
                                                tipPrice = 0;
                                              }
                                            },
                                            controller: customAmount,
                                            keyboardType: TextInputType.number,
                                            style: Theme.of(context).textTheme.bodyText2,
                                            inputFormatters: [CurrencyTextInputFormatter(symbol: '£')],
                                            decoration: (InputDecoration(
                                                hintText: "£3.21",
                                                contentPadding: Theme.of(context).inputDecorationTheme.contentPadding,
                                                border: Theme.of(context).inputDecorationTheme.border,
                                                focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
                                                enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
                                                floatingLabelBehavior: FloatingLabelBehavior.never))),
                                      )
                                    ],
                                  ))
                              //If the custom price is not selected, show title "custom tip amount" instead of the text field
                              : Text(
                                  "Custom Tip Amount",
                                  style: Theme.of(context).textTheme.headline6?.copyWith(color: Theme.of(context).textTheme.headline3?.color),
                                )))),
              Padding(
                  //No tip button
                  padding: const EdgeInsets.all(10),
                  child: InkWell(
                      onTap: () {
                        //On button press, change selected to be "none" so that it changes the highlight colour for it and set the tip price to be 0
                        setState(() {
                          selectedTip = "none";
                          tipPrice = 0;
                        });
                      },
                      child: Container(
                          alignment: Alignment.center,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onSurface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: (selectedTip == "none") ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurface,
                                  width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.01),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: const Offset(0, 10), // changes position of shadow
                                ),
                              ]),
                          child: Text(
                            "No Tip",
                            style: Theme.of(context).textTheme.headline6?.copyWith(color: Theme.of(context).textTheme.headline3?.color),
                          ))))
            ]));
      }),
      const SizedBox(
        height: 20,
      ),
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Divider(
            thickness: 2,
            color: Theme.of(context).textTheme.headline6?.color?.withOpacity(0.5),
            indent: 40,
            endIndent: 40,
          )),
      LayoutBuilder(builder: ((p0, p1) {
        //Checkout final price section
        List priceItemKeys = widget.cartInfo[0][6].keys.toList(); //get the item ids for the first profile in the cart
        double total = (subtotal * 100 + double.parse(widget.cartInfo[0][6][priceItemKeys[0]][0][5]) * 100 + tipPrice * 100) /
            100; //Total is equal to the subtotal + delivery price + tip
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Subtotal",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Text(
                        "Delivery Fee",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Text(
                        "Tip",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Total",
                        style: Theme.of(context).textTheme.headline5?.copyWith(color: Theme.of(context).primaryColor),
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 50,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "£${subtotal.toStringAsFixed(2)}",
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      Text(
                        "£${widget.cartInfo[0][6][priceItemKeys[0]][0][5].toString()}",
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      Text(
                        "£${tipPrice.toStringAsFixed(2)}",
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      const SizedBox(height: 20),
                      Text("£${total.toStringAsFixed(2)}",
                          style: Theme.of(context).textTheme.headline5?.copyWith(color: Theme.of(context).textTheme.headline1?.color)),
                    ],
                  )
                ],
              ),
            ]));
      })),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Expanded(
            //Checkout button
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: ElevatedButton(
                    onPressed: (() async {
                      //On button press get the delivery location and join the destination address into a single string
                      List destination = await getDeliveryDestination();
                      String destinationAddress = [destination[0], destination[1], destination[2], destination[3]].join(" ,");
                      Map orderCreated = await sendCart(
                          //Send the cart to the server
                          widget.cartInfo,
                          tipPrice.toString(),
                          destinationAddress,
                          destination[4].toString(),
                          destination[5].toString());
                      if (orderCreated["error"] == true) {
                        //If there is an error go to the homepage and display snackbar with error message
                        setState(() {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ERROR: ${orderCreated["message"]}")));
                        });
                      } else {
                        //If there isnt an error try to clear the cart
                        try {
                          await SQLiteCartItems.clearCart();
                          setState(() {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Successfully ordered.")));
                          });
                        } catch (e) {
                          //If there is an error clearing the cart display error
                          setState(() {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text("ERROR: Successfully created order but failed to clear cart. \n $e")));
                          });
                        }
                      }
                    }),
                    child: const Text("Complete Order"))))
      ])
    ])));
  }
}

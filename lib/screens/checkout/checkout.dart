import 'dart:async';
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
  String selectedTip = "none";
  double tipPrice = 0;
  double subtotal = 0;
  static TextEditingController customAmount = TextEditingController(text: "£0.00");

  Future<Map> sendCart(cart, tip, address, latitude, longitude) async {
    int indexid = 0;
    List iteminfo = [];
    List customiseinfo = [];
    int restaurantid = 0;
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
          indexid,
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
            print(customiseOption);
            int customiseOptionid = int.parse(customiseOption[0]); //Save option id as customiseoptionid
            int optionQuantity = customiseOption[1];
            customiseinfo.add([indexid, customiseOptionid, optionQuantity]);
          }
        }
        indexid++; //Add one to index (incremental for each item)
      }
    }
    print(iteminfo);
    print(customiseinfo);
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
    return res;
  }

  Future<List> getDeliveryDestination() async {
    final prefs = await SharedPreferences.getInstance(); // Get saved location from shared preferences
    final double? savedLocationLat = prefs.getDouble('locationLatitude');
    final double? savedLocationLng = prefs.getDouble('locationLongitude');
    final List<String>? savedLocationText = prefs.getStringList('locationPlacemark');
    if (savedLocationLat == null || savedLocationLng == null || savedLocationText == null) {
      return [];
    } else {
      savedLocationText.addAll([savedLocationLat.toString(), savedLocationLng.toString()]);
      return savedLocationText.toList();
    }
  }

  Set<Marker> getmarkers(restaurantAddress, restaurantLat, restaurantLng, destination, destinationLat, destinationLng) {
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
        future: getDeliveryDestination(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List destination = snapshot.data ?? [];
            if (destination != []) {
              List locationItemKeys = widget.cartInfo[0][6].keys.toList();
              final List restaurantAddress = widget.cartInfo[0][6][locationItemKeys[0]][0][9].split(',');
              final double restaurantLat = double.parse(widget.cartInfo[0][6][locationItemKeys[0]][0][10]);
              final double restaurantLng = double.parse(widget.cartInfo[0][6][locationItemKeys[0]][0][11]);
              final controllerMap = Completer<GoogleMapController>(); //Google Maps Controller
              final double destinationLat = double.parse(destination[4]);
              final double destinationLng = double.parse(destination[5]);

              return Column(children: [
                SizedBox(
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
          subtotal = (subtotal * 100 + widget.cartInfo[0][7] * 100) / 100;
        }
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(children: [
              Row(
                children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: InkWell(
                              onTap: () {
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
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: InkWell(
                              onTap: () {
                                setState(() {
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
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: InkWell(
                              onTap: () {
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
                  padding: const EdgeInsets.all(10),
                  child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedTip = "custom";

                          try {
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
                          child: (selectedTip == "custom")
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
                              : Text(
                                  "Custom Tip Amount",
                                  style: Theme.of(context).textTheme.headline6?.copyWith(color: Theme.of(context).textTheme.headline3?.color),
                                )))),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: InkWell(
                      onTap: () {
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
        List locationItemKeys = widget.cartInfo[0][6].keys.toList();
        double total = (subtotal * 100 + double.parse(widget.cartInfo[0][6][locationItemKeys[0]][0][5]) * 100 + tipPrice * 100) / 100;
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
                        "£${widget.cartInfo[0][6][locationItemKeys[0]][0][5].toString()}",
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
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: ElevatedButton(
                    onPressed: (() async {
                      List destination = await getDeliveryDestination();
                      String destinationAddress = [destination[0], destination[1], destination[2], destination[3]].join(" ,");
                      Map orderCreated = await sendCart(
                          widget.cartInfo, tipPrice.toString(), destinationAddress, destination[4].toString(), destination[5].toString());
                      setState(() {
                        showDialog<String>(
                            //Display popup to confirm
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                    backgroundColor: Theme.of(context).backgroundColor,
                                    title: Text(
                                      'Server Response',
                                      style: Theme.of(context).textTheme.headline5?.copyWith(color: Theme.of(context).textTheme.headline1?.color),
                                    ),
                                    content: Text(
                                      orderCreated.toString(),
                                      style: Theme.of(context).textTheme.bodyText2,
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        //Cancel button to close the popup bring user back to the location page
                                        onPressed: () => Navigator.pop(context, 'Cancel'),
                                        child: const Text('Cancel'),
                                      ),
                                    ]));
                      });
                    }),
                    child: const Text("Complete Order"))))
      ])
    ])));
  }
}

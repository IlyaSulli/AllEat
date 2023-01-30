import 'dart:async';
import 'package:alleat/widgets/elements/elements.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_picker/map_picker.dart';
import 'dart:math';

class Checkout extends StatefulWidget {
  final List cartInfo;
  const Checkout({Key? key, required this.cartInfo}) : super(key: key);

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  final Set<Marker> markers = {}; //markers for google map
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
      const SizedBox(
        height: 30,
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
    ])));
  }
}

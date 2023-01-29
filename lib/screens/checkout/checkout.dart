import 'dart:async';
import 'package:alleat/widgets/elements/elements.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_picker/map_picker.dart';

class Checkout extends StatefulWidget {
  final List cartInfo;
  const Checkout({Key? key, required this.cartInfo}) : super(key: key);

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
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
              final String restaurantAddress = widget.cartInfo[0][6][locationItemKeys[0]][0][8];

              final _controller = Completer<GoogleMapController>(); //Google Maps Controller
              MapPickerController mapPickerController = MapPickerController(); // Marker controller
              final double destinationLat = double.parse(destination[4]);
              final double destinationLng = double.parse(destination[5]);
              CameraPosition cameraPosition = CameraPosition(target: LatLng(destinationLat, destinationLng), zoom: 18);
              return Column(children: [
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                    return MapPicker(
                        // pass icon widget
                        iconWidget: Icon(
                          Icons.location_on,
                          size: 50,
                          color: Theme.of(context).primaryColor,
                        ),
                        //add map picker controller
                        mapPickerController: mapPickerController,
                        child: GoogleMap(
                          myLocationEnabled: false,
                          scrollGesturesEnabled: false,
                          onCameraMove: (position) {
                            null;
                          },

                          compassEnabled: false,
                          mapToolbarEnabled: false,
                          zoomControlsEnabled: false,
                          // hide location button
                          myLocationButtonEnabled: false,
                          mapType: MapType.normal,

                          rotateGesturesEnabled: false,
                          tiltGesturesEnabled: false,
                          //  camera position
                          initialCameraPosition: cameraPosition,
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                        ));
                  }),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 30,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${destination[0]}, ${destination[1]}",
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            Text(
                              "${destination[2]}, ${destination[3]}",
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ],
                        ))
                      ],
                    )),
                Text(widget.cartInfo.toString())
              ]);
            } else {
              return Text("Failed to get location");
            }
          } else {
            return Text("Getting Destination");
          }
        },
      ),
    ])));
  }
}

import 'dart:async';
import 'package:alleat/widgets/genericlocading.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:map_picker/map_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class SelectLocation extends StatefulWidget {
  const SelectLocation({super.key});

  @override
  State<SelectLocation> createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  final _controller = Completer<GoogleMapController>();
  static TextEditingController addresslineone = TextEditingController();
  static TextEditingController addresslinetwo = TextEditingController();
  static TextEditingController postcode = TextEditingController();
  static TextEditingController city = TextEditingController();
  MapPickerController mapPickerController = MapPickerController();
  late var cameraPosition =
      const CameraPosition(target: LatLng(0, 0), zoom: 20);

  Future<List> getSavedPosition(getType) async {
    //Try to get saved location and current location
    if (getType == 0) {
      final prefs = await SharedPreferences
          .getInstance(); // Get saved location from shared preferences
      final double? savedLocationLat = prefs.getDouble('locationlat');
      final double? savedLocationLng = prefs.getDouble('locationlat');
      if (savedLocationLat != null && savedLocationLng != null) {
        //If not null returned, return the value
        return [savedLocationLat, savedLocationLng];
      } else {
        //If null returned from saved location, get the approximate location
        return getCurrentLocation();
      }
    } else if (getType == 1) {
      return getCurrentLocation();
    } else {
      return [0, 0];
    }
  }

  Future<List> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return [51.509865, -0.118092];
    }

    // Check if the location is denied
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return [51.509865, -0.118092];
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return [51.509865, -0.118092];
    }

    // Access the current possition of the device
    Position locationDevice = await Geolocator.getCurrentPosition();
    return [locationDevice.latitude, locationDevice.longitude];
  }

  Future<void> getPlacemark() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        cameraPosition.target.latitude,
        cameraPosition.target.longitude,
      );
      addresslineone = TextEditingController(text: placemarks.first.name);
      addresslinetwo = TextEditingController(text: placemarks.first.street);
      postcode = TextEditingController(text: placemarks.first.postalCode);
      if ((placemarks.first.locality) == "") {
        city =
            TextEditingController(text: placemarks.first.subAdministrativeArea);
      } else {
        city = TextEditingController(text: placemarks.first.locality);
      }
    } catch (e) {
      textController.text = "";
    }
  }

  var textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<List>(
      future: getSavedPosition(0),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const GenericLoading();
        }
        if (snapshot.hasData) {
          var savedPosition = snapshot.data ?? [];

          CameraPosition cameraPosition = CameraPosition(
              target: LatLng(savedPosition[0], savedPosition[1]), zoom: 19);
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return MapPicker(
                    // pass icon widget
                    iconWidget: const Icon(
                      Icons.location_on,
                      size: 65,
                    ),
                    //add map picker controller
                    mapPickerController: mapPickerController,
                    child: GoogleMap(
                      myLocationEnabled: false,

                      zoomControlsEnabled: false,
                      // hide location button
                      myLocationButtonEnabled: true,
                      mapType: MapType.normal,

                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      //  camera position
                      initialCameraPosition: cameraPosition,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      onCameraMoveStarted: () {
                        // notify map is moving
                        mapPickerController.mapMoving!();
                      },
                      onCameraMove: (cameraPosition) {
                        try {
                          //If the pointer position is invalid, dont try to move the map.
                          this.cameraPosition = cameraPosition;
                        } catch (e) {
                          cameraPosition = cameraPosition;
                        }
                      },
                      onCameraIdle: () async {
                        // notify map stopped moving
                        try {
                          // if there is an error getting the placemark return null
                          mapPickerController.mapFinishedMoving!();
                          //get address name from camera position
                          getPlacemark();
                        } catch (e) {
                          return;
                        }
                      },
                    ));
              }),
              DraggableScrollableSheet(
                  initialChildSize: 0.2,
                  snap: true,
                  minChildSize: 0.2,
                  maxChildSize: 0.8,
                  builder: ((context, scrollController) {
                    return Container(
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10)),
                            color: Theme.of(context).backgroundColor,
                            boxShadow: const [
                              BoxShadow(
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  color: Color.fromARGB(8, 0, 0, 0))
                            ]),
                        child: ListView.builder(
                            controller: scrollController,
                            itemCount: 1,
                            itemBuilder: ((context, index) {
                              return Column(
                                children: [
                                  Container(
                                      width: 40,
                                      height: 5,
                                      decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(5))),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 30, horizontal: 20),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: InkWell(
                                                  onTap: (() {
                                                    print(cameraPosition
                                                        .target.latitude);
                                                    print(cameraPosition
                                                        .target.longitude);
                                                    print(textController.text);
                                                  }),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: Theme.of(context)
                                                            .primaryColor),
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 15,
                                                        horizontal: 30),
                                                    child: Text(
                                                      "Save Location",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline6!
                                                          .copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onSurface),
                                                    ),
                                                  ))),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              // Get the current location of the device
                                              List currentLocation =
                                                  await getCurrentLocation();
                                              // Move the camera to the current location
                                              final GoogleMapController
                                                  controller =
                                                  await _controller.future;
                                              controller.animateCamera(
                                                  CameraUpdate
                                                      .newCameraPosition(
                                                CameraPosition(
                                                  target: LatLng(
                                                      currentLocation[0],
                                                      currentLocation[1]),
                                                  zoom: 18,
                                                ),
                                              ));
                                            },
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Theme.of(context)
                                                        .backgroundColor),
                                                padding:
                                                    const EdgeInsets.all(15),
                                                child: Icon(
                                                  Icons.my_location,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .headline1!
                                                      .color,
                                                )),
                                          )
                                        ],
                                      )),
                                  Container(
                                      padding: const EdgeInsets.all(20),
                                      alignment: Alignment.bottomLeft,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Edit your address",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline3),
                                            const SizedBox(height: 20),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 15),
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Address Line 1",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline6,
                                                      ),
                                                      TextFormField(
                                                        controller:
                                                            addresslineone,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2,
                                                        inputFormatters: [
                                                          //Only allows the input of letters a-z and A-Z and @,.-
                                                          FilteringTextInputFormatter
                                                              .allow(RegExp(
                                                                  r'[a-zA-Z0-9,.-]+|\s'))
                                                        ],
                                                      )
                                                    ])),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 15),
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Address Line 2",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline6,
                                                      ),
                                                      TextFormField(
                                                        controller:
                                                            addresslinetwo,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2,
                                                        inputFormatters: [
                                                          //Only allows the input of letters a-z and A-Z and ,.- and space
                                                          FilteringTextInputFormatter
                                                              .allow(RegExp(
                                                                  r'[a-zA-Z0-9,.-]+|\s'))
                                                        ],
                                                      )
                                                    ])),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 15),
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "City/County",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline6,
                                                      ),
                                                      TextFormField(
                                                        controller: city,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2,
                                                        inputFormatters: [
                                                          //Only allows the input of letters a-z and A-Z and ,.- and space
                                                          FilteringTextInputFormatter
                                                              .allow(RegExp(
                                                                  r'[a-zA-Z0-9,.-]+|\s'))
                                                        ],
                                                      )
                                                    ])),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 15),
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Postcode",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline6,
                                                      ),
                                                      TextFormField(
                                                        controller: postcode,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2,
                                                        inputFormatters: [
                                                          //Only allows the input of letters a-z and A-Z and ,.- and space
                                                          FilteringTextInputFormatter
                                                              .allow(RegExp(
                                                                  r'[a-zA-Z0-9,.-]+|\s'))
                                                        ],
                                                      )
                                                    ])),
                                          ]))
                                ],
                              );
                            })));
                  })),
            ],
          );
        } else {
          return const GenericLoading();
        }
      },
    ));
  }
}

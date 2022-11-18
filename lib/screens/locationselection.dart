import 'dart:async';
import 'package:alleat/widgets/elements/elements.dart';
import 'package:alleat/widgets/genericlocading.dart';
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
      textController.text =
          "${placemarks.first.street}, ${placemarks.first.subAdministrativeArea}";
    } catch (e) {
      textController.text = "Move the map to select location";
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
              MapPicker(
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
                      textController.text = "...";
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
                  )),
              Positioned(
                  top: MediaQuery.of(context).viewPadding.top + 30,
                  width: MediaQuery.of(context).size.width - 70,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 30),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface,
                        borderRadius: BorderRadius.circular(10)),
                    child: TextFormField(
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      readOnly: true,
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none),
                      controller: textController,
                    ),
                  )),
              Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        children: [
                          Expanded(
                              child: InkWell(
                                  onTap: null,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Theme.of(context).primaryColor),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 30),
                                    child: Text(
                                      "Save Location",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface),
                                    ),
                                  ))),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                cameraPosition = const CameraPosition(
                                    target: LatLng(0, 0), zoom: 19);
                              });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Theme.of(context).backgroundColor),
                                padding: const EdgeInsets.all(15),
                                child: Icon(
                                  Icons.my_location,
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline1!
                                      .color,
                                )),
                          )
                        ],
                      )))
              // const Positioned(
              //   bottom: 24,
              //   left: 24,
              //   right: 24,
              //   child: SizedBox(height: 50, child: ScreenBackButton()
              // TextButton(
              //   onPressed: () {
              //     print(
              //         "Location ${cameraPosition.target.latitude} ${cameraPosition.target.longitude}");
              //     print("Address: ${textController.text}");
              //   },
              //   style: ButtonStyle(
              //     backgroundColor: MaterialStateProperty.all<Color>(
              //         const Color(0xFFA3080C)),
              //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              //       RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(15.0),
              //       ),
              //     ),
              //   ),
              //   child: const Text(
              //     "Submit",
              //     style: TextStyle(
              //       fontWeight: FontWeight.w400,
              //       fontStyle: FontStyle.normal,
              //       color: Color(0xFFFFFFFF),
              //       fontSize: 19,
              //       // height: 19/19,
              //     ),
              //   ),
              // ),
              //  ),
              //)
            ],
          );
        } else {
          return GenericLoading();
        }
      },
    ));
  }
}

import 'package:alleat/services/sqlite_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geo;

class CurrentLocation extends StatefulWidget {
  const CurrentLocation({Key? key}) : super(key: key);

  @override
  State<CurrentLocation> createState() => _CurrentLocationState();
}

class _CurrentLocationState extends State<CurrentLocation> {
  Future<String> getSavedStreet() async {
    try {
      // Try to see if there is an address saved
      List address = await SQLiteLocalDB.getAddress(); // Get address
      setState(() {
        // Update the widget if there is a change
        address = address;
      });
      return address[0]["savedaddressstreet"]; // Send back the street address
    } catch (e) {
      return "Set Location."; // Send back that no location is saved
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getSavedStreet(), //Get the saved street address
        builder: (context, snapshot) {
          var location = snapshot.data ?? [];

          if (!snapshot.hasData) {
            //While getting the street address, add button with loading bar

            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              padding: const EdgeInsets.only(
                                  top: 5, bottom: 7, left: 35, right: 20),
                              decoration: const BoxDecoration(
                                  color: Color(0xffEBE0FF),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 12),
                                    child: SizedBox(
                                      width: 80,
                                      height: 3,
                                      child: LinearProgressIndicator(
                                        color: Color(0xff4100C4),
                                        backgroundColor: Color(0xffEBE0FF),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const FromSavedManualLocation())); //Go to the manual location page
                                      },
                                      icon: const Icon(
                                        Icons.location_on,
                                        color: Color(0xff4100C4),
                                      ))
                                ],
                              ))
                        ],
                      ))
                ]);
          } else {
            // Once the street address is recieved, output the street address instead of the loading bar
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const FromSavedManualLocation()));
                              },
                              child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 5, bottom: 7, left: 35, right: 20),
                                  decoration: const BoxDecoration(
                                      color: Color(0xffEBE0FF),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  child: Row(
                                    children: [
                                      Text(
                                        location.toString(),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff4100C4),
                                            fontWeight: FontWeight.w600),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const FromSavedManualLocation())); //Go to the manual location page
                                          },
                                          icon: const Icon(
                                            Icons.location_on,
                                            color: Color(0xff4100C4),
                                          ))
                                    ],
                                  )))
                        ],
                      ))
                ]);
          }
        });
  }
}

class FromSavedManualLocation extends StatefulWidget {
  const FromSavedManualLocation({Key? key}) : super(key: key);

  @override
  State<FromSavedManualLocation> createState() =>
      _FromSavedManualLocationState();
}

class _FromSavedManualLocationState extends State<FromSavedManualLocation> {
  final _formKey = GlobalKey<FormState>();
  final verifyPostcode = RegExp(
      r"^([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([AZa-z][0-9][A-Za-z])|([A-Za-z][A-Ha-hJ-Yj-y][0-9]?[A-Za-z]))))[0-9][A-Za-z]{2})$"); //Postcode formatting

  Future<List> getSavedAddress() async {
    return await SQLiteLocalDB.getAddress(); // get the saved address
  }

  Future<void> saveFilledAddress(String extraAddress, String streetAddress,
      String cityAddress, String postcodeAddress) async {
    try {
      SQLiteLocalDB.setAddress(extraAddress, streetAddress, cityAddress,
          postcodeAddress); // Try to save address
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully saved address.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Failed to save address'))); // If failed to saved, output failed to save
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
        future: getSavedAddress(), //Get the saved address to fill the fields
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
                child:
                    CircularProgressIndicator()); //While loading, display loading page
          }
          if (snapshot.hasError) {
            return const Center(
                child: Text("Failed")); //If there is a failure, output Failed
          }
          List savedAddress = snapshot.data ?? []; //Get address in list form
          if (savedAddress.isEmpty) {
            //If it is an empty list (nothing is saved for profile) output empty fields in the right format
            savedAddress = [
              {
                "savedaddressextra": "",
                "savedaddressstreet": "",
                "savedaddresscity": "",
                "savedaddresspostcode": ""
              }
            ];
          }
          final TextEditingController extraAddress = TextEditingController(
              text: savedAddress[0]
                  ["savedaddressextra"]); //For each field, fill with saved data
          final TextEditingController streetAddress = TextEditingController(
              text: savedAddress[0]["savedaddressstreet"]);
          final TextEditingController cityAddress =
              TextEditingController(text: savedAddress[0]["savedaddresscity"]);
          final TextEditingController postcodeAddress = TextEditingController(
              text: savedAddress[0]["savedaddresspostcode"]);
          return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: const Text(
                    'Address Details.'), //Create page for manual fill
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () =>
                        Navigator.of(context).pop()), //Go back button
                backgroundColor: Theme.of(context).primaryColor,
              ),
              body: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 170,
                              height: 40,
                              child: ElevatedButton(
                                // Button for getting current location
                                style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(50),
                                    backgroundColor: const Color(0xff5806FF)),
                                onPressed: (() {
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const FromCurrentManualLocation()));
                                }),
                                child: const Text("Use current Location"),
                              ),
                            )),
                        ListTile(
                            title: TextFormField(
                                keyboardType: TextInputType.name,
                                controller: extraAddress,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(
                                      "[a-zA-Z0-9|\\.|\\'|\\#\\|@\\|%\\|&\\|/|\\ ]")) // Must only contain a-z, A-Z, 0-9, ., ', #, @, %, &, /, (space)
                                ],
                                decoration: (const InputDecoration(
                                    labelText:
                                        "Apt, suite, unit, building, floor etc.")))),
                        ListTile(
                            title: TextFormField(
                          keyboardType: TextInputType.name,
                          controller: streetAddress,
                          validator: (streetAddress) {
                            if (streetAddress == null ||
                                streetAddress.isEmpty) {
                              // Must be filled
                              return "Required";
                            }
                            return null;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(
                                "[a-zA-Z0-9|\\.|\\'|\\#\\|@\\|%\\|&\\|/|\\ ]")) // Must only contain a-z, A-Z, 0-9, ., ', #, @, %, &, /, (space)
                          ],
                          decoration: (const InputDecoration(
                              labelText: "Street Address")),
                        )),
                        ListTile(
                            title: TextFormField(
                          keyboardType: TextInputType.name,
                          validator: (cityAddress) {
                            if (cityAddress == null || cityAddress.isEmpty) {
                              //Must be filled
                              return "Required";
                            }
                            return null;
                          },
                          controller: cityAddress,
                          decoration:
                              (const InputDecoration(labelText: "City")),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(
                                "[a-zA-Z0-9|\\.|\\'|\\#\\|@\\|%\\|&\\|/|\\ ]")) // Must only contain a-z, A-Z, 0-9, ., ', #, @, %, &, /, (space)
                          ],
                        )),
                        ListTile(
                            title: TextFormField(
                          controller: postcodeAddress,
                          keyboardType: TextInputType.name,
                          onChanged: (value) {
                            postcodeAddress.value = TextEditingValue(
                                //Force capital letters
                                text: value.toUpperCase(),
                                selection: postcodeAddress.selection);
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(
                                '[a-zA-Z0-9]')) // Must only contain a-z, A-Z and 0-9
                          ],
                          decoration:
                              (const InputDecoration(labelText: "Postcode")),
                          validator: (postcodeAddress) {
                            if (postcodeAddress == null ||
                                postcodeAddress.isEmpty ||
                                postcodeAddress.length != 6) {
                              // Must be filled and be exactly 6 characters
                              return "Enter valid postcode";
                            }
                            return null;
                          },
                        )),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                backgroundColor: const Color(0xff5806FF)),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                //If passed validation continue
                                saveFilledAddress(
                                    extraAddress.text,
                                    streetAddress.text,
                                    cityAddress.text,
                                    postcodeAddress.text);
                                Navigator.pop(context); // Go back to main page
                              }
                            },
                            child: const Text("Save Address"),
                          ),
                        )
                      ]))));
        });
  }
}

class FromCurrentManualLocation extends StatefulWidget {
  const FromCurrentManualLocation({Key? key}) : super(key: key);

  @override
  State<FromCurrentManualLocation> createState() =>
      _FromCurrentManualLocationState();
}

class _FromCurrentManualLocationState extends State<FromCurrentManualLocation> {
  final _formKey = GlobalKey<FormState>();
  final verifyPostcode = RegExp(
      r"^([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([AZa-z][0-9][A-Za-z])|([A-Za-z][A-Ha-hJ-Yj-y][0-9]?[A-Za-z]))))[0-9][A-Za-z]{2})$"); // Postcode format

  Future<void> saveFilledAddress(String extraAddress, String streetAddress,
      String cityAddress, String postcodeAddress) async {
    try {
      SQLiteLocalDB.setAddress(extraAddress, streetAddress, cityAddress,
          postcodeAddress); // Try to save
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully saved address.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save address')));
    }
  }

  Future<List> determinePosition() async {
    bool serviceEnabled;
    geo.LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check if the location is denied
    permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.

      return Future.error('Location permissions are permanently denied.');
    }

    // Access the current possition of the device
    geo.Position locationDevice = await geo.Geolocator.getCurrentPosition();
    List locationDeviceLatLong = [
      locationDevice.latitude,
      locationDevice.longitude
    ];
    List<Placemark> placemarks = await placemarkFromCoordinates(
        locationDeviceLatLong[0],
        locationDeviceLatLong[1]); //Get the lat and long
    Placemark place = placemarks[0];
    List address = [
      //Convert to address
      {
        "savedaddressextra": "",
        "savedaddressstreet": place.street,
        "savedaddresscity": place.subAdministrativeArea,
        "savedaddresspostcode": place.postalCode?.replaceAll(' ',
            '') //Remove the space between the each 3 characters to fit with the constraint
      }
    ];
    return address;
  }

  Future<List> getCurrentAddress() async {
    try {
      List location = await determinePosition(); //Get current location
      return location;
    } catch (e) {
      //If failed to get location, replace with nothing
      return [
        {
          "savedaddressextra": "",
          "savedaddressstreet": "",
          "savedaddresscity": "",
          "savedaddresspostcode": ""
        }
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
        future: getCurrentAddress(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            //While waiting to get location, show loading circle
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            //On future failure, show failed
            return const Center(child: Text("Failed"));
          }
          List savedAddress =
              snapshot.data ?? []; //Get the location from future
          if (savedAddress.isEmpty) {
            //If it is empty, replace with blanks
            savedAddress = [
              {
                "savedaddressextra": "",
                "savedaddressstreet": "",
                "savedaddresscity": "",
                "savedaddresspostcode": ""
              }
            ];
          }
          final TextEditingController extraAddress = TextEditingController(
              text: savedAddress[0][
                  "savedaddressextra"]); //For each field, fill with the current address
          final TextEditingController streetAddress = TextEditingController(
              text: savedAddress[0]["savedaddressstreet"]);
          final TextEditingController cityAddress =
              TextEditingController(text: savedAddress[0]["savedaddresscity"]);
          final TextEditingController postcodeAddress = TextEditingController(
              text: savedAddress[0]["savedaddresspostcode"]);
          return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: const Text('Address Details.'),
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () =>
                        Navigator.of(context).pop()), //Go back button
                backgroundColor: Theme.of(context).primaryColor,
              ),
              body: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 170,
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(50),
                                    backgroundColor: const Color(0xff5806FF)),
                                onPressed: (() {
                                  //Recenter button to get current location again
                                  Navigator.pop(
                                      context); //Reopen current location class
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const FromCurrentManualLocation()));
                                }),
                                child: const Text("Recenter"),
                              ),
                            )),
                        ListTile(
                            title: TextFormField(
                                keyboardType: TextInputType.name,
                                controller: extraAddress,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(
                                      "[a-zA-Z0-9|\\.|\\'|\\#\\|@\\|%\\|&\\|/|\\ ]")) // Must only contain a-z, A-Z, 0-9, ., ', #, @, %, &, /, (space)
                                ],
                                decoration: (const InputDecoration(
                                    labelText:
                                        "Apt, suite, unit, building, floor etc.")))),
                        ListTile(
                            title: TextFormField(
                          keyboardType: TextInputType.name,
                          controller: streetAddress,
                          validator: (streetAddress) {
                            if (streetAddress == null ||
                                streetAddress.isEmpty) {
                              return "Required";
                            }
                            return null;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(
                                "[a-zA-Z0-9|\\.|\\'|\\#\\|@\\|%\\|&\\|/|\\ ]")) // Must only contain a-z, A-Z, 0-9, ., ', #, @, %, &, /, (space)
                          ],
                          decoration: (const InputDecoration(
                              labelText: "Street Address")),
                        )),
                        ListTile(
                            title: TextFormField(
                          keyboardType: TextInputType.name,
                          validator: (cityAddress) {
                            if (cityAddress == null || cityAddress.isEmpty) {
                              return "Required";
                            }
                            return null;
                          },
                          controller: cityAddress,
                          decoration:
                              (const InputDecoration(labelText: "City")),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(
                                "[a-zA-Z0-9|\\.|\\'|\\#\\|@\\|%\\|&\\|/|\\ ]")) // Must only contain a-z, A-Z, 0-9, ., ', #, @, %, &, /, (space)
                          ],
                        )),
                        ListTile(
                            title: TextFormField(
                          controller: postcodeAddress,
                          keyboardType: TextInputType.name,
                          onChanged: (value) {
                            postcodeAddress.value = TextEditingValue(
                                text: value.toUpperCase(),
                                selection: postcodeAddress.selection);
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(
                                '[a-zA-Z0-9]')) // Must only contain a-z, A-Z, 0-9
                          ],
                          decoration:
                              (const InputDecoration(labelText: "Postcode")),
                          validator: (postcodeAddress) {
                            if (postcodeAddress == null ||
                                postcodeAddress.isEmpty ||
                                postcodeAddress.length != 6) {
                              return "Enter valid postcode";
                            }
                            return null;
                          },
                        )),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                backgroundColor: const Color(0xff5806FF)),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // If all validation correct, send to be saved and close the page
                                saveFilledAddress(
                                    extraAddress.text,
                                    streetAddress.text,
                                    cityAddress.text,
                                    postcodeAddress.text);
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Invalid Address')));
                              }
                            },
                            child: const Text("Save Address"),
                          ),
                        )
                      ]))));
        });
  }
}

import 'dart:math';
import 'package:alleat/services/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RestaurantItemCustomisePage extends StatefulWidget {
  final String itemid;
  final String foodcategory;
  final String subfoodcategory;
  final String itemname;
  final String description;
  final String price;
  final String itemimage;
  final String reslogo;
  const RestaurantItemCustomisePage(
      {Key?
          key, //Get the items from the restaurant main page when an item is clicked
      required this.reslogo,
      required this.itemid,
      required this.foodcategory,
      required this.subfoodcategory,
      required this.itemname,
      required this.description,
      required this.price,
      required this.itemimage})
      : super(key: key);

  @override
  State<RestaurantItemCustomisePage> createState() =>
      _RestaurantItemCustomisePageState();
}

class _RestaurantItemCustomisePageState
    extends State<RestaurantItemCustomisePage> {
  int quantity = 1;
  Map customisedOptions = {};
  bool beenMade = false;
  double changingPrice = 0;
  List requiredFields = [];
  late double quantityPrice = double.parse(widget.price);
  late double finalSinglePrice = double.parse(widget.price);
  Future<bool> addToCart() async {
    try {
      String customisedOptionsEncoded = json.encode(customisedOptions);
      await SQLiteCartItems.addToCart(
          int.parse(widget.itemid), customisedOptionsEncoded, quantity);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map> getCustomiseOptions() async {
    try {
      String phpurl = "https://alleat.cpur.net/query/itemcustomise.php";
      var res =
          await http.post(Uri.parse(phpurl), body: {"itemid": widget.itemid});
      if (res.statusCode == 200) {
        //If sends successfully
        var data = json.decode(res.body); //Decode to array
        if (data["error"]) {
          Map error = {
            "error": true,
            "message": "Server Error: ${data["message"]}",
            "customise": "[]"
          } //Send blank list of customise data
              ;
          return error;
          //If fails to perform query
        } else {
          Map success = {
            "error": false,
            "message": "",
            "customise": data["customiseitem"]
          } //Send back returned data
              ;
          return success;
        }
      } else {
        Map error = {
          "error": true,
          "message": "Error $e: Please try again",
          "customise": "[]"
        } //Send blank list of customise data
            ;
        return error;
      }
    } catch (e) {
      Map error = {
        "error": true,
        "message": "Unexpected Error: $e",
        "customise": "[]"
      } //Send blank list of customise data
          ;
      return error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(children: [
      Stack(children: [
        //Display item image at bottom of stack
        Container(
          width: MediaQuery.of(context).size.width,
          height: 240,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fitWidth,
              image: NetworkImage(widget.itemimage),
            ),
          ),
        ),
        Align(
            //Display rounded container at bottom of image to respresent overhanging image
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 215),
              width: double.infinity,
              height: 30,
              decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20))),
            )),
        Align(
            // Display background color as outline of restaurant logo, overlapping the image background
            alignment: Alignment.bottomCenter,
            child: Container(
                margin: const EdgeInsets.only(top: 180),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).backgroundColor,
                ))),
        Align(
            // Display circle restaurant logo
            alignment: Alignment.bottomCenter,
            child: Container(
                margin: const EdgeInsets.only(top: 185),
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(widget.reslogo.toString()),
                  ),
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.onSurface,
                ))),
        SafeArea(
            // Display back button in a circle
            child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  margin: const EdgeInsets.only(top: 20, left: 20),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: Theme.of(context).colorScheme.onBackground,
                    size: 35,
                  ),
                ))),
      ]),
      Padding(
          // Item name
          padding:
              const EdgeInsets.only(top: 40, left: 30, right: 30, bottom: 10),
          child: Text(
            widget.itemname,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline2,
          )),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        //Display restuarant category(ies)
        Text(widget.foodcategory, //Must have food category
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(color: Theme.of(context).textTheme.headline1!.color)),
        LayoutBuilder(builder: (context, constraints) {
          if (widget.subfoodcategory != "") {
            //If there is a subcategory, display it with a dot next to it
            //If there is a sub food category, show it
            return Text(" · ${widget.subfoodcategory}",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6!.copyWith(
                    color: Theme.of(context).textTheme.headline1!.color));
          } else {
            // If there is no sub-category, dont display anything
            //If there isnt a sub-food category, dont show it
            return const Text("");
          }
        })
      ]),
      Padding(
        //Display item description
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Text(
          widget.description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
              color: Theme.of(context).textTheme.headline6!.color,
              fontWeight: FontWeight.w400),
        ),
      ),
      FutureBuilder<Map>(
          future: getCustomiseOptions(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Map customiseData = snapshot.data ?? [] as Map;
              if (customiseData["error"] == true) {
                //Check if there was an error getting the data from the server
                return Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Theme.of(context).colorScheme.onSurface),
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                  child: Text(
                    customiseData["message"], //Return that there was an error
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                );
              } else {
                if (beenMade == false) {
                  for (int i = 0; i < customiseData["customise"].length; i++) {
                    customisedOptions[customiseData["customise"][i][0]] = [];
                  }
                  beenMade = true;
                }

                //If there was not an error getting the data
                if (customiseData["customise"].length == 0) {
                  //if there is no customise options, return nothing
                  return const SizedBox(
                    height: 1,
                  );
                } else {
                  //If there are customise options, return customise options
                  return ListView.builder(
                      physics:
                          const NeverScrollableScrollPhysics(), //Disable scrolling. Scroll with whole page
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: (customiseData[
                              "customise"] //For each item, create a container
                          .length),
                      itemBuilder: ((context, index) {
                        if (customiseData["customise"][index][4] == "1" &&
                            !requiredFields.contains(
                                customiseData["customise"][index][0])) {
                          requiredFields
                              .add(customiseData["customise"][index][0]);
                        }
                        return Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 10,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onBackground
                                  .withOpacity(0.1),
                            ),
                            LayoutBuilder(builder: ((context, constraints) {
                              if (customiseData["customise"][index][3] ==
                                  "SELECT") {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          top: 30,
                                          bottom: 10),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                  Text(
                                                    customiseData["customise"]
                                                            [index][1]
                                                        .toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline5,
                                                    overflow:
                                                        TextOverflow.visible,
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    customiseData["customise"]
                                                        [index][2],
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline5,
                                                    overflow:
                                                        TextOverflow.visible,
                                                  )
                                                ])),
                                            const SizedBox(width: 30),
                                            LayoutBuilder(builder:
                                                ((context, constraints) {
                                              if (customiseData["customise"]
                                                      [index][4] ==
                                                  "0") {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .tertiary
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20,
                                                      vertical: 5),
                                                  child: Text(
                                                    "Optional",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6
                                                        ?.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .tertiary),
                                                  ),
                                                );
                                              } else if (customiseData[
                                                      "customise"][index][4] ==
                                                  "1") {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20,
                                                      vertical: 5),
                                                  child: Text(
                                                    "Required",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6
                                                        ?.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                  ),
                                                );
                                              } else {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .error
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20,
                                                      vertical: 5),
                                                  child: Text(
                                                    "ERROR",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6
                                                        ?.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .error),
                                                  ),
                                                );
                                              }
                                            }))
                                          ]),
                                    ),
                                    ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(), //Disable scrolling. Scroll with whole page
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: customiseData["customise"]
                                                [index][7]
                                            .length,
                                        itemBuilder: ((context, index2) {
                                          return Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 5),
                                              child: ElevatedButton(
                                                  style: ButtonStyle(
                                                      side: (customisedOptions[customiseData["customise"][index][0]].contains(
                                                              customiseData["customise"]
                                                                      [index][7]
                                                                  [index2][0]))
                                                          ? MaterialStateProperty.all(BorderSide(
                                                              width: 2,
                                                              color: Theme.of(context)
                                                                  .primaryColor))
                                                          : null,
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 30, vertical: 20)),
                                                      textStyle: (customisedOptions[customiseData["customise"][index][0]].contains(customiseData["customise"][index][7][index2][0])) ? MaterialStateProperty.all(Theme.of(context).textTheme.headline6?.copyWith(color: Theme.of(context).textTheme.headline1?.color)) : MaterialStateProperty.all(Theme.of(context).textTheme.headline6),
                                                      backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onSurface)),
                                                  onPressed: () {
                                                    if (customisedOptions[customiseData["customise"][index][0]]
                                                                .length <
                                                            int.parse(
                                                                customiseData["customise"]
                                                                        [index]
                                                                    [6]) &&
                                                        !customisedOptions[
                                                                customiseData["customise"]
                                                                    [index][0]]
                                                            .contains(
                                                                customiseData["customise"]
                                                                        [index][7]
                                                                    [index2][0])) {
                                                      setState(() {
                                                        customisedOptions[
                                                                customiseData[
                                                                        "customise"]
                                                                    [index][0]]
                                                            .add(customiseData[
                                                                        "customise"]
                                                                    [index][7]
                                                                [index2][0]);
                                                        changingPrice += double
                                                            .parse(customiseData[
                                                                        "customise"]
                                                                    [index][7]
                                                                [index2][3]);
                                                      });
                                                    } else if (customisedOptions[
                                                            customiseData[
                                                                    "customise"]
                                                                [index][0]]
                                                        .contains(customiseData[
                                                                    "customise"]
                                                                [index][7]
                                                            [index2][0])) {
                                                      setState(() {
                                                        customisedOptions[
                                                                customiseData[
                                                                        "customise"]
                                                                    [index][0]]
                                                            .remove(customiseData[
                                                                            "customise"]
                                                                        [index][
                                                                    7][index2][0]
                                                                .toString());
                                                        changingPrice -= double
                                                            .parse(customiseData[
                                                                        "customise"]
                                                                    [index][7]
                                                                [index2][3]);
                                                      });
                                                    }
                                                  },
                                                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                    Expanded(
                                                        child: Text(
                                                      customiseData["customise"]
                                                          [index][7][index2][1],
                                                      style: (customisedOptions[
                                                                  customiseData["customise"]
                                                                          [index]
                                                                      [0]]
                                                              .contains(customiseData["customise"]
                                                                      [index][7]
                                                                  [index2][0]))
                                                          ? Theme.of(context)
                                                              .textTheme
                                                              .headline6
                                                              ?.copyWith(
                                                                  color: Theme.of(context)
                                                                      .textTheme
                                                                      .headline1
                                                                      ?.color)
                                                          : Theme.of(context)
                                                              .textTheme
                                                              .headline6,
                                                    )),
                                                    LayoutBuilder(
                                                        builder: ((p0, p1) {
                                                      if (customiseData[
                                                                      "customise"]
                                                                  [index][7]
                                                              [index2][3] !=
                                                          "0.00") {
                                                        return Text(
                                                          "+${customiseData["customise"][index][7][index2][3]}",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .headline6
                                                              ?.copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .error),
                                                        );
                                                      } else {
                                                        return Text(
                                                          "-",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .headline6
                                                              ?.copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onBackground
                                                                      .withOpacity(
                                                                          0.5)),
                                                        );
                                                      }
                                                    }))
                                                  ])));
                                        })),
                                    const SizedBox(height: 50)
                                  ],
                                );
                              } else if (customiseData["customise"][index][3] ==
                                  "ADD") {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          top: 30,
                                          bottom: 10),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                  Text(
                                                    customiseData["customise"]
                                                            [index][1]
                                                        .toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline5,
                                                    overflow:
                                                        TextOverflow.visible,
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    customiseData["customise"]
                                                        [index][2],
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6,
                                                    overflow:
                                                        TextOverflow.visible,
                                                  ),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                ])),
                                            const SizedBox(width: 30),
                                            LayoutBuilder(builder:
                                                ((context, constraints) {
                                              if (customiseData["customise"]
                                                      [index][4] ==
                                                  "0") {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .tertiary
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20,
                                                      vertical: 5),
                                                  child: Text(
                                                    "Optional",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6
                                                        ?.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .tertiary),
                                                  ),
                                                );
                                              } else if (customiseData[
                                                      "customise"][index][4] ==
                                                  "1") {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20,
                                                      vertical: 5),
                                                  child: Text(
                                                    "Required",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6
                                                        ?.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                  ),
                                                );
                                              } else {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .error
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20,
                                                      vertical: 5),
                                                  child: Text(
                                                    "ERROR",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6
                                                        ?.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .error),
                                                  ),
                                                );
                                              }
                                            }))
                                          ]),
                                    ),
                                    ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(), //Disable scrolling. Scroll with whole page
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: customiseData["customise"]
                                                [index][7]
                                            .length,
                                        itemBuilder: ((context, index2) {
                                          return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 5),
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                    side: (customisedOptions[customiseData["customise"][index][0]].contains(customiseData["customise"][index][7][index2][0]))
                                                        ? MaterialStateProperty.all(BorderSide(
                                                            width: 2,
                                                            color: Theme.of(context)
                                                                .primaryColor))
                                                        : null,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    padding: MaterialStateProperty.all(
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 30,
                                                            vertical: 20)),
                                                    textStyle: (customisedOptions[customiseData["customise"][index][0]].contains(customiseData["customise"][index][7][index2][0])) ? MaterialStateProperty.all(Theme.of(context).textTheme.headline6?.copyWith(color: Theme.of(context).textTheme.headline1?.color)) : MaterialStateProperty.all(Theme.of(context).textTheme.headline6),
                                                    backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onSurface)),
                                                onPressed: () {
                                                  if (customisedOptions[customiseData["customise"][index][0]]
                                                              .length <
                                                          int.parse(customiseData[
                                                                  "customise"]
                                                              [index][6]) &&
                                                      !customisedOptions[
                                                              customiseData["customise"]
                                                                  [index][0]]
                                                          .contains(
                                                              customiseData["customise"]
                                                                      [index][7]
                                                                  [index2])) {
                                                    setState(() {
                                                      customisedOptions[
                                                              customiseData[
                                                                      "customise"]
                                                                  [index][0]]
                                                          .add(customiseData[
                                                                      "customise"]
                                                                  [index][7]
                                                              [index2][0]);
                                                      changingPrice += double
                                                          .parse(customiseData[
                                                                      "customise"]
                                                                  [index][7]
                                                              [index2][3]);
                                                    });
                                                  }
                                                },
                                                child: LayoutBuilder(builder:
                                                    ((context, constraints) {
                                                  int count = 0;
                                                  for (int i = 0;
                                                      i <
                                                          customisedOptions[
                                                                  customiseData[
                                                                          "customise"]
                                                                      [
                                                                      index][0]]
                                                              .length;
                                                      i++) {
                                                    if (customisedOptions[
                                                            customiseData[
                                                                    "customise"]
                                                                [
                                                                index][0]][i] ==
                                                        customiseData[
                                                                    "customise"]
                                                                [index][7]
                                                            [index2][0]) {
                                                      count += 1;
                                                    }
                                                  }
                                                  if (count == 0) {
                                                    return Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .add_box_outlined,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .tertiary,
                                                          ),
                                                          const SizedBox(
                                                              width: 30),
                                                          Expanded(
                                                              child: Text(
                                                            customiseData[
                                                                        "customise"]
                                                                    [index][7]
                                                                [index2][1],
                                                            style: (customisedOptions[
                                                                        customiseData["customise"][index]
                                                                            [0]]
                                                                    .contains(customiseData["customise"][index][7]
                                                                            [index2]
                                                                        [0]))
                                                                ? Theme.of(context)
                                                                    .textTheme
                                                                    .headline6
                                                                    ?.copyWith(
                                                                        color: Theme.of(context)
                                                                            .textTheme
                                                                            .headline1
                                                                            ?.color)
                                                                : Theme.of(context)
                                                                    .textTheme
                                                                    .headline6,
                                                          )),
                                                          const SizedBox(
                                                              width: 20),
                                                          LayoutBuilder(builder:
                                                              ((p0, p1) {
                                                            if (customiseData[
                                                                            "customise"]
                                                                        [
                                                                        index][7]
                                                                    [
                                                                    index2][3] !=
                                                                "0.00") {
                                                              return Text(
                                                                "+${customiseData["customise"][index][7][index2][3]}",
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .headline6
                                                                    ?.copyWith(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .error),
                                                              );
                                                            } else {
                                                              return Text(
                                                                "-",
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .headline6
                                                                    ?.copyWith(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .onBackground
                                                                            .withOpacity(0.5)),
                                                              );
                                                            }
                                                          }))
                                                        ]);
                                                  } else {
                                                    return Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 15,
                                                            backgroundColor:
                                                                Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .tertiary
                                                                    .withOpacity(
                                                                        0.5),
                                                            child: Text(
                                                                count
                                                                    .toString(),
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .headline6
                                                                    ?.copyWith(
                                                                        color: Theme.of(context)
                                                                            .textTheme
                                                                            .headline1
                                                                            ?.color)),
                                                          ),
                                                          const SizedBox(
                                                            width: 30,
                                                          ),
                                                          Expanded(
                                                              child: Text(
                                                            customiseData[
                                                                        "customise"]
                                                                    [index][7]
                                                                [index2][1],
                                                            style: (customisedOptions[
                                                                        customiseData["customise"][index]
                                                                            [0]]
                                                                    .contains(customiseData["customise"][index][7]
                                                                            [index2]
                                                                        [0]))
                                                                ? Theme.of(context)
                                                                    .textTheme
                                                                    .headline6
                                                                    ?.copyWith(
                                                                        color: Theme.of(context)
                                                                            .textTheme
                                                                            .headline1
                                                                            ?.color)
                                                                : Theme.of(context)
                                                                    .textTheme
                                                                    .headline6,
                                                          )),
                                                          const SizedBox(
                                                              width: 20),
                                                          IconButton(
                                                            icon: const Icon(
                                                                Icons.delete),
                                                            splashRadius: 15,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .error,
                                                            onPressed: () {
                                                              setState(() {
                                                                customisedOptions[
                                                                        customiseData["customise"][index]
                                                                            [0]]
                                                                    .remove(customiseData["customise"][index][7]
                                                                            [
                                                                            index2][0]
                                                                        .toString());
                                                                changingPrice -=
                                                                    double.parse(customiseData["customise"]
                                                                            [
                                                                            index][7]
                                                                        [
                                                                        index2][3]);
                                                              });
                                                            },
                                                          ),
                                                        ]);
                                                  }
                                                })),
                                              ));
                                        })),
                                    const SizedBox(height: 50)
                                  ],
                                );
                              } else if (customiseData["customise"][index][3] ==
                                  "REMOVE") {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          top: 30,
                                          bottom: 10),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                  Text(
                                                    customiseData["customise"]
                                                            [index][1]
                                                        .toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline5,
                                                    overflow:
                                                        TextOverflow.visible,
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    customiseData["customise"]
                                                        [index][2],
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6,
                                                    overflow:
                                                        TextOverflow.visible,
                                                  ),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                ])),
                                            const SizedBox(width: 30),
                                            LayoutBuilder(builder:
                                                ((context, constraints) {
                                              if (customiseData["customise"]
                                                      [index][4] ==
                                                  "0") {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .tertiary
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20,
                                                      vertical: 5),
                                                  child: Text(
                                                    "Optional",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6
                                                        ?.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .tertiary),
                                                  ),
                                                );
                                              } else if (customiseData[
                                                      "customise"][index][4] ==
                                                  "1") {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20,
                                                      vertical: 5),
                                                  child: Text(
                                                    "Required",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6
                                                        ?.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                  ),
                                                );
                                              } else {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .error
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20,
                                                      vertical: 5),
                                                  child: Text(
                                                    "ERROR",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6
                                                        ?.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .error),
                                                  ),
                                                );
                                              }
                                            }))
                                          ]),
                                    ),
                                    ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(), //Disable scrolling. Scroll with whole page
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: customiseData["customise"]
                                                [index][7]
                                            .length,
                                        itemBuilder: ((context, index2) {
                                          return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 5),
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                    side: (customisedOptions[customiseData["customise"][index][0]].contains(customiseData["customise"][index][7][index2][0]))
                                                        ? MaterialStateProperty.all(BorderSide(
                                                            width: 2,
                                                            color: Theme.of(context)
                                                                .primaryColor))
                                                        : null,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    padding: MaterialStateProperty.all(
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 30,
                                                            vertical: 20)),
                                                    textStyle: (customisedOptions[customiseData["customise"][index][0]].contains(customiseData["customise"][index][7][index2][0])) ? MaterialStateProperty.all(Theme.of(context).textTheme.headline6?.copyWith(color: Theme.of(context).textTheme.headline1?.color)) : MaterialStateProperty.all(Theme.of(context).textTheme.headline6),
                                                    backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onSurface)),
                                                onPressed: () {
                                                  if (customisedOptions[customiseData["customise"][index][0]]
                                                              .length <
                                                          int.parse(customiseData[
                                                                  "customise"]
                                                              [index][6]) &&
                                                      !customisedOptions[
                                                              customiseData["customise"]
                                                                  [index][0]]
                                                          .contains(
                                                              customiseData["customise"]
                                                                      [index][7]
                                                                  [index2])) {
                                                    setState(() {
                                                      customisedOptions[
                                                              customiseData[
                                                                      "customise"]
                                                                  [index][0]]
                                                          .add(customiseData[
                                                                      "customise"]
                                                                  [index][7]
                                                              [index2][0]);
                                                      changingPrice -= double
                                                          .parse(customiseData[
                                                                      "customise"]
                                                                  [index][7]
                                                              [index2][3]);
                                                    });
                                                  }
                                                },
                                                child: LayoutBuilder(builder:
                                                    ((context, constraints) {
                                                  int count = 0;
                                                  for (int i = 0;
                                                      i <
                                                          customisedOptions[
                                                                  customiseData[
                                                                          "customise"]
                                                                      [
                                                                      index][0]]
                                                              .length;
                                                      i++) {
                                                    if (customisedOptions[
                                                            customiseData[
                                                                    "customise"]
                                                                [
                                                                index][0]][i] ==
                                                        customiseData[
                                                                    "customise"]
                                                                [index][7]
                                                            [index2][0]) {
                                                      count += 1;
                                                    }
                                                  }
                                                  if (count == 0) {
                                                    return Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .disabled_by_default_outlined,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .error,
                                                          ),
                                                          const SizedBox(
                                                              width: 30),
                                                          Expanded(
                                                              child: Text(
                                                            customiseData[
                                                                        "customise"]
                                                                    [index][7]
                                                                [index2][1],
                                                            style: (customisedOptions[
                                                                        customiseData["customise"][index]
                                                                            [0]]
                                                                    .contains(customiseData["customise"][index][7]
                                                                            [index2]
                                                                        [0]))
                                                                ? Theme.of(context)
                                                                    .textTheme
                                                                    .headline6
                                                                    ?.copyWith(
                                                                        color: Theme.of(context)
                                                                            .textTheme
                                                                            .headline1
                                                                            ?.color)
                                                                : Theme.of(context)
                                                                    .textTheme
                                                                    .headline6,
                                                          )),
                                                          const SizedBox(
                                                              width: 20),
                                                          LayoutBuilder(builder:
                                                              ((p0, p1) {
                                                            if (customiseData[
                                                                            "customise"]
                                                                        [
                                                                        index][7]
                                                                    [
                                                                    index2][3] !=
                                                                "0.00") {
                                                              return Text(
                                                                "-${customiseData["customise"][index][7][index2][3]}",
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .headline6
                                                                    ?.copyWith(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .tertiary),
                                                              );
                                                            } else {
                                                              return Text(
                                                                "-",
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .headline6
                                                                    ?.copyWith(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .onBackground
                                                                            .withOpacity(0.5)),
                                                              );
                                                            }
                                                          }))
                                                        ]);
                                                  } else {
                                                    return Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 15,
                                                            backgroundColor:
                                                                Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .error
                                                                    .withOpacity(
                                                                        0.5),
                                                            child: Text(
                                                                count
                                                                    .toString(),
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .headline6
                                                                    ?.copyWith(
                                                                        color: Theme.of(context)
                                                                            .textTheme
                                                                            .headline1
                                                                            ?.color)),
                                                          ),
                                                          const SizedBox(
                                                            width: 30,
                                                          ),
                                                          Expanded(
                                                              child: Text(
                                                            customiseData[
                                                                        "customise"]
                                                                    [index][7]
                                                                [index2][1],
                                                            style: (customisedOptions[
                                                                        customiseData["customise"][index]
                                                                            [0]]
                                                                    .contains(customiseData["customise"][index][7]
                                                                            [index2]
                                                                        [0]))
                                                                ? Theme.of(context)
                                                                    .textTheme
                                                                    .headline6
                                                                    ?.copyWith(
                                                                        color: Theme.of(context)
                                                                            .textTheme
                                                                            .headline1
                                                                            ?.color)
                                                                : Theme.of(context)
                                                                    .textTheme
                                                                    .headline6,
                                                          )),
                                                          const SizedBox(
                                                              width: 20),
                                                          IconButton(
                                                            icon: const Icon(
                                                                Icons.delete),
                                                            splashRadius: 15,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .error,
                                                            onPressed: () {
                                                              setState(() {
                                                                customisedOptions[
                                                                        customiseData["customise"][index]
                                                                            [0]]
                                                                    .remove(customiseData["customise"][index][7]
                                                                            [
                                                                            index2][0]
                                                                        .toString());
                                                                changingPrice +=
                                                                    double.parse(customiseData["customise"]
                                                                            [
                                                                            index][7]
                                                                        [
                                                                        index2][3]);
                                                              });
                                                            },
                                                          ),
                                                        ]);
                                                  }
                                                })),
                                              ));
                                        })),
                                    const SizedBox(height: 50)
                                  ],
                                );
                              } else {
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 30, horizontal: 20),
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface),
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 30),
                                  child: Text(
                                    "Unknown Customise Option", //Return that there was an error
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                );
                              }
                            }))
                          ],
                        );
                      }));
                }
              }
            } else {
              //While loading, return progress indicator
              return const LinearProgressIndicator(
                  color: Color(0xff4100C4), backgroundColor: Color(0xffEBE0FF));
            }
          }),

      //Add to cart and quantity
      LayoutBuilder(builder: ((context, constraints) {
        finalSinglePrice =
            ((double.parse(widget.price) * 100) + (changingPrice * 100)) / 100;
        quantityPrice = finalSinglePrice * quantity;

        return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text("£${finalSinglePrice.toStringAsFixed(2)}",
              style: Theme.of(context).textTheme.headline4),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).colorScheme.onSurface,
                      child: IconButton(
                        icon: const Icon(Icons.remove),
                        iconSize: 25,
                        color: (quantity == 1)
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Theme.of(context).primaryColor,
                        onPressed: () {
                          if (quantity != 1) {
                            setState(() {
                              quantity -= 1;
                            });
                          }
                        },
                      )),
                  const SizedBox(
                    width: 30,
                  ),
                  SizedBox(
                      width: 30,
                      child: Text(
                        quantity.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline3,
                      )),
                  const SizedBox(
                    width: 30,
                  ),
                  CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).colorScheme.onSurface,
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        iconSize: 25,
                        color: (quantity == 99)
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Theme.of(context).primaryColor,
                        onPressed: () {
                          if (quantity != 99) {
                            setState(() {
                              quantity += 1;
                            });
                          }
                        },
                      )),
                ],
              )),
          Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                Expanded(child: LayoutBuilder(builder: ((context, constraints) {
                  bool tempCheckRequiredFilled = true;
                  for (int i = 0; i < requiredFields.length; i++) {
                    if (customisedOptions[requiredFields[i]].isEmpty) {
                      tempCheckRequiredFilled = false;
                    }
                  }
                  if (tempCheckRequiredFilled == true) {
                    return ElevatedButton(
                        onPressed: () async {
                          bool isAddedToCart = await addToCart();
                          if (isAddedToCart == true) {
                            setState(() {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Successfully added to Cart")));
                            });
                          } else {
                            setState(() {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Failed to add to Cart")));
                            });
                          }
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Add to Cart"),
                              Text("£${quantityPrice.toStringAsFixed(2)}")
                            ]));
                  } else {
                    return Opacity(
                        opacity: 0.2,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    Theme.of(context)
                                        .colorScheme
                                        .onBackground)),
                            onPressed: () {},
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Add to Cart"),
                                  Text("£${quantityPrice.toStringAsFixed(2)}")
                                ])));
                  }
                })))
              ])),
          const SizedBox(height: 20),
        ]);
      }))
    ])));
  }
}

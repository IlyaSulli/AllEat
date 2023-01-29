import 'package:alleat/services/cart_service.dart';
import 'package:alleat/services/localprofiles_service.dart';
import 'package:alleat/services/queryserver.dart';
import 'package:alleat/widgets/elements/elements.dart';
import 'package:alleat/widgets/genericlocading.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  List finalCartData = [];
  Future<List> getAvailableProfiles() async {
    List availableProfiles = [];
    List cartProfileIDs = await SQLiteCartItems.getProfilesInCart(); //Get profile ids that are in the cart
    List profileInfo = await SQLiteLocalProfiles.getProfiles();

    //Got profiles
    for (int i = 0; i < cartProfileIDs.length; i++) {
      for (int j = 0; j < profileInfo.length; j++) {
        if (cartProfileIDs[i] == profileInfo[j]["profileid"]) {
          availableProfiles.add([
            profileInfo[j]["profileid"],
            profileInfo[j]["firstname"],
            profileInfo[j]["lastname"],
            profileInfo[j]["profilecolorred"],
            profileInfo[j]["profilecolorgreen"],
            profileInfo[j]["profilecolorblue"]
          ]);
        }
      }
    }
    return availableProfiles;
  }

  //Remove Item
  Future<bool> removeItem(cartID) async {
    try {
      await SQLiteCartItems.removeItem(cartID);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map> getProfileCart(profileID) async {
    Map returnItemList = {"error": false, "message": "", "iteminfo": {}};
    Map tempItemInfo = {};

    List profileCart = await SQLiteCartItems.getProfileCart(profileID); //{cartid, itemid, customised, quantity}
    for (int i = 0; i < profileCart.length; i++) {
      // For each item, add it as an index i
      tempItemInfo[profileCart[i]["itemid"]] = [[], {}];

      Map basicItemInfo = await QueryServer.query("https://alleat.cpur.net/query/cartiteminfo.php", {
        "type": "item",
        "term": profileCart[i]["itemid"].toString()
      }); //returns item id, item name, price, item image, restaurant id, restaurant name, delivery price

      if (basicItemInfo["error"] == true) {
        returnItemList["error"] = true;
        returnItemList["message"] = basicItemInfo["message"];
        return returnItemList;
      } else {
        tempItemInfo[profileCart[i]["itemid"]][0].addAll([
          basicItemInfo["message"]["message"][1],
          basicItemInfo["message"]["message"][3],
          basicItemInfo["message"]["message"][2],
          basicItemInfo["message"]["message"][5],
          basicItemInfo["message"]["message"][4],
          basicItemInfo["message"]["message"][6],
          profileCart[i]["quantity"],
          profileCart[i]["cartid"],
        ]);

        Map customised = json.decode(profileCart[i]["customised"]);
        List customisedtitleids = customised.keys.toList(); //Each customise title is stored here
        List customisedOptions = []; //Each unique option stored here
        Map updatedCustomised = {}; //Data that will be sent back in the iteminfo key, correctly formatted
        for (int i = 0; i < customisedtitleids.length; i++) {
          //For each customise title
          updatedCustomised[customisedtitleids[i]] = [[], []]; //Add customised key to new Map
          for (int j = 0; j < customised[customisedtitleids[i]].length; j++) {
            //For each item in list of customised options for customise title
            if (!customisedOptions.contains(customised[customisedtitleids[i]][j])) {
              //If the option is not in the list of options, add it to the list
              updatedCustomised[customisedtitleids[i]][1].add([customised[customisedtitleids[i]][j], 1]);
              customisedOptions.add(customised[customisedtitleids[i]][j]);
            } else {
              for (int k = 0; k < updatedCustomised[customisedtitleids[i]][1].length; k++) {
                if (updatedCustomised[customisedtitleids[i]][1][k][0] == customised[customisedtitleids[i]][j]) {
                  updatedCustomised[customisedtitleids[i]][1][k][1] += 1;
                }
              }
            }
          }
        }
        try {
          if (customisedtitleids.isNotEmpty) {
            Map customisedTitlesInfo =
                await QueryServer.query("https://alleat.cpur.net/query/cartiteminfo.php", {"type": "title", "term": json.encode(customisedtitleids)});

            if (customisedTitlesInfo["error"] == true) {
              returnItemList["error"] = true;
              returnItemList["message"] = customisedTitlesInfo["message"];
              return returnItemList;
            } else {
              List customisedTitlesInfoFormatted = customisedTitlesInfo["message"]["message"];
              if (customisedOptions.isNotEmpty) {
                Map customisedOptionInfo = await QueryServer.query(
                    "https://alleat.cpur.net/query/cartiteminfo.php", {"type": "option", "term": customisedOptions.toString()});

                if (customisedOptionInfo["error"] == true) {
                  returnItemList["error"] = true;
                  returnItemList["message"] = customisedOptionInfo["message"];
                  return returnItemList;
                } else {
                  List customisedOptionInfoFormatted = customisedOptionInfo["message"]["message"];

                  for (int i = 0; i < customisedtitleids.length; i++) {
                    // For each customise title
                    for (int j = 0; j < customisedTitlesInfoFormatted.length; j++) {
                      //For each item in list of returned from server info about each title
                      if (customisedTitlesInfoFormatted[j][0] == customisedtitleids[i]) {
                        // If it has the id of the title in the first index, add the info to the composite info
                        updatedCustomised[customisedtitleids[i]][0]
                            .addAll([customisedTitlesInfoFormatted[j][1], customisedTitlesInfoFormatted[j][2]]);
                      }
                    }
                    for (int j = 0; j < updatedCustomised[customisedtitleids[i]][1].length; j++) {
                      //For each option in the list of options for each title
                      for (int k = 0; k < customisedOptionInfoFormatted.length; k++) {
                        //For each item in list of returned from server about option info
                        if (customisedOptionInfoFormatted[k][0] == updatedCustomised[customisedtitleids[i]][1][j][0]) {
                          // If it has the id of the option in the first index, add the info to the list
                          updatedCustomised[customisedtitleids[i]][1][j]
                              .addAll([customisedOptionInfoFormatted[k][1], customisedOptionInfoFormatted[k][2]]);
                        }
                      }
                    }
                  }
                  tempItemInfo[profileCart[i]["itemid"]][1] = updatedCustomised;
                }
              }
            }
          }
        } catch (e) {
          returnItemList["error"] = true;
          returnItemList["message"] = "An error occurred while attempting to process the item information.";
        }
      }
    }
    returnItemList["iteminfo"] = tempItemInfo;
    return returnItemList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
        future: getAvailableProfiles(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            List availableProfiles = snapshot.data ?? [];
            if (availableProfiles.isNotEmpty) {
              for (int p = 0; p < availableProfiles.length; p++) {
                finalCartData.addAll([
                  [
                    availableProfiles[p][0],
                    availableProfiles[p][1],
                    availableProfiles[p][2],
                    availableProfiles[p][3],
                    availableProfiles[p][4],
                    availableProfiles[p][5],
                    0.00,
                    {}
                  ]
                ]);
              }
  
              return Scaffold(
                  body: SingleChildScrollView(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const ScreenBackButton(),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 20, top: 20),
                      child: Text("Cart.", style: Theme.of(context).textTheme.headline2),
                    ),
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(), //Dont allow scrolling (Done by main page)
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: availableProfiles.length, //For each profile
                        itemBuilder: (context, avPrIndex) {
                          return Column(children: [
                            Container(
                                //Contain the profile within a container
                                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: Row(
                                  children: [
                                    Container(
                                        // Create profile circle with first and last letter
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color.fromRGBO(availableProfiles[avPrIndex][3], availableProfiles[avPrIndex][4],
                                                availableProfiles[avPrIndex][5], 1)),
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Text('${availableProfiles[avPrIndex][1][0]}${availableProfiles[avPrIndex][2][0]}',
                                                style: Theme.of(context).textTheme.headline6?.copyWith(color: Theme.of(context).backgroundColor)))),
                                    const SizedBox(width: 20), //Profile firstname and lastname

                                    Text(
                                      "${availableProfiles[avPrIndex][1]} ${availableProfiles[avPrIndex][2]}",
                                      style: Theme.of(context).textTheme.headline5?.copyWith(color: Theme.of(context).textTheme.headline1?.color),
                                      overflow: TextOverflow.fade,
                                    )
                                  ],
                                )),
                            Divider(
                              thickness: 2,
                              color: Theme.of(context).textTheme.headline6?.color?.withOpacity(0.5),
                              indent: 40,
                              endIndent: 40,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            FutureBuilder<Map>(
                                future: getProfileCart(availableProfiles[avPrIndex][0]),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    List profileCart = [snapshot.data ?? []];
                                    if (profileCart[0]["error"] == true) {
                                      return Padding(
                                          padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                                                  color: Theme.of(context).colorScheme.onSurface,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.1),
                                                      spreadRadius: 2,
                                                      blurRadius: 10,
                                                      offset: const Offset(0, 10), // changes position of shadow
                                                    ),
                                                  ]),
                                              child: Column(children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(30),
                                                  child: SizedBox(
                                                      width: double.infinity,
                                                      child: Center(
                                                          child: Column(children: [
                                                        const Text(
                                                          "An error has occurred.",
                                                          textAlign: TextAlign.center,
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        Text(
                                                          profileCart[0]["message"],
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ]))),
                                                )
                                              ])));
                                    } else {
                                      List itemKeyValues = profileCart[0]["iteminfo"].keys.toList();
                                      return ListView.builder(
                                          physics: const NeverScrollableScrollPhysics(), //Dont allow scrolling (Done by main page)
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          itemCount: itemKeyValues.length, //For each item
                                          itemBuilder: (context, indexItem) {
                                            List currentItem = profileCart[0]["iteminfo"][itemKeyValues[indexItem]];
                                            double itemPrice = double.parse(currentItem[0][2]);

                                            for (int l = 0; l < finalCartData.length; l++) {
                                              if (finalCartData[l][0].toString() == availableProfiles[avPrIndex][0].toString()) {
                                                finalCartData[l][6] = (finalCartData[l][6] * 100 + itemPrice * 100) / 100;
                                              }
                                            }

                                            return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                                child: Dismissible(
                                                    key: Key(currentItem[0][7].toString()),
                                                    onDismissed: (direction) async {
                                                      bool hasDeleted = await removeItem(currentItem[0][7]);
                                                      setState(() {
                                                        profileCart[0]["iteminfo"].remove(itemKeyValues[indexItem]);
                                                        if (hasDeleted) {
                                                          ScaffoldMessenger.of(context)
                                                              .showSnackBar(const SnackBar(content: Text("Successfully deleted item.")));
                                                        } else {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(content: Text("Failed to remove. Reopen cart and try again.")));
                                                        }
                                                      });
                                                    },
                                                    background: Container(
                                                        color: Theme.of(context).colorScheme.error,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                                                child: Icon(
                                                                  Icons.delete,
                                                                  color: Theme.of(context).colorScheme.onSurface,
                                                                )),
                                                            Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                                                child: Icon(
                                                                  Icons.delete,
                                                                  color: Theme.of(context).colorScheme.onSurface,
                                                                ))
                                                          ],
                                                        )),
                                                    child: Container(
                                                        width: double.infinity,
                                                        decoration: BoxDecoration(
                                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                            color: Theme.of(context).colorScheme.onSurface),
                                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                                        child: Column(children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 80,
                                                                height: 80,
                                                                decoration: BoxDecoration(
                                                                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                                                                    image: DecorationImage(
                                                                        fit: BoxFit.cover, image: NetworkImage(currentItem[0][1].toString()))),
                                                              ),
                                                              const SizedBox(
                                                                width: 20,
                                                              ),
                                                              Container(
                                                                  alignment: Alignment.center,
                                                                  height: 30,
                                                                  width: 30,
                                                                  decoration: BoxDecoration(
                                                                      color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(30)),
                                                                  child: Text(
                                                                    currentItem[0][6].toString(),
                                                                    style: Theme.of(context)
                                                                        .textTheme
                                                                        .headline6
                                                                        ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                                                                  )),
                                                              const SizedBox(
                                                                width: 20,
                                                              ),
                                                              Expanded(
                                                                  child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    currentItem[0][0],
                                                                    style: Theme.of(context)
                                                                        .textTheme
                                                                        .headline6
                                                                        ?.copyWith(color: Theme.of(context).textTheme.headline1?.color),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Text(
                                                                    currentItem[0][3],
                                                                    style: Theme.of(context)
                                                                        .textTheme
                                                                        .bodyText1
                                                                        ?.copyWith(color: Theme.of(context).textTheme.headline6?.color),
                                                                  )
                                                                ],
                                                              ))
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          LayoutBuilder(
                                                            builder: (BuildContext context, BoxConstraints constraints) {
                                                              List customiseIDs = Map.from(currentItem[1]).keys.toList();
                                                              return ListView.builder(
                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                  shrinkWrap: true,
                                                                  itemCount: customiseIDs.length,
                                                                  itemBuilder: (context, i) {
                                                                    if (customiseIDs.length - 1 == i &&
                                                                        availableProfiles.length - 1 == avPrIndex &&
                                                                        itemKeyValues.length - 1 == indexItem) {
                                                                    }
                                                                    if (currentItem[1][customiseIDs[i]][0][1] == "SELECT" &&
                                                                        currentItem[1][customiseIDs[i]][1].isNotEmpty) {
                                                                      for (int s = 0; s < currentItem[1][customiseIDs[i]][1].length; s++) {
                                                                        itemPrice = ((itemPrice * 100) +
                                                                                double.parse(currentItem[1][customiseIDs[i]][1][s][3]) * 100) /
                                                                            100;
                                                                        for (int l = 0; l < finalCartData.length; l++) {
                                                                          if (finalCartData[l][0].toString() ==
                                                                              availableProfiles[avPrIndex][0].toString()) {
                                                                            finalCartData[l][6] = (finalCartData[l][6] * 100 +
                                                                                    double.parse(currentItem[1][customiseIDs[i]][1][s][3]) * 100) /
                                                                                100;
                                                                          }
                                                                        }
                                                                      }

                                                                      return Container(
                                                                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                                                          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                                                                          decoration: BoxDecoration(
                                                                              color: Theme.of(context).backgroundColor.withOpacity(0.5),
                                                                              border: Border.all(
                                                                                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
                                                                                  width: 1),
                                                                              borderRadius: BorderRadius.circular(10)),
                                                                          child: Column(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(currentItem[1][customiseIDs[i]][0][0],
                                                                                    textAlign: TextAlign.start,
                                                                                    style: Theme.of(context).textTheme.headline6?.copyWith(
                                                                                        color: Theme.of(context).textTheme.headline1?.color)),
                                                                                const SizedBox(height: 15),
                                                                                ListView.builder(
                                                                                    physics: const NeverScrollableScrollPhysics(),
                                                                                    shrinkWrap: true,
                                                                                    itemCount: currentItem[1][customiseIDs[i]][1].length,
                                                                                    itemBuilder: (context, index) {
                                                                                      return Padding(
                                                                                        padding: const EdgeInsets.only(left: 10, bottom: 10),
                                                                                        child: Row(children: [
                                                                                          CircleAvatar(
                                                                                            backgroundColor:
                                                                                                Theme.of(context).primaryColor.withOpacity(0.5),
                                                                                            radius: 10,
                                                                                            child: Text(
                                                                                                currentItem[1][customiseIDs[i]][1][index][1]
                                                                                                    .toString(),
                                                                                                style: Theme.of(context)
                                                                                                    .textTheme
                                                                                                    .bodyText1
                                                                                                    ?.copyWith(
                                                                                                        color: Theme.of(context).backgroundColor)),
                                                                                          ),
                                                                                          const SizedBox(
                                                                                            width: 20,
                                                                                          ),
                                                                                          Expanded(
                                                                                              child: Text(
                                                                                                  currentItem[1][customiseIDs[i]][1][index][2]
                                                                                                      .toString(),
                                                                                                  style: Theme.of(context).textTheme.bodyText1))
                                                                                        ]),
                                                                                      );
                                                                                    }),
                                                                              ]));
                                                                    } else if (currentItem[1][customiseIDs[i]][0][1] == "ADD" &&
                                                                        currentItem[1][customiseIDs[i]][1].isNotEmpty) {
                                                                      for (int s = 0; s < currentItem[1][customiseIDs[i]][1].length; s++) {
                                                                        itemPrice = ((itemPrice * 100) +
                                                                                double.parse(currentItem[1][customiseIDs[i]][1][s][3]) * 100) /
                                                                            100;
                                                                        for (int l = 0; l < finalCartData.length; l++) {
                                                                          if (finalCartData[l][0].toString() ==
                                                                              availableProfiles[avPrIndex][0].toString()) {
                                                                            finalCartData[l][6] = (finalCartData[l][6] * 100 +
                                                                                    double.parse(currentItem[1][customiseIDs[i]][1][s][3]) * 100) /
                                                                                100;
                                                                          }
                                                                        }
                                                                      }
                                                                      return Container(
                                                                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                                                          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                                                                          decoration: BoxDecoration(
                                                                              color: Theme.of(context).backgroundColor.withOpacity(0.5),
                                                                              border: Border.all(
                                                                                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
                                                                                  width: 1),
                                                                              borderRadius: BorderRadius.circular(10)),
                                                                          child: Column(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(currentItem[1][customiseIDs[i]][0][0],
                                                                                    textAlign: TextAlign.start,
                                                                                    style: Theme.of(context).textTheme.headline6?.copyWith(
                                                                                        color: Theme.of(context).textTheme.headline1?.color)),
                                                                                const SizedBox(height: 15),
                                                                                ListView.builder(
                                                                                    physics: const NeverScrollableScrollPhysics(),
                                                                                    shrinkWrap: true,
                                                                                    itemCount: currentItem[1][customiseIDs[i]][1].length,
                                                                                    itemBuilder: (context, index) {
                                                                                      return Padding(
                                                                                        padding: const EdgeInsets.only(left: 10, bottom: 10),
                                                                                        child: Row(children: [
                                                                                          CircleAvatar(
                                                                                            backgroundColor:
                                                                                                Theme.of(context).primaryColor.withOpacity(0.5),
                                                                                            radius: 10,
                                                                                            child: Text(
                                                                                                currentItem[1][customiseIDs[i]][1][index][1]
                                                                                                    .toString(),
                                                                                                style: Theme.of(context)
                                                                                                    .textTheme
                                                                                                    .bodyText1
                                                                                                    ?.copyWith(
                                                                                                        color: Theme.of(context).backgroundColor)),
                                                                                          ),
                                                                                          const SizedBox(
                                                                                            width: 20,
                                                                                          ),
                                                                                          Expanded(
                                                                                              child: Text(
                                                                                                  currentItem[1][customiseIDs[i]][1][index][2]
                                                                                                      .toString(),
                                                                                                  style: Theme.of(context)
                                                                                                      .textTheme
                                                                                                      .bodyText1
                                                                                                      ?.copyWith(
                                                                                                          color: Theme.of(context)
                                                                                                              .colorScheme
                                                                                                              .tertiary)))
                                                                                        ]),
                                                                                      );
                                                                                    }),
                                                                              ]));
                                                                    } else if (currentItem[1][customiseIDs[i]][0][1] == "REMOVE" &&
                                                                        currentItem[1][customiseIDs[i]][1].isNotEmpty) {
                                                                      for (int s = 0; s < currentItem[1][customiseIDs[i]][1].length; s++) {
                                                                        itemPrice = ((itemPrice * 100) -
                                                                                double.parse(currentItem[1][customiseIDs[i]][1][s][3]) * 100) /
                                                                            100;
                                                                        for (int l = 0; l < finalCartData.length; l++) {
                                                                          if (finalCartData[l][0].toString() ==
                                                                              availableProfiles[avPrIndex][0].toString()) {
                                                                            finalCartData[l][6] = (finalCartData[l][6] * 100 -
                                                                                    double.parse(currentItem[1][customiseIDs[i]][1][s][3]) * 100) /
                                                                                100;
                                                                          }
                                                                        }
                                                                      }
                                                                      return Container(
                                                                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                                                          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                                                                          decoration: BoxDecoration(
                                                                              color: Theme.of(context).backgroundColor.withOpacity(0.5),
                                                                              border: Border.all(
                                                                                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
                                                                                  width: 1),
                                                                              borderRadius: BorderRadius.circular(10)),
                                                                          child: Column(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(currentItem[1][customiseIDs[i]][0][0],
                                                                                    textAlign: TextAlign.start,
                                                                                    style: Theme.of(context).textTheme.headline6?.copyWith(
                                                                                        color: Theme.of(context).textTheme.headline1?.color)),
                                                                                const SizedBox(height: 15),
                                                                                ListView.builder(
                                                                                    physics: const NeverScrollableScrollPhysics(),
                                                                                    shrinkWrap: true,
                                                                                    itemCount: currentItem[1][customiseIDs[i]][1].length,
                                                                                    itemBuilder: (context, index) {
                                                                                      return Padding(
                                                                                        padding: const EdgeInsets.only(left: 10, bottom: 10),
                                                                                        child: Row(children: [
                                                                                          CircleAvatar(
                                                                                            backgroundColor:
                                                                                                Theme.of(context).primaryColor.withOpacity(0.5),
                                                                                            radius: 10,
                                                                                            child: Text(
                                                                                                currentItem[1][customiseIDs[i]][1][index][1]
                                                                                                    .toString(),
                                                                                                style: Theme.of(context)
                                                                                                    .textTheme
                                                                                                    .bodyText1
                                                                                                    ?.copyWith(
                                                                                                        color: Theme.of(context).backgroundColor)),
                                                                                          ),
                                                                                          const SizedBox(
                                                                                            width: 20,
                                                                                          ),
                                                                                          Expanded(
                                                                                              child: Text(
                                                                                                  currentItem[1][customiseIDs[i]][1][index][2]
                                                                                                      .toString(),
                                                                                                  style: Theme.of(context)
                                                                                                      .textTheme
                                                                                                      .bodyText1
                                                                                                      ?.copyWith(
                                                                                                          color:
                                                                                                              Theme.of(context).colorScheme.error)))
                                                                                        ]),
                                                                                      );
                                                                                    }),
                                                                              ]));
                                                                    } else {
                                                                      return const SizedBox(
                                                                        height: 0,
                                                                      );
                                                                    }
                                                                  });
                                                            },
                                                          ),
                                                          LayoutBuilder(builder: (((p0, p1) {
                                                            return Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                                                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                                  Text(
                                                                    "Price: ",
                                                                    style: Theme.of(context)
                                                                        .textTheme
                                                                        .headline6
                                                                        ?.copyWith(color: Theme.of(context).textTheme.headline1?.color),
                                                                  ),
                                                                  Text("£",
                                                                      style: Theme.of(context)
                                                                          .textTheme
                                                                          .headline6
                                                                          ?.copyWith(color: Theme.of(context).primaryColor)),
                                                                  Text(
                                                                    itemPrice.toStringAsFixed(2),
                                                                    style: Theme.of(context)
                                                                        .textTheme
                                                                        .headline6
                                                                        ?.copyWith(color: Theme.of(context).textTheme.headline1?.color),
                                                                  )
                                                                ]));
                                                          })))
                                                        ]))));
                                          });
                                    }
                                  } else {
                                    return LinearProgressIndicator(
                                        color: Theme.of(context).primaryColor, backgroundColor: const Color.fromARGB(0, 235, 224, 255));
                                  }
                                }),
                            const SizedBox(
                              height: 30,
                            )
                          ]);
                        }),
                  ],
                )
              ])));
            } else {
              return Scaffold(
                  body: SingleChildScrollView(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const ScreenBackButton(),
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: SizedBox(
                      width: double.infinity,
                      child: Center(
                          child: Column(children: [
                        Text(
                          "The cart is empty",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline1,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Try adding an item through the browse page.",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ]))),
                )
              ])));
            }
          } else {
            return const GenericLoading();
          }
        }));
  }
}
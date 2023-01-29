import 'package:alleat/screens/checkout/checkout.dart';
import 'package:alleat/services/cart_service.dart';
import 'package:alleat/services/localprofiles_service.dart';
import 'package:alleat/services/queryserver.dart';
import 'package:alleat/widgets/elements/elements.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  Future<Map> getCart() async {
    Map returnCartInfo = {"error": false, "message": "", "cartinfo": []};
    List availableProfiles = [];
    List cartProfileIDs = await SQLiteCartItems.getProfilesInCart(); //Get profile ids that are in the cart
    List profileInfo = await SQLiteLocalProfiles.getProfiles();

    //Get profiles

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
    for (int iProfile = 0; iProfile < availableProfiles.length; iProfile++) {
      Map tempItemInfo = {};

      List profileCart = await SQLiteCartItems.getProfileCart(availableProfiles[iProfile][0]); //{cartid, itemid, customised, quantity}
      for (int i = 0; i < profileCart.length; i++) {
        // For each item, add it as an index i
        tempItemInfo[profileCart[i]["itemid"]] = [[], {}];

        Map basicItemInfo = await QueryServer.query("https://alleat.cpur.net/query/cartiteminfo.php", {
          "type": "item",
          "term": profileCart[i]["itemid"].toString()
        }); //returns item id, item name, price, item image, restaurant id, restaurant name, delivery price

        if (basicItemInfo["error"] == true) {
          returnCartInfo["error"] = true;
          returnCartInfo["message"] = basicItemInfo["message"];
          return returnCartInfo;
        } else {
          tempItemInfo[profileCart[i]["itemid"]][0].addAll([
            basicItemInfo["message"]["message"][1], //Item name
            basicItemInfo["message"]["message"][3], //Item image link
            basicItemInfo["message"]["message"][2], //Item price
            basicItemInfo["message"]["message"][5], //Restaurant name
            basicItemInfo["message"]["message"][4], //Restaurant id
            basicItemInfo["message"]["message"][6], //Delivery price
            profileCart[i]["quantity"], //Item quantity
            profileCart[i]["cartid"], //Cart ID
            basicItemInfo["message"]["message"][7], //Minimum order price for restaurant
            basicItemInfo["message"]["message"][8], //Restaurant address
            basicItemInfo["message"]["message"][9], //Restaurant location latitude
            basicItemInfo["message"]["message"][10] //Restaurant location longitude
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
              Map customisedTitlesInfo = await QueryServer.query(
                  "https://alleat.cpur.net/query/cartiteminfo.php", {"type": "title", "term": json.encode(customisedtitleids)});

              if (customisedTitlesInfo["error"] == true) {
                returnCartInfo["error"] = true;
                returnCartInfo["message"] = customisedTitlesInfo["message"];
                return returnCartInfo;
              } else {
                List customisedTitlesInfoFormatted = customisedTitlesInfo["message"]["message"];
                if (customisedOptions.isNotEmpty) {
                  Map customisedOptionInfo = await QueryServer.query(
                      "https://alleat.cpur.net/query/cartiteminfo.php", {"type": "option", "term": customisedOptions.toString()});

                  if (customisedOptionInfo["error"] == true) {
                    returnCartInfo["error"] = true;
                    returnCartInfo["message"] = customisedOptionInfo["message"];
                    return returnCartInfo;
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
            returnCartInfo["error"] = true;
            returnCartInfo["message"] = "An error occurred while attempting to process the item information.";
          }
        }

        // Update item price to be the new customised price
        List customiseOptionsKeys = tempItemInfo[profileCart[i]["itemid"]][1].keys.toList();
        for (int iCust = 0; iCust < customiseOptionsKeys.length; iCust++) {
          //For each customise title
          if (tempItemInfo[profileCart[i]["itemid"]][1][customiseOptionsKeys[iCust]][0][1] == "SELECT" ||
              tempItemInfo[profileCart[i]["itemid"]][1][customiseOptionsKeys[iCust]][0][1] == "ADD") {
            //If it is either a selection or an add function add it to the item price
            for (int iCustOptions = 0;
                iCustOptions < tempItemInfo[profileCart[i]["itemid"]][1][customiseOptionsKeys[iCust]][1].length;
                iCustOptions++) {
              tempItemInfo[profileCart[i]["itemid"]][0][2] = ((double.parse(tempItemInfo[profileCart[i]["itemid"]][0][2]) * 100 +
                          double.parse(tempItemInfo[profileCart[i]["itemid"]][1][customiseOptionsKeys[iCust]][1][iCustOptions][3]) * 100) /
                      100)
                  .toString();
            }
          } else if (tempItemInfo[profileCart[i]["itemid"]][1][customiseOptionsKeys[iCust]][0][1] == "REMOVE") {
            //If it is a remove function, remove from the item price
            for (int iCustOptions = 0;
                iCustOptions < tempItemInfo[profileCart[i]["itemid"]][1][customiseOptionsKeys[iCust]][1].length;
                iCustOptions++) {
              tempItemInfo[profileCart[i]["itemid"]][0][2] = ((double.parse(tempItemInfo[profileCart[i]["itemid"]][0][2]) * 100 -
                          double.parse(tempItemInfo[profileCart[i]["itemid"]][1][customiseOptionsKeys[iCust]][1][iCustOptions][3]) * 100) /
                      100)
                  .toString();
            }
          }
        }
        tempItemInfo[profileCart[i]["itemid"]][0][2] =
            (double.parse(tempItemInfo[profileCart[i]["itemid"]][0][2]) * tempItemInfo[profileCart[i]["itemid"]][0][6]).toString();
      }

      returnCartInfo["cartinfo"].add([
        availableProfiles[iProfile][0],
        availableProfiles[iProfile][1],
        availableProfiles[iProfile][2],
        availableProfiles[iProfile][3],
        availableProfiles[iProfile][4],
        availableProfiles[iProfile][5],
        tempItemInfo
      ]);
    }
    return returnCartInfo;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const ScreenBackButton(),
      FutureBuilder<Map>(
          future: getCart(),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              List cartInfo = [snapshot.data ?? []];
              if (cartInfo[0]["error"] == true) {
                //If there is an error getting the cart info display error box
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
                                    cartInfo[0]["message"],
                                    textAlign: TextAlign.center,
                                  ),
                                ]))),
                          )
                        ])));
              } else {
                if (cartInfo[0]["cartinfo"].isNotEmpty) {
                  //If there are profiles in the cart
                  return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(), //Dont allow scrolling (Done by main page)
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: cartInfo[0]["cartinfo"].length + 1, //For each profile (add one for the total price)
                      itemBuilder: (context, indexProfile) {
                        if (indexProfile != cartInfo[0]["cartinfo"].length) {
                          List currentProfile = cartInfo[0]["cartinfo"][indexProfile];
                          List itemIDs = currentProfile[6].keys.toList();
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
                                            color: Color.fromRGBO(currentProfile[3], currentProfile[4], currentProfile[5], 1)),
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Text('${currentProfile[1][0]}${currentProfile[2][0]}',
                                                style: Theme.of(context).textTheme.headline6?.copyWith(color: Theme.of(context).backgroundColor)))),
                                    const SizedBox(width: 20), //Profile firstname and lastname

                                    Text(
                                      "${currentProfile[1]} ${currentProfile[2]}",
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
                            ListView.builder(
                                //Create a container for each profile containing the customised options and a summary of the item
                                physics: const NeverScrollableScrollPhysics(), //Dont allow scrolling (Done by main page)
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: itemIDs.length, //For each item
                                itemBuilder: (context, indexItem) {
                                  List currentItem = currentProfile[6][itemIDs[indexItem]];
                                  List itemCustomiseIDs = currentItem[1].keys.toList();
                                  return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                      child: Dismissible(
                                          //Create a slide to delete container (dismissible)
                                          key: Key(currentItem[0][7].toString()), //Key is the cart id
                                          onDismissed: (direction) async {
                                            bool hasDeleted = await removeItem(currentItem[0][7]); //Remove item from local cart database
                                            if (hasDeleted) {
                                              //If it deleted
                                              cartInfo[0]["cartinfo"][indexProfile][6].remove(itemIDs[indexItem]); //removing the item from the list
                                              setState(() {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(content: Text("Successfully deleted item.")));
                                              });
                                            } else {
                                              setState(() {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(content: Text("Failed to deleted item. Please reopen the cart")));
                                              });
                                            }
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
                                                          image:
                                                              DecorationImage(fit: BoxFit.cover, image: NetworkImage(currentItem[0][1].toString()))),
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
                                                ListView.builder(
                                                    //Create a container with the title of the option that has been customised with a list of options changed
                                                    physics: const NeverScrollableScrollPhysics(), //Dont allow scrolling (Done by main page)
                                                    scrollDirection: Axis.vertical,
                                                    shrinkWrap: true,
                                                    itemCount: itemCustomiseIDs.length, //For each customise title
                                                    itemBuilder: (context, indexCustomise) {
                                                      List currentCustomiseTitle = currentItem[1][itemCustomiseIDs[indexCustomise]];
                                                      if (currentCustomiseTitle[0][1] == "SELECT" && currentCustomiseTitle[1].toList().length != 0) {
                                                        return Container(
                                                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                                            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                                                            decoration: BoxDecoration(
                                                                color: Theme.of(context).backgroundColor.withOpacity(0.5),
                                                                border: Border.all(
                                                                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3), width: 1),
                                                                borderRadius: BorderRadius.circular(10)),
                                                            child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(currentCustomiseTitle[0][0],
                                                                      textAlign: TextAlign.start,
                                                                      style: Theme.of(context)
                                                                          .textTheme
                                                                          .headline6
                                                                          ?.copyWith(color: Theme.of(context).textTheme.headline1?.color)),
                                                                  const SizedBox(height: 15),
                                                                  ListView.builder(
                                                                      physics: const NeverScrollableScrollPhysics(),
                                                                      shrinkWrap: true,
                                                                      itemCount: currentCustomiseTitle[1].length, //For each customise option
                                                                      itemBuilder: (context, indexOption) {
                                                                        List currentCustomiseOption = currentCustomiseTitle[1][indexOption];
                                                                        return Padding(
                                                                          padding: const EdgeInsets.only(left: 10, bottom: 10),
                                                                          child: Row(children: [
                                                                            CircleAvatar(
                                                                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
                                                                              radius: 10,
                                                                              child: Text(currentCustomiseOption[1].toString(),
                                                                                  style: Theme.of(context)
                                                                                      .textTheme
                                                                                      .bodyText1
                                                                                      ?.copyWith(color: Theme.of(context).backgroundColor)),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 20,
                                                                            ),
                                                                            Expanded(
                                                                                child: Text(currentCustomiseOption[2].toString(),
                                                                                    style: Theme.of(context).textTheme.bodyText1))
                                                                          ]),
                                                                        );
                                                                      }),
                                                                ]));
                                                      } else if (currentCustomiseTitle[0][1] == "ADD" &&
                                                          currentCustomiseTitle[1].toList().length != 0) {
                                                        return Container(
                                                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                                            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                                                            decoration: BoxDecoration(
                                                                color: Theme.of(context).backgroundColor.withOpacity(0.5),
                                                                border: Border.all(
                                                                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3), width: 1),
                                                                borderRadius: BorderRadius.circular(10)),
                                                            child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(currentCustomiseTitle[0][0],
                                                                      textAlign: TextAlign.start,
                                                                      style: Theme.of(context)
                                                                          .textTheme
                                                                          .headline6
                                                                          ?.copyWith(color: Theme.of(context).textTheme.headline1?.color)),
                                                                  const SizedBox(height: 15),
                                                                  ListView.builder(
                                                                      physics: const NeverScrollableScrollPhysics(),
                                                                      shrinkWrap: true,
                                                                      itemCount: currentCustomiseTitle[1].length, //For each customise option
                                                                      itemBuilder: (context, indexOption) {
                                                                        List currentCustomiseOption = currentCustomiseTitle[1][indexOption];
                                                                        return Padding(
                                                                          padding: const EdgeInsets.only(left: 10, bottom: 10),
                                                                          child: Row(children: [
                                                                            CircleAvatar(
                                                                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
                                                                              radius: 10,
                                                                              child: Text(currentCustomiseOption[1].toString(),
                                                                                  style: Theme.of(context)
                                                                                      .textTheme
                                                                                      .bodyText1
                                                                                      ?.copyWith(color: Theme.of(context).backgroundColor)),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 20,
                                                                            ),
                                                                            Expanded(
                                                                                child: Text(currentCustomiseOption[2].toString(),
                                                                                    style: Theme.of(context)
                                                                                        .textTheme
                                                                                        .bodyText1
                                                                                        ?.copyWith(color: Theme.of(context).colorScheme.tertiary)))
                                                                          ]),
                                                                        );
                                                                      }),
                                                                ]));
                                                      } else if (currentCustomiseTitle[0][1] == "REMOVE" &&
                                                          currentCustomiseTitle[1].toList().length != 0) {
                                                        return Container(
                                                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                                            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                                                            decoration: BoxDecoration(
                                                                color: Theme.of(context).backgroundColor.withOpacity(0.5),
                                                                border: Border.all(
                                                                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3), width: 1),
                                                                borderRadius: BorderRadius.circular(10)),
                                                            child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(currentCustomiseTitle[0][0],
                                                                      textAlign: TextAlign.start,
                                                                      style: Theme.of(context)
                                                                          .textTheme
                                                                          .headline6
                                                                          ?.copyWith(color: Theme.of(context).textTheme.headline1?.color)),
                                                                  const SizedBox(height: 15),
                                                                  ListView.builder(
                                                                      physics: const NeverScrollableScrollPhysics(),
                                                                      shrinkWrap: true,
                                                                      itemCount: currentCustomiseTitle[1].length, //For each customise option
                                                                      itemBuilder: (context, indexOption) {
                                                                        List currentCustomiseOption = currentCustomiseTitle[1][indexOption];
                                                                        return Padding(
                                                                          padding: const EdgeInsets.only(left: 10, bottom: 10),
                                                                          child: Row(children: [
                                                                            CircleAvatar(
                                                                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
                                                                              radius: 10,
                                                                              child: Text(currentCustomiseOption[1].toString(),
                                                                                  style: Theme.of(context)
                                                                                      .textTheme
                                                                                      .bodyText1
                                                                                      ?.copyWith(color: Theme.of(context).backgroundColor)),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 20,
                                                                            ),
                                                                            Expanded(
                                                                                child: Text(currentCustomiseOption[2].toString(),
                                                                                    style: Theme.of(context)
                                                                                        .textTheme
                                                                                        .bodyText1
                                                                                        ?.copyWith(color: Theme.of(context).colorScheme.error)))
                                                                          ]),
                                                                        );
                                                                      }),
                                                                ]));
                                                      } else {
                                                        return const SizedBox(
                                                          height: 0,
                                                        );
                                                      }
                                                    }),
                                                Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                                    child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                      Text(
                                                        "Price: ",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline6
                                                            ?.copyWith(color: Theme.of(context).textTheme.headline1?.color),
                                                      ),
                                                      Text(
                                                        "£",
                                                        style: Theme.of(context).textTheme.headline6?.copyWith(color: Theme.of(context).primaryColor),
                                                      ),
                                                      Text(
                                                        double.parse(currentItem[0][2]).toStringAsFixed(2),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline6
                                                            ?.copyWith(color: Theme.of(context).textTheme.headline1?.color),
                                                      )
                                                    ]))
                                              ]))));
                                })
                          ]);
                        } else {
                          return LayoutBuilder(
                            builder: (p0, p1) {
                              double subtotal = 0;
                              bool isOneRestaurant = true;
                              int tempRestaurantID = -1;
                              for (int iProfile = 0; iProfile < cartInfo[0]["cartinfo"].length; iProfile++) {
                                //For each profile in the cart
                                cartInfo[0]["cartinfo"][iProfile].add(0.00); //Add total price to the end of the profile index in the cartInfo
                                List itemPriceKeys = cartInfo[0]["cartinfo"][iProfile][6].keys.toList(); //Create a list of keys for each item
                                for (int iItem = 0; iItem < itemPriceKeys.length; iItem++) {
                                  if (tempRestaurantID == -1) {
                                    tempRestaurantID = int.parse(cartInfo[0]["cartinfo"][iProfile][6][itemPriceKeys[iItem]][0][4]);
                                  } else {
                                    if (int.parse(cartInfo[0]["cartinfo"][iProfile][6][itemPriceKeys[iItem]][0][4]) != tempRestaurantID) {
                                      isOneRestaurant = false;
                                    }
                                  }

                                  //For each item
                                  cartInfo[0]["cartinfo"][iProfile][7] = (cartInfo[0]["cartinfo"][iProfile][7] * 100 +
                                          double.parse(cartInfo[0]["cartinfo"][iProfile][6][itemPriceKeys[iItem]][0][2]) * 100) /
                                      100; //Add price to the total price for the profile

                                }
                              }

                              for (int iSubtotalProfile = 0; iSubtotalProfile < cartInfo[0]["cartinfo"].length; iSubtotalProfile++) {
                                subtotal = (subtotal * 100 + cartInfo[0]["cartinfo"][iSubtotalProfile][7] * 100) /
                                    100; //Add the total price for profile to subtotal
                              }
                              return Column(children: [
                                const SizedBox(height: 50),
                                ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: cartInfo[0]["cartinfo"].length, //For each profile
                                    itemBuilder: (context, iProfilePrice) {
                                      //For each profile, display the profile total price
                                      return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                "${cartInfo[0]["cartinfo"][iProfilePrice][1]} ${cartInfo[0]["cartinfo"][iProfilePrice][2]}: ",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline6
                                                    ?.copyWith(color: Theme.of(context).textTheme.headline1?.color),
                                              ),
                                              const SizedBox(
                                                width: 50,
                                              ),
                                              Text("£${cartInfo[0]["cartinfo"][iProfilePrice][7].toStringAsFixed(2)}",
                                                  style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w500))
                                            ],
                                          ));
                                    }),
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                      Text("SUBTOTAL", style: Theme.of(context).textTheme.headline6?.copyWith(color: Theme.of(context).primaryColor)),
                                      const SizedBox(
                                        width: 50,
                                      ),
                                      Text("£${subtotal.toStringAsFixed(2)}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              ?.copyWith(fontWeight: FontWeight.w500, color: Theme.of(context).primaryColor))
                                    ])),
                                LayoutBuilder(
                                  builder: (p0, p1) {
                                    if (isOneRestaurant == true) {
                                      List itemKeys = cartInfo[0]["cartinfo"][0][6].keys.toList();
                                      try {
                                        if (double.parse(cartInfo[0]["cartinfo"][0][6][itemKeys[0]][0][8]) <= subtotal) {
                                          return Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                                              child: Row(children: [
                                                Expanded(
                                                    child: ElevatedButton(
                                                        onPressed: (() {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => Checkout(
                                                                        cartInfo: cartInfo[0]["cartinfo"],
                                                                      )));
                                                        }),
                                                        child: const Text("Checkout")))
                                              ]));
                                        } else {
                                          return Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                                              child: Row(children: [
                                                Expanded(
                                                    child: Opacity(
                                                        opacity: 0.2,
                                                        child: ElevatedButton(
                                                            style: ButtonStyle(
                                                                backgroundColor:
                                                                    MaterialStatePropertyAll(Theme.of(context).colorScheme.onBackground)),
                                                            onPressed: null,
                                                            child: Text(
                                                              "Minimum order £${cartInfo[0]["cartinfo"][0][6][itemKeys[0]][0][8]}",
                                                              textAlign: TextAlign.center,
                                                              style: Theme.of(context)
                                                                  .textTheme
                                                                  .headline6
                                                                  ?.copyWith(color: Theme.of(context).backgroundColor),
                                                            ))))
                                              ]));
                                        }
                                      } catch (e) {
                                        return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                                            child: Row(children: [
                                              Expanded(
                                                  child: ElevatedButton(
                                                      style:
                                                          ButtonStyle(backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.error)),
                                                      onPressed: null,
                                                      child: Text(
                                                        "Unknown minimum cart price",
                                                        textAlign: TextAlign.center,
                                                        style:
                                                            Theme.of(context).textTheme.headline6?.copyWith(color: Theme.of(context).backgroundColor),
                                                      )))
                                            ]));
                                      }
                                    } else {
                                      return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                                          child: Row(children: [
                                            Expanded(
                                                child: Opacity(
                                                    opacity: 0.2,
                                                    child: ElevatedButton(
                                                        style: ButtonStyle(
                                                            backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.onBackground)),
                                                        onPressed: null,
                                                        child: Text(
                                                          "Multiple Restaurant Delivery Unavilable",
                                                          textAlign: TextAlign.center,
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .headline6
                                                              ?.copyWith(color: Theme.of(context).backgroundColor),
                                                        ))))
                                          ]));
                                    }
                                  },
                                )
                              ]);
                            },
                          );
                        }
                      });
                } else {
                  return Padding(
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
                  );
                }
              }
            } else {
              return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Padding(
                    padding: const EdgeInsets.all(50),
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ))
              ]);
            }
          })),
    ])));
  }
}

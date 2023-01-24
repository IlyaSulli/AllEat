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
        for (int iCust = 0; iCust < customiseOptionsKeys.length; iCust++) { //For each customise title
          if (tempItemInfo[profileCart[i]["itemid"]][1][customiseOptionsKeys[iCust]][0][1] == "SELECT" ||
              tempItemInfo[profileCart[i]["itemid"]][1][customiseOptionsKeys[iCust]][0][1] == "ADD") { //If it is either a selection or an add function add it to the item price
            for (int iCustOptions = 0;
                iCustOptions < tempItemInfo[profileCart[i]["itemid"]][1][customiseOptionsKeys[iCust]][1].length;
                iCustOptions++) {
              tempItemInfo[profileCart[i]["itemid"]][0][2] = ((double.parse(tempItemInfo[profileCart[i]["itemid"]][0][2]) * 100 +
                          double.parse(tempItemInfo[profileCart[i]["itemid"]][1][customiseOptionsKeys[iCust]][1][iCustOptions][3]) * 100) /
                      100)
                  .toString();
            }
          } else if (tempItemInfo[profileCart[i]["itemid"]][1][customiseOptionsKeys[iCust]][0][1] == "REMOVE") { //If it is a remove function, remove from the item price
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

  @override
  Widget build(BuildContext context) {
    List cartInfo = [];
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const ScreenBackButton(),
      FutureBuilder<Map>(
          future: getCart(),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              List cartInfo = [snapshot.data ?? []];
              return Text(cartInfo.toString());
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
      Text(cartInfo.toString()),
    ])));
  }
}

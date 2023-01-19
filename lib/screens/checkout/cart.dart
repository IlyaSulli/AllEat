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
  Future<List> getAvailableProfiles() async {
    List availableProfiles = [];
    List cartProfileIDs = await SQLiteCartItems
        .getProfilesInCart(); //Get profile ids that are in the cart
    List profileInfo = await SQLiteLocalProfiles.getProfiles();

    //Got profiles
    for (int i = 0; i < cartProfileIDs.length; i++) {
      if (cartProfileIDs.contains(profileInfo[i]["profileid"])) {
        availableProfiles.add([
          profileInfo[i]["profileid"],
          profileInfo[i]["firstname"],
          profileInfo[i]["lastname"],
          profileInfo[i]["profilecolorred"],
          profileInfo[i]["profilecolorgreen"],
          profileInfo[i]["profilecolorblue"]
        ]);
      }
    }
    return availableProfiles;
  }

  Future<Map> getProfileCart(profileID) async {
    Map returnItemList = {"error": false, "message": "", "iteminfo": {}};
    Map tempItemInfo = {};

    List profileCart = await SQLiteCartItems.getProfileCart(
        profileID); //{itemid, customised, quantity}

    for (int i = 0; i < profileCart.length; i++) {
      tempItemInfo[profileCart[i]["itemid"]] = [[], {}];
    }
    for (int i = 0; i < profileCart.length; i++) {
      Map basicItemInfo = await QueryServer.query(
          "https://alleat.cpur.net/query/cartiteminfo.php",
          {"type": "item", "term": profileCart[i]["itemid"].toString()});
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
          basicItemInfo["message"]["message"][6]
        ]);

        Map customised = json.decode(profileCart[i]["customised"]);
        List customisedtitleids =
            customised.keys.toList(); //Each customise title is stored here
        List customisedOptions = []; //Each unique option stored here
        Map updatedCustomised = {};
        for (int i = 0; i < customisedtitleids.length; i++) {
          //For each customise title
          updatedCustomised[customisedtitleids[i]] = [
            [],
            []
          ]; //Add customised key to new Map
          for (int j = 0; j < customised[customisedtitleids[i]].length; j++) {
            //For each item in list of customised options for customise title
            if (!customisedOptions
                .contains(customised[customisedtitleids[i]][j])) {
              //If the option is not in the list of options, add it to the list
              updatedCustomised[customisedtitleids[i]][1]
                  .add([customised[customisedtitleids[i]][j], 1]);
              customisedOptions.add(customised[customisedtitleids[i]][j]);
            } else {
              for (int k = 0;
                  k < updatedCustomised[customisedtitleids[i]][1].length;
                  k++) {
                if (updatedCustomised[customisedtitleids[i]][1][k][0] ==
                    customised[customisedtitleids[i]][j]) {
                  updatedCustomised[customisedtitleids[i]][1][k][1] += 1;
                }
              }
            }
          }
        }
        try {
          Map customisedTitlesInfo = await QueryServer.query(
              "https://alleat.cpur.net/query/cartiteminfo.php",
              {"type": "title", "term": json.encode(customisedtitleids)});
          if (customisedTitlesInfo["error"] == true) {
            returnItemList["error"] = true;
            returnItemList["message"] = customisedTitlesInfo["message"];
            return returnItemList;
          } else {
            List customisedTitlesInfoFormatted =
                customisedTitlesInfo["message"]["message"];
            Map customisedOptionInfo = await QueryServer.query(
                "https://alleat.cpur.net/query/cartiteminfo.php",
                {"type": "option", "term": customisedOptions.toString()});
            if (customisedOptionInfo["error"] == true) {
              returnItemList["error"] = true;
              returnItemList["message"] = customisedOptionInfo["message"];
              return returnItemList;
            } else {
              List customisedOptionInfoFormatted =
                  customisedOptionInfo["message"]["message"];

              for (int i = 0; i < customisedtitleids.length; i++) {
                // For each customise title
                for (int j = 0; j < customisedTitlesInfoFormatted.length; j++) {
                  //For each item in list of returned from server info about each title
                  if (customisedTitlesInfoFormatted[j][0] ==
                      customisedtitleids[i]) {
                    // If it has the id of the title in the first index, add the info to the composite info
                    updatedCustomised[customisedtitleids[i]][0].addAll([
                      customisedTitlesInfoFormatted[j][1],
                      customisedTitlesInfoFormatted[j][2]
                    ]);
                  }
                }
                for (int j = 0;
                    j < updatedCustomised[customisedtitleids[i]][1].length;
                    j++) {
                  //For each option in the list of options for each title
                  for (int k = 0;
                      k < customisedOptionInfoFormatted.length;
                      k++) {
                    //For each item in list of returned from server about option info
                    if (customisedOptionInfoFormatted[k][0] ==
                        updatedCustomised[customisedtitleids[i]][1][j][0]) {
                      // If it has the id of the option in the first index, add the info to the list
                      updatedCustomised[customisedtitleids[i]][1][j].addAll([
                        customisedOptionInfoFormatted[k][1],
                        customisedOptionInfoFormatted[k][2]
                      ]);
                    }
                  }
                }
              }
              tempItemInfo[profileCart[i]["itemid"]][1] = updatedCustomised;
              returnItemList["iteminfo"] = tempItemInfo;
              return returnItemList;
            }
          }
        } catch (e) {
          returnItemList["error"] = true;
          returnItemList["message"] =
              "An error occurred while attempting to process the item information.";
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

            return Scaffold(
                body: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  const ScreenBackButton(),
                  Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 40, right: 20, top: 20),
                        child: Text("Cart.",
                            style: Theme.of(context).textTheme.headline2),
                      ),
                      ListView.builder(
                          physics:
                              const NeverScrollableScrollPhysics(), //Dont allow scrolling (Done by main page)
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount:
                              availableProfiles.length, //For each profile
                          itemBuilder: (context, index) {
                            return Column(children: [
                              Container(
                                  //Contain the profile within a container
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                          // Create profile circle with first and last letter
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color.fromRGBO(
                                                  availableProfiles[index][3],
                                                  availableProfiles[index][4],
                                                  availableProfiles[index][5],
                                                  1)),
                                          child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                  '${availableProfiles[index][1][0]}${availableProfiles[index][2][0]}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline6
                                                      ?.copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .backgroundColor)))),
                                      const SizedBox(
                                          width:
                                              20), //Profile firstname and lastname
                                      Text(
                                        "${availableProfiles[index][1]} ${availableProfiles[index][2]}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5
                                            ?.copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headline1
                                                    ?.color),
                                      )
                                    ],
                                  )),
                              Divider(
                                thickness: 2,
                                color: Theme.of(context).colorScheme.onSurface,
                                indent: 40,
                                endIndent: 40,
                              ),
                              FutureBuilder<Map>(
                                  future: getProfileCart(
                                      availableProfiles[index][0]),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      List profileCart = [snapshot.data ?? []];
                                      if (profileCart[0]["error"] == true) {
                                        return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20,
                                                right: 20,
                                                top: 10,
                                                bottom: 10),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                20)),
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        spreadRadius: 2,
                                                        blurRadius: 10,
                                                        offset: const Offset(0,
                                                            10), // changes position of shadow
                                                      ),
                                                    ]),
                                                child: Column(children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            30),
                                                    child: SizedBox(
                                                        width: double.infinity,
                                                        child: Center(
                                                            child: Column(
                                                                children: [
                                                              const Text(
                                                                "An error has occurred.",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                              const SizedBox(
                                                                height: 20,
                                                              ),
                                                              Text(
                                                                profileCart[0]
                                                                    ["message"],
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ]))),
                                                  )
                                                ])));
                                      } else {
                                        List itemKeyValues = profileCart[0]
                                                ["iteminfo"]
                                            .keys
                                            .toList();
                                        return ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(), //Dont allow scrolling (Done by main page)
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            itemCount: itemKeyValues
                                                .length, //For each item
                                            itemBuilder: (context, index) {
                                              List currentItem = profileCart[0]
                                                      ["iteminfo"]
                                                  [itemKeyValues[index]];
                                              return Dismissible(
                                                  key: Key(itemKeyValues[index]
                                                      .toString()),
                                                  onDismissed: (direction) {
                                                    print("Dismissed");
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface),
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15,
                                                        vertical: 20),
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 30,
                                                        horizontal: 30),
                                                    child:
                                                        Text(currentItem[0][0]),
                                                  ));
                                            });
                                      }
                                    } else {
                                      return LinearProgressIndicator(
                                          color: Theme.of(context).primaryColor,
                                          backgroundColor: const Color.fromARGB(
                                              0, 235, 224, 255));
                                    }
                                  }),
                              const SizedBox(
                                height: 30,
                              )
                            ]);
                          })
                    ],
                  )
                ])));
          } else {
            return const GenericLoading();
          }
        }));
  }
}

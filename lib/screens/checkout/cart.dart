import 'package:alleat/services/cart_service.dart';
import 'package:alleat/services/localprofiles_service.dart';
import 'package:alleat/services/queryserver.dart';
import 'package:alleat/widgets/elements/elements.dart';
import 'package:alleat/widgets/genericlocading.dart';
import 'package:flutter/material.dart';

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

  Future<void> getProfileCart(profileID) async {
    Map itemInfo = {};
    List profileCart = await SQLiteCartItems.getProfileCart(profileID);
    print(profileCart);
    for (int i = 0; i < profileCart.length; i++) {
      Map basicItemInfo = await QueryServer.query(
          "https://alleat.cpur.net/query/cartiteminfo.php",
          {"type": "item", "term": profileCart[i]["itemid"].toString()});
      print(basicItemInfo);
    }
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
                              FutureBuilder<void>(
                                  future: getProfileCart(
                                      availableProfiles[index][0]),
                                  builder: (context, snapshot) {
                                    return Text(
                                        "Hey"); // if (snapshot.hasData) {

                                    //   //List profileCart = snapshot.data ?? [];
                                    //   //return Text(profileCart.toString());
                                    // }
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

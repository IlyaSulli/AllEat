import 'package:alleat/screens/profilesetup/profilesetup_existing.dart';
import 'package:alleat/services/localprofiles_service.dart';
import 'package:alleat/services/setselected.dart';
import 'package:flutter/material.dart';

class ProfileList extends StatefulWidget {
  const ProfileList({super.key});

  @override
  State<ProfileList> createState() => _ProfileListState();
}

class _ProfileListState extends State<ProfileList> {
  bool edit = false;

  Future<List> getDisplayableProfiles() async {
    return await SQLiteLocalProfiles.getDisplayProfilesList();
  }

  Future<void> selectProfile(id) async {
    var getToSelect = (await SQLiteLocalProfiles.getProfileFromID(id))[0];

    bool trySelect = await SetSelected.selectProfile(
        getToSelect['profileid'],
        getToSelect['firstname'],
        getToSelect['lastname'],
        getToSelect['email']);
    if (trySelect == true) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Switched profiles successfully',
              style: Theme.of(context).textTheme.headline6,
            ),
            backgroundColor: Theme.of(context).colorScheme.onSurface,
          ),
        );
      });
    } else {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to switch profiles.',
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(color: Color(0xffffffff)),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        //Create profile selection widget with height 150px
        height: 150,
        child: ListView(scrollDirection: Axis.horizontal, children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            FutureBuilder<List>(
                // Get selected profile
                future: getDisplayableProfiles(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    //While there is no information sent back
                    return Column(
                      //Display empty circle
                      children: [
                        Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context)
                                    .navigationBarTheme
                                    .backgroundColor))
                      ],
                    );
                  } else if (snapshot.hasData) {
                    // Once there is information
                    List? profileInfo = snapshot.data; // Store in profileInfo

                    if (profileInfo != null && profileInfo.isNotEmpty) {
                      //If it contains a profile
                      return Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: SizedBox(
                              //Set width of data to the number of profiles by 120px
                              width: (profileInfo.length) * 120,
                              child: ListView.builder(
                                  //For each profile
                                  itemCount: profileInfo.length,
                                  scrollDirection:
                                      Axis.horizontal, //Make scrollable list
                                  itemBuilder: (context, index) {
                                    Map<String, dynamic> profile = profileInfo[
                                        index]; //Store current profile being created in profile
                                    if (index == 0) {
                                      return InkWell(
                                          onTap: (() {}),
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Column(children: [
                                                Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Container(
                                                        width: 93,
                                                        height: 93,
                                                        decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                width: 3,
                                                                style:
                                                                    BorderStyle
                                                                        .solid)),
                                                      ),
                                                      Container(
                                                          // Create a circle with a purple outline and and the first letter of first and last name
                                                          width: 80,
                                                          height: 80,
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Color.fromRGBO(
                                                                  profile[
                                                                      'profilecolorred'],
                                                                  profile[
                                                                      'profilecolorgreen'],
                                                                  profile[
                                                                      'profilecolorblue'],
                                                                  1)),
                                                          child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Text(
                                                                  '${profile['firstname'][0]}${profile['lastname'][0]}',
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .headline3
                                                                      ?.copyWith(
                                                                          color:
                                                                              Theme.of(context).backgroundColor))))
                                                    ]),
                                                const SizedBox(height: 15),
                                                SizedBox(
                                                    //Display profile name
                                                    width: 100,
                                                    child: Text(
                                                      "${profile['firstname']}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline5
                                                          ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .headline1
                                                                  ?.color),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ))
                                              ])));
                                    } else if (index > 0) {
                                      return InkWell(
                                          onTap: (() {
                                            selectProfile(profile['id']);
                                          }),
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Column(children: [
                                                Container(
                                                    // Create a circle with a purple outline and and the first letter of first and last name
                                                    width: 88,
                                                    height: 88,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color.fromRGBO(
                                                            profile[
                                                                'profilecolorred'],
                                                            profile[
                                                                'profilecolorgreen'],
                                                            profile[
                                                                'profilecolorblue'],
                                                            1)),
                                                    child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                            '${profile['firstname'][0]}${profile['lastname'][0]}',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .headline3
                                                                ?.copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .backgroundColor)))),
                                                const SizedBox(height: 15),
                                                SizedBox(
                                                    //Display profile name
                                                    width: 100,
                                                    child: Text(
                                                      "${profile['firstname']}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline5
                                                          ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .headline1
                                                                  ?.color),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ))
                                              ])));
                                    } else {
                                      return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Column(children: [
                                            Container(
                                                // Create a circle with a purple outline and and the first letter of first and last name
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .error),
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "Error",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline5
                                                        ?.copyWith(
                                                            color: const Color(
                                                                0xffffffff)),
                                                  ),
                                                ))
                                          ]));
                                    }
                                  })));
                    } else {
                      return Column(
                        children: [
                          Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).errorColor))
                        ],
                      );
                    }
                  } else {
                    return Column(
                      children: [
                        Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).errorColor))
                      ],
                    );
                  }
                }),
            Column(
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(children: [
                      ElevatedButton(
                        onPressed: (() {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ProfileSetupExisting()));
                        }),
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(22)),
                        child: Icon(
                          Icons.add,
                          color: Theme.of(context).backgroundColor,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ]))
              ],
            )
          ])
        ]));
  }
}

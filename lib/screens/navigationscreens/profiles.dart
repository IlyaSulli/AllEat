// import 'package:alleat/screens/add_profile/addprofile.dart';
// import 'package:alleat/screens/fresh_app/fresh_profile.dart';
// import 'package:alleat/services/sqlite_service.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late dynamic profileInfo;
  bool setup = false;

  // Future<List> getProfileInfo() async {
  //   List profileInfo = await SQLiteLocalDB
  //       .getDisplayProfiles(); //Get id, firstname, lastname and selected status to display
  //   return profileInfo;
  // }

  // Future<void> selectProfile(index) async {
  //   await SQLiteLocalDB.setSelected(index); //Get selected profile
  //   List profileInfo = await SQLiteLocalDB.getDisplayProfiles();
  //   setState(() {
  //     profileInfo = profileInfo;
  //   });
  // }

  // Future<void> deleteProfile(index) async {
  //   await SQLiteLocalDB.deleteProfile(index);
  //   List profileInfo = await SQLiteLocalDB
  //       .getDisplayProfiles(); //Get profile info under id selected
  //   setState(() {
  //     profileInfo = profileInfo;
  //   });
  //   List<Map> profileInfoCheck = await SQLiteLocalDB
  //       .getFirstProfile(); //Call Database for the first entry
  //   if (profileInfoCheck.isEmpty) {
  //     //If the first entry is empty
  //     setup = false; //Then setup is not complete (pass to build)
  //     setState(() {
  //       Navigator.push(context,
  //           MaterialPageRoute(builder: (context) => const FreshProfile()));
  //     });
  //   } else {
  //     index = await SQLiteLocalDB.getFirstProfile(); //Get first profile
  //     index = index[0]["id"];
  //     await SQLiteLocalDB.setSelected(
  //         index); //Set selected to the first profile
  //     List profileInfoSelect = await SQLiteLocalDB
  //         .getDisplayProfiles(); //Return list of profiles back
  //     setState(() {
  //       profileInfoSelect = profileInfoSelect;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    //getProfileInfo();
    return Scaffold(
        //Create subpage
        body: SizedBox(
            child: Column(children: <Widget>[
      Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.all(20),
        child: const Text(
          //Saved Profiles Heading
          "Saved Profiles",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      Expanded(child: FutureBuilder<List>(
        //Future builder remakes the list of profiles when it is updated
        //future: getProfileInfo(), //On Future getProfileInfo data update rebuild
        builder: (context, snapshot) {
          List profiles = snapshot.data ?? []; //Get data from Future
          return ListView.builder(
              // Creates a new instance of contianer for each item
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> profile =
                    profiles[index]; //Map profile to profiles index
                var profileSelected = profile["selected"].toString();
                return Center(
                    child: LayoutBuilder(builder: (context, constraints) {
                  try {
                    if (profileSelected == "0") {
                      //If profile is not selected then
                      return Container(
                          //Create container with ListTile so that it can be pressed
                          margin: const EdgeInsets.only(
                              top: 5, bottom: 5, left: 15, right: 15),
                          color: const Color(0xffffffff),
                          padding: const EdgeInsets.only(left: 5),
                          child: ListTile(
                              onTap: () {
                                //  selectProfile(profiles[index]["id"]);
                              },
                              title: Text(
                                  profile["firstname"] +
                                      " " +
                                      profile["lastname"],
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                  )),
                              trailing: IconButton(
                                //Delete button to remove from database
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Color(0xffAF0E17),
                                ),
                                onPressed: () {
                                  //  deleteProfile(profiles[index][
                                  //      "id"]); //Run Future to delete profile from local database (signed out)
                                },
                              )));
                    } else if (profileSelected == "1") {
                      //If profile is selected then
                      return Container(
                          //Create container with ListTile but without tap function since it doesnt do anything
                          margin: const EdgeInsets.only(
                              top: 5, bottom: 5, left: 15, right: 15),
                          color: const Color(0xffffffff),
                          padding: const EdgeInsets.only(left: 5),
                          width: 500,
                          height: 80,
                          child: Column(
                            //Column includes the normal name and delete button but also the SELECTED text to show which one is selected
                            children: [
                              Expanded(
                                child: SizedBox(
                                    child: ListTile(
                                        title: Text(
                                            profile["firstname"] +
                                                " " +
                                                profile["lastname"],
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 18,
                                            )),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Color(0xffAF0E17),
                                          ),
                                          onPressed: () {
                                            //  deleteProfile(
                                            //      profiles[index]["id"]);
                                          },
                                        ))),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.bottomLeft,
                                  padding: const EdgeInsets.all(5),
                                  child: const Padding(
                                      padding:
                                          EdgeInsets.only(bottom: 10, left: 10),
                                      child: Text(
                                        "SELECTED",
                                        style: TextStyle(
                                          color: Colors.deepPurple,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                      )),
                                ),
                              )
                            ],
                          ));
                    } else {
                      return Container(
                          //If none show no profiles (fallback. Should go straight to setup page normally)
                          margin: const EdgeInsets.only(
                              top: 5, bottom: 5, left: 15, right: 15),
                          color: const Color(0xffffffff),
                          child: const ListTile(title: Text("No Profiles")));
                    }
                  } catch (e) {
                    //If fails to get profile info, show failed to grab profile
                    return Container(
                        margin: const EdgeInsets.only(
                            top: 5, bottom: 5, left: 15, right: 15),
                        color: const Color(0xffffffff),
                        child: const ListTile(
                            title: Text("Failed to grab profile.")));
                  }
                }));
              });
        },
      )),
      Container(
        //At the bottom of the page, include a button that allows the user to add a new profile
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          style: Theme.of(context).elevatedButtonTheme.style,
          onPressed: () {
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (context) => const AddProfile()));
          },
          child: const Text("Add Profile"),
        ),
      )
    ])));
  }
}

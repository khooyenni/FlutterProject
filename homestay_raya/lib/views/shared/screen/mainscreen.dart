import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:homestay_raya/config.dart';
import 'package:homestay_raya/models/homestay.dart';
import 'package:homestay_raya/views/shared/screen/loginscreen.dart';
import 'package:homestay_raya/views/shared/screen/newhomestayscreen.dart';

import '../../../models/user.dart';
import '../mainmenu.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ndialog/ndialog.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Position _position;
  var placemarks;
  List<Homestay> homestayList = <Homestay>[];
  String titlecenter = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadHomestay();
  }

  @override
  void dispose() {
    homestayList = [];
    print("dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          floatingActionButton: SpeedDial(
            animatedIcon: AnimatedIcons.menu_close,
            children: [
              SpeedDialChild(
                  child: const Icon(Icons.add),
                  label: "Add New Homestay",
                  labelStyle: const TextStyle(),
                  onTap: _gotoNewHomeStay),
            ],
          ),
          appBar: AppBar(title: const Text("My Homestay List"), actions: [
            PopupMenuButton(itemBuilder: (context) {
              return [
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text("Log Out"),
                ),
              ];
            }, onSelected: (value) {
              if (value == 0) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      title: const Text(
                        "Log Out",
                        style: TextStyle(),
                      ),
                      content: const Text("Are you sure want to log out?",
                          style: TextStyle()),
                      actions: <Widget>[
                        TextButton(
                          child: const Text(
                            "Yes",
                            style: TextStyle(),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (content) => const LoginScreen()));
                          },
                        ),
                        TextButton(
                          child: const Text(
                            "No",
                            style: TextStyle(),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            }),
          ]),
          body: homestayList.isEmpty
              ? Center(
                  child: Text(titlecenter,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)))
              : Column(
                  children: [
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        padding: const EdgeInsets.all(10),
                        children: List.generate(homestayList.length, (index) {
                          return Card(
                            elevation: 8,
                            child: Column(children: [
                              const SizedBox(
                                height: 8,
                              ),
                              Flexible(
                                flex: 6,
                                child: CachedNetworkImage(
                                  width: 150,
                                  fit: BoxFit.cover,
                                  imageUrl:
                                      "${Config.SERVER}/assets/homestayImages/${homestayList[index].homestayId}.1.png",
                                  placeholder: (context, url) =>
                                      const LinearProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                              Flexible(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text(homestayList[index]
                                            .homestayName
                                            .toString()),
                                        Text(
                                            "Price Per Night: RM ${homestayList[index].homestayPrice}"),
                                        Text(
                                            "Room Number: ${homestayList[index].homestayQtyroom}"),
                                      ],
                                    ),
                                  ))
                            ]),
                          );
                        }),
                      ),
                    )
                  ],
                ),
          drawer: MainMenuWidget(user: widget.user),
        ));
  }

  Future<void> _gotoNewHomeStay() async {
    if (widget.user.id == "0") {
      Fluttertoast.showToast(
          msg: "Please login/register",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    ProgressDialog progressDialog = ProgressDialog(
      context,
      blur: 10,
      message: const Text("Searching your current location"),
      title: null,
    );
    progressDialog.show();
    if (await _checkPermissionGetLoc()) {
      progressDialog.dismiss();
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (content) => NewHomeStayScreen(
                  position: _position,
                  user: widget.user,
                  placemarks: placemarks)));
      _loadHomestay();
    } else {
      Fluttertoast.showToast(
          msg: "Please allow the app to access the location",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    }
  }

  Future<bool> _checkPermissionGetLoc() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(
            msg: "Please allow the app to access the location",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
        Geolocator.openLocationSettings();
        return false;
      }
    }
    _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    try {
      placemarks = await placemarkFromCoordinates(
          _position.latitude, _position.longitude);
      setState(() {
        String loc =
            "${placemarks[0].locality},${placemarks[0].administrativeArea},${placemarks[0].country}";
        print(loc);
      });
    } catch (e) {
      Fluttertoast.showToast(
          msg:
              "Error in fixing your location. Make sure internet connection is available and try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return false;
    }
    return true;
  }

  void _loadHomestay() {
    if (widget.user.id == "0") {
      Fluttertoast.showToast(
          msg: "Please register an account first", 
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }

    http
        .get(
      Uri.parse(
          "${Config.SERVER}/php/load_seller_homestay.php?userid=${widget.user.id}"),
    )
        .then((response) {
      // wait for response from the request
      if (response.statusCode == 200) {
        //if statuscode OK
        var jsondata =
            jsonDecode(response.body); 
        if (jsondata['status'] == 'success') {
          //check if status data array is success
          var extractdata = jsondata['data']; 
          if (extractdata['homestay'] != null) {
            homestayList = <Homestay>[]; 
            extractdata['homestay'].forEach((v) {
              homestayList.add(Homestay.fromJson(
                  v)); 
            });
            titlecenter = "Found";
          } else {
            titlecenter =
                "No Homestay Available"; 
            homestayList.clear();
          }
        } else {
          titlecenter = "No Homestay Available";
        }
      } else {
        titlecenter = "No Homestay Available"; 
        homestayList.clear(); 
      }
      setState(() {});
    });
  }
}

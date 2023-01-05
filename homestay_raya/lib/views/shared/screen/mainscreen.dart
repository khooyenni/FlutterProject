import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:homestay_raya/config.dart';
import 'package:homestay_raya/models/homestay.dart';
import 'package:homestay_raya/views/shared/screen/newhomestayscreen.dart';

import '../../../models/user.dart';
import '../mainmenu.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ndialog/ndialog.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Position _position;
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
          appBar: AppBar(title: const Text("Seller"), actions: [
            PopupMenuButton(
                // add icon, by default "3 dot" icon
                // icon: Icon(Icons.book)
                itemBuilder: (context) {
              return [
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text("New Product"),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text("My Order"),
                ),
              ];
            }, onSelected: (value) {
              if (value == 0) {
                _gotoNewProduct();
                print("My account menu is selected.");
              } else if (value == 1) {
                print("Settings menu is selected.");
              } else if (value == 2) {
                print("Logout menu is selected.");
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
                                      "${Config.SERVER}/assets/homestayImages/${homestayList[index].homestayId}.png",
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
                                            "RM ${homestayList[index].homestayPrice}"),
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

  Future<void> _gotoNewProduct() async {
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
              builder: (content) =>
                  NewHomeStayScreen(position: _position, user: widget.user)));
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
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg: "Please allow the app to access the location",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      Geolocator.openLocationSettings();
      return false;
    }
    _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    return true;
  }

  void _loadHomestay() {
    if (widget.user.id == "0") {
      //check if the user is registered or not
      Fluttertoast.showToast(
          msg: "Please register an account first", //Show toast
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      // titlecenter = "Please register an account";
      // setState(() {

      // });
      return; //exit method if true
    }
    //if registered user, continue get request
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
            jsonDecode(response.body); //decode response body to jsondata array
        if (jsondata['status'] == 'success') {
          //check if status data array is success
          var extractdata = jsondata['data']; //extract data from jsondata array
          if (extractdata['homestay'] != null) {
            //check if  array object is not null
            homestayList = <Homestay>[]; //complete the array object definition
            extractdata['homestay'].forEach((v) {
              //traverse products array list and add to the list object array productList
              homestayList.add(Homestay.fromJson(
                  v)); //add each product array to the list object array productList
            });
            titlecenter = "Found";
          } else {
            titlecenter =
                "No Product Available"; //if no data returned show title center
            homestayList.clear();
          }
        } else {
          titlecenter = "No Product Available";
        }
      } else {
        titlecenter = "No Product Available"; //status code other than 200
        homestayList.clear(); //clear productList array
      }
      setState(() {}); //refresh UI
    });
  }
}

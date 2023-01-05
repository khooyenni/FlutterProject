import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:homestay_raya/config.dart';
import 'package:homestay_raya/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class NewHomeStayScreen extends StatefulWidget {
  final User user;
  final Position position;
  const NewHomeStayScreen(
      {super.key, required this.user, required this.position});

  @override
  State<NewHomeStayScreen> createState() => _NewHomeStayScreenState();
}

class _NewHomeStayScreenState extends State<NewHomeStayScreen> {
  final TextEditingController _hsnameEditingController =
      TextEditingController();
  final TextEditingController _hsdescEditingController =
      TextEditingController();
  final TextEditingController _hspriceEditingController =
      TextEditingController();
  final TextEditingController _hsqtyEditingController = TextEditingController();
  final TextEditingController _hsstateEditingController =
      TextEditingController();
  final TextEditingController _hslocalEditingController =
      TextEditingController();
  final TextEditingController _hscontactEditingController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _lat, _lng;
  List<File> imageList = [];
  

  @override
  void initState() {
    super.initState();
    // _checkPermissionGetLoc();
    _lat = widget.position.latitude.toString();
    _lng = widget.position.longitude.toString();
    _getAddress();
  }

  File? _image;
  var pathAsset = "assets/images/camera.png";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Add New HomeStay")),
        body: SingleChildScrollView(
            child: Column(
          children: [
            GestureDetector(
              onTap: _selectImageDialog,
              child: Card(
                elevation: 8,
                child: Container(
                  height: 250,
                  width: 300,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: _image == null
                        ? AssetImage(pathAsset)
                        : FileImage(_image!) as ImageProvider,
                    fit: BoxFit.scaleDown,
                  )),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                          textInputAction: TextInputAction.next,
                          controller: _hsnameEditingController,
                          validator: (val) => val!.isEmpty || (val.length < 3)
                              ? "Homestay name must be longer than 3"
                              : null,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                              labelText: 'Homestay Name',
                              labelStyle: TextStyle(),
                              icon: Icon(Icons.home),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 2.0),
                              ))),
                      TextFormField(
                          textInputAction: TextInputAction.next,
                          controller: _hsdescEditingController,
                          validator: (val) => val!.isEmpty || (val.length < 10)
                              ? "Homestay description must be longer than 10"
                              : null,
                          maxLines: 4,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                              labelText: 'Homestay Description',
                              alignLabelWithHint: true,
                              labelStyle: TextStyle(),
                              icon: Icon(
                                Icons.description_outlined,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 2.0),
                              ))),
                      Row(
                        children: [
                          Flexible(
                            flex: 5,
                            child: TextFormField(
                                textInputAction: TextInputAction.next,
                                controller: _hspriceEditingController,
                                validator: (val) => val!.isEmpty
                                    ? "Homestay price must contain value"
                                    : null,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: 'Price/Per Night',
                                    labelStyle: TextStyle(),
                                    icon: Icon(Icons.money),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 2.0),
                                    ))),
                          ),
                          Flexible(
                            flex: 5,
                            child: TextFormField(
                                textInputAction: TextInputAction.next,
                                controller: _hsqtyEditingController,
                                validator: (val) => val!.isEmpty
                                    ? "Room number should be more than 0"
                                    : null,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: 'No of Rooms',
                                    labelStyle: TextStyle(),
                                    icon: Icon(Icons.family_restroom),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 2.0),
                                    ))),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Flexible(
                              flex: 5,
                              child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  validator: (val) =>
                                      val!.isEmpty || (val.length < 3)
                                          ? "Current State"
                                          : null,
                                  enabled: false,
                                  controller: _hsstateEditingController,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                      labelText: 'Current States',
                                      labelStyle: TextStyle(),
                                      icon: Icon(Icons.flag),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(width: 2.0),
                                      )))),
                          Flexible(
                            flex: 5,
                            child: TextFormField(
                                textInputAction: TextInputAction.next,
                                enabled: false,
                                validator: (val) =>
                                    val!.isEmpty || (val.length < 3)
                                        ? "Current Locality"
                                        : null,
                                controller: _hslocalEditingController,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                    labelText: 'Current Locality',
                                    labelStyle: TextStyle(),
                                    icon: Icon(Icons.map),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 2.0),
                                    ))),
                          )
                        ],
                      ),
                      Row(children: [
                        Flexible(
                          flex: 5,
                          child: TextFormField(
                              textInputAction: TextInputAction.next,
                              controller: _hscontactEditingController,
                              validator: (val) => val!.isEmpty
                                  ? "Must be more than zero"
                                  : null,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: 'Contact Number',
                                  labelStyle: TextStyle(),
                                  icon: Icon(Icons.contact_phone),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2.0),
                                  ))),
                        ),
                      ]),
                      const SizedBox(height: 20),
                      MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5.0)),
                                    minWidth: 115,
                                    height: 50,
                                    elevation: 10,
                                    onPressed: _newHomestayDialog,
                                    color: Theme.of(context).colorScheme.primary,
                                    child: const Text('Add Homestay',
                                        style: TextStyle(color: Colors.white, fontSize: 15)),
                                  ),
                    ],
                  )),
            )
          ],
        )));
  }

  void _newHomestayDialog() {
    if (_image == null) {
      Fluttertoast.showToast(
          msg: "Please take picture of your homestay",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
          msg: "Please complete the form first",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Insert this homestay?",
            style: TextStyle(),
          ),
          content: const Text("Are you sure?", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                insertHomestay();
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

  void _selectImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
            title: const Text(
              "Select picture from:",
              style: TextStyle(),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    iconSize: 64,
                    onPressed: _onCamera,
                    icon: const Icon(Icons.camera)),
                IconButton(
                    iconSize: 64,
                    onPressed: _onGallery,
                    icon: const Icon(Icons.browse_gallery)),
              ],
            ));
      },
    );
  }

  Future<void> _onCamera() async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      cropImage();
      setState(() {});
    } else {
      print('No image selected.');
    }
  }

  Future<void> _onGallery() async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      cropImage();
      setState(() {});
    } else {
      print('No image selected.');
    }
  }

  Future<void> cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _image!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        // CropAspectRatioPreset.ratio3x2,
        // CropAspectRatioPreset.original,
        // CropAspectRatioPreset.ratio4x3,
        // CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    if (croppedFile != null) {
      File imageFile = File(croppedFile.path);
      _image = imageFile;
      setState(() {});
    }
  }

  // void _checkPermissionGetLoc() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     return Future.error('Location services are disabled.');
  //   }
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return Future.error('Location permissions are denied');
  //     }
  //   }
  //   if (permission == LocationPermission.deniedForever) {
  //     return Future.error('Location permissions are permanently denied.');
  //   }
  //   _position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //   print(_position.latitude);
  //   print(_position.longitude);
  //   _getAddress(_position);
  // }

  // _getAddress(Position pos) async {
  //   List<Placemark> placemarks =
  //       await placemarkFromCoordinates(pos.latitude, pos.longitude);
  //   setState(() {
  //     String loc = "${placemarks[0].locality},${placemarks[1].administrativeArea},${placemarks[2].country}";
  //     print(loc);
  //   });
  // }

  _getAddress() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.position.latitude, widget.position.longitude);
    setState(() {
      _hsstateEditingController.text =
          placemarks[0].administrativeArea.toString();
      _hslocalEditingController.text = placemarks[0].locality.toString();
    });
  }

  void insertHomestay() {
    String hsname = _hsnameEditingController.text;
    String hsdesc = _hsdescEditingController.text;
    String hsprice = _hspriceEditingController.text;
    String qty = _hsqtyEditingController.text;
    String state = _hsstateEditingController.text;
    String local = _hslocalEditingController.text;
    String hscontact = _hscontactEditingController.text;
    String base64Image = base64Encode(_image!.readAsBytesSync());

    http.post(Uri.parse("${Config.SERVER}/php/insert_homestay.php"), body: {
      "userid": widget.user.id,
      "hsname": hsname,
      "hsdesc": hsdesc,
      "hsprice": hsprice,
      "qty": qty,
      "state": state,
      "local": local,
      "lat": _lat,
      "lon": _lng,
      "hscontact": hscontact,
      "image": base64Image
    }).then((response) {
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == "success") {
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
        // Navigator.of(context).pop();
        return;
      } else {
        Fluttertoast.showToast(
            msg: "Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
        return;
      }
    });
  }
}

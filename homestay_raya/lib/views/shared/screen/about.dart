import 'package:flutter/material.dart';

import '../../../models/user.dart';
import '../mainmenu.dart';




class AboutScreen extends StatefulWidget {
  final User user;
  const AboutScreen({super.key, required this.user});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(title: const Text("About")),
          body: const Center(child: Text("About")),
          drawer: MainMenuWidget(user: widget.user),
        ));
  }
}
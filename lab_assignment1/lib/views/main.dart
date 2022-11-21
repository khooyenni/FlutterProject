import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Movie App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  TextEditingController title = TextEditingController();

  String desc1 = "";
  String desc2 = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Simple Movie APP",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            TextField(
              controller: title,
              decoration: InputDecoration(
                  hintText: 'First number',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0))),
            ),
            ElevatedButton(
                onPressed: _getMovie, child: const Text("Search")),
            Text(desc1,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(desc2,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> _getMovie() async {
    var apiid = "2e811de8";
    var url = Uri.parse('https://www.omdbapi.com/?t=$title&apikey=$apiid');
    var response = await http.get(url);
    var rescode = response.statusCode;
    if (rescode == 200) {
      var jsonData = response.body;
      var parsedJson = json.decode(jsonData);
      setState(() {
        title = parsedJson['Title'];
        String released = parsedJson['Released'];
        String genre = parsedJson['Genre'];
        desc1 = "$title";
        desc2 = "Released: $released, Genre: $genre";
      });
    } else {
      setState(() {
        desc1 = "No record";
        
      });
    }
  }
}

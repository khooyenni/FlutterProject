import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController textEditingController = TextEditingController();

  String name = " ";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Simple App Bar'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextField(controller: textEditingController),
              ElevatedButton(
                  onPressed: _pressme, child: const Text("Press Me")),
              Text("You have entered:$name"),
              const Text("Welcome to Flutter"),
              const Text("Flutter is fun"),
              const SizedBox(height: 8),
              const Text("Flutter will change the world",
                  style: TextStyle(
                      color: Colors.deepOrangeAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.all(20),
                color: Colors.red,
                height: 200,
                width: 200,
                child: const Text('Welcome'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pressme() {
    name = textEditingController.text;
    print(name);
    setState(() {});
  }
}

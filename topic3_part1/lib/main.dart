import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController numaController = TextEditingController();
  TextEditingController numbController = TextEditingController();

  int result = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Simple Calculator'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              color: Color.fromARGB(255, 230, 190, 233),
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/calculator.png', scale: 2.5),
                  const SizedBox(height: 8),
                  TextField(
                    controller: numaController,
                    decoration: InputDecoration(
                        hintText: 'First number',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0))),
                    keyboardType: const TextInputType.numberWithOptions(),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: numbController,
                    decoration: InputDecoration(
                        hintText: 'Second number',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0))),
                    keyboardType: const TextInputType.numberWithOptions(),
                  ),
                  ElevatedButton(
                      onPressed: _pressme, child: const Text("Press Me")),
                  Text("Result: $result", style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _pressme() {
    int a = int.parse(numaController.text);
    int b = int.parse(numbController.text);
    result = a + b;
    setState(() {});
  }
}


  


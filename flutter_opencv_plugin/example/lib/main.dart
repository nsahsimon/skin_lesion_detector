import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_opencv_plugin/flutter_opencv_plugin.dart';

void main() async{
  await Opencv().initialize();
  runApp(MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.red,
      ),
      home: const MyApp()));
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  TextEditingController num1Controller = TextEditingController();
  TextEditingController num2Controller = TextEditingController();
  double? sum;
  File? imageFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Flutter Opencv Demo App for ElpaTap", )
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Demo skin lesion detection flutter application built by Nsah Simon for Elpha Studio", textAlign: TextAlign.center,),
                imageFile != null ? Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.height * 0.6,
                  child: Image.file(imageFile!, fit: BoxFit.cover,),
                ) : Container(),
                // SizedBox(height: 10),
                // Text("Enter num1: "),
                // TextField(controller: num1Controller,),
                // SizedBox(height: 10),
                // Text("Enter num2: "),
                // TextField(controller: num2Controller,),
                // SizedBox(height: 10),
                // Text("$sum"),
                // SizedBox(height: 10),
                // ElevatedButton(
                //     onPressed: () async{
                //       double? sumTemp = await Opencv().addNumbers(num1: double.parse(num1Controller.text), num2: double.parse(num2Controller.text));
                //       setState(() {
                //         sum = sumTemp;
                //       });
                //     },
                //     child: Text("Add")
                // ),
                SizedBox(height: 10),
                ElevatedButton(
                    onPressed: () async{
                      File? result = await Opencv().liveDarkSpotDetection(context);
                      if(result == null) return;
                      setState(() {
                        imageFile = result;
                      });
                    },
                    child: Text('Camera')
                )
              ],
            )
          ),
        )
      );
  }
}


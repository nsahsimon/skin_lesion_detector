import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../constants.dart';


/// CameraApp is the Main Application.
class CameraScreen extends StatefulWidget {

  Future<dynamic> Function({ required dynamic frame}) detector;
  CameraScreen({required this.detector});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  String imagePath = "";
  bool imageTaken = false;
  List<Positioned> cornerAvatars = [];
  List<List<double>> prevCorners = [];
  List<List<double>> cornerPoints = [];
  bool isDetecting = false;
  bool detectedValidFrame = false;
  late CameraImage frame;
  double lowerBarLengthFraction = 0.4;
  int detectedSpotCount = 0;
  bool detectedValidSpot = false;

  Future<void> listenToFocusMode() async {
    while (true) {
      await Future.delayed(Duration(seconds: 1), ()  {
        if(controller != null) {
          debugPrint("Focus Mode Name: ${controller!.value.focusMode.name}");
        }

      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future(()async{
      try {
        controller = CameraController(cameras![0], ResolutionPreset.veryHigh);
      }catch(e) {
        return;
      }

      // listenToFocusMode();
      controller!.setExposureMode(ExposureMode.auto);
      controller!.setFocusMode(FocusMode.auto);

      controller?.initialize().then((_) {
        debugPrint("Started image Stream");
        controller!.startImageStream(
                (imgFrame) async{
              frame = imgFrame;
              return;
              /// Do not detect corners if already detecting corner
              //     debugPrint("Received new frame");
              int sensorExpTime = frame.sensorExposureTime ?? -1;
              if(isDetecting == true && sensorExpTime < 50000000) return;
              // debugPrint("**(NEW) SENSOR EXPOSURE TIME: ${sensorExpTime}**");
              if(mounted) {
                setState(() {
                  isDetecting = true;
                });
              }

              int start = DateTime.now().microsecondsSinceEpoch;
              cornerPoints = await widget.detector(frame: frame);
              int stop = DateTime.now().microsecondsSinceEpoch;
              // debugPrint("***(main thread) DETECTED CORNERS IN : ${(start - stop) / 1000} SECONDS****");

              // debugPrint("FOUND ${cornerPoints.length} corner points");
              double width = MediaQuery.of(context).size.width;
              double height = MediaQuery.of(context).size.height;
              cornerAvatars = [];
              for(List<double> cornerPoint in cornerPoints) {
                cornerAvatars.add(
                    Positioned(
                        left: cornerPoint[0] * width - 75 / 2,
                        top: cornerPoint[1] * height - 75 / 2,
                        child: Container(
                            height: 75,
                            width: 75,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: cornerPoints.length == 4 ? Colors.blue : Colors.red,
                                )
                            )
                        )
                      // child: Text("o", style: TextStyle(color: cornerPoints.length == 4 ? Colors.blue : Colors.red, fontSize: 30),)
                    )
                );
              }

              /// Update the list of previous corners
              prevCorners = cornerPoints;

              if(mounted) {
                setState(() {
                  isDetecting = false;
                });
              }

            }
        );

        if(mounted) {
          setState(() {
          });
        }
      });
    });

  }

  bool validateNewCorners(List<List<double>> corners) {
    //Make sure new corners are equal in number to old corners
    if(prevCorners.length != corners.length || corners.length != 4) return false;
    double prevSumX = 0;
    double prevSumY = 0;
    double sumX = 0;
    double sumY = 0;
    double maxDist = 0.01;

    for(int i = 0; i < corners.length; i++) {
      sumX += corners[i][0];
      sumY += corners[i][1];
      prevSumX += prevCorners[i][0];
      prevSumY += prevCorners[i][1];
    }

    double avgX = sumX / corners.length;
    double avgY = sumY / corners.length;
    double prevAvgX = prevSumX / corners.length;
    double prevAvgY = prevSumY / corners.length;
    double dist = sqrt(pow(avgX - prevAvgX, 2) - pow(avgY - prevAvgY, 2));
    if(dist < maxDist) return true;
    else return false;

  }

  @override
  void dispose() {
    try {
      controller!.stopImageStream();
    }catch(e) {
      debugPrint("$e");
    }
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
    }
  }


  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container();
    }
    controller!.setZoomLevel(1.6);
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: CameraPreview(controller!)),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: detectedValidSpot ? Colors.green : Colors.red, width: 5),
                        shape: BoxShape.circle
                      ),
                    )
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      color: Colors.black87.withOpacity(0.4),
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Spot detected ", style: TextStyle(color: Colors.white)),
                          SizedBox(width: 20),
                          detectedSpotCount == 0 ? Icon(Icons.close, color: Colors.red) : Icon(Icons.check, color: Colors.green)
                        ],
                      ),
                    ),
                  )

                ],
              );
            }
        ),

        // floatingActionButton: FloatingActionButton(
        //     child: Icon(Icons.camera),
        //     onPressed: () async{
        //       if(validateNewCorners(cornerPoints)) {
        //         setState((){
        //           detectedValidFrame = true;
        //         });
        //         await Future.delayed(Duration(seconds: 1));
        //         controller!.stopImageStream();
        //         Navigator.pop(context , true);
        //       }
        //     }),
      ),
    );
  }
}

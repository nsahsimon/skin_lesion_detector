import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import '../constants.dart';


/// CameraApp is the Main Application.
class CameraScreen extends StatefulWidget {

  Future<dynamic> Function({ required dynamic frame, required double roiHeightFactor, required double roiWidthFactor}) detector;
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
  late double roiWidthFactor;
  late double roiHeightFactor;
  double lowerBarLengthFraction = 0.4;
  int detectedSpotCount = 0;
  bool detectedValidSpot = false;
  List<int> prevDetectedSpotCounts = List<int>.filled(5, 0,growable: true); //Keep track of the last 10 spot counts
  int prevDetectedSpotCountIdx = 0; //has a max value of 9
  int maxIdx = 4;
  bool imageClear = false;
  bool imageInFocus = true;

  Future<void> listenToFocusMode() async {
    while (true) {
      await Future.delayed(Duration(seconds: 1), ()  {
        if(controller != null) {
          debugPrint("Focus Mode Name: ${controller!.value.focusMode.name}");
        }

      });
    }
  }

  Future<File> cropImage(File inputImage) async {
    final image = imglib.decodeImage(await inputImage.readAsBytes());
    if (image != null) {
    // Define the cropping rectangle

    final height = (image!.height * roiHeightFactor).toInt();  // Width of the cropping rectangle
    final width = (image!.width * roiWidthFactor).toInt(); // Height of the cropping rectangle
    final left = ((image!.width - width) ~/ 2);   // Left coordinate of the cropping rectangle
    final top = ((image!.height - height) ~/ 2);    // Top coordinate of the cropping rectangle


      final croppedImage = imglib.copyCrop(image, x:left, y:top, width: width, height: height);

      // Save the cropped image to a new File
      final croppedFile = File(inputImage.path.replaceAll(RegExp(r'\.\w+$'), '_cropped.png'));
      await croppedFile.writeAsBytes(imglib.encodePng(croppedImage));

      return croppedFile;
    } else {
      throw Exception('Error decoding image.');
    }
  }

  void recordSpotCount(int currentSpotCount) {
    if(currentSpotCount <= 0) {
      setState(() {
        detectedValidSpot == false;
      });
    } else {
      setState(() {
        detectedValidSpot == true;
      });
    }

    if(prevDetectedSpotCountIdx <= maxIdx) {
      prevDetectedSpotCounts[prevDetectedSpotCountIdx] = currentSpotCount;
      prevDetectedSpotCountIdx++;
    } else {
      prevDetectedSpotCounts[0] = currentSpotCount;
      prevDetectedSpotCountIdx = 1;
    }
  }

  Future<void> validateSpot() async{

    for(int i = 0 ; i < maxIdx; i++) {
      if(prevDetectedSpotCounts[i] <= 0) return;
      if(prevDetectedSpotCounts[i] != prevDetectedSpotCounts[(i + 1)%(maxIdx + 1)]) return;
    }
    controller!.stopImageStream();
    setState(() {
      isDetecting = false;
      imageClear  = true;
    });
    if(true ) {
      // controller!.stopImageStream();
      // setState(() {
      //   isDetecting = false;
      //   detectedValidSpot  = true;
      // });
      XFile image = await controller!.takePicture();
      Future.delayed(Duration(seconds: 0), () async{
        var croppedImage = await cropImage(File(image.path));
        Navigator.pop(context,croppedImage);
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


      controller?.initialize().then((_) {
        controller!.setExposureMode(ExposureMode.auto);
        controller!.setFocusMode(FocusMode.auto);
        // controller!.setFlashMode(FlashMode.torch);
        debugPrint("Started image Stream");
        controller!.startImageStream(
                (imgFrame) async{
              frame = imgFrame;
              /// Do not detect skin lesions if already detecting skin lession
              int sensorExpTime = frame.sensorExposureTime ?? -1;
              if(isDetecting == true && sensorExpTime < 50000000) return;

              if(mounted) {
                setState(() {
                  isDetecting = true;
                });
              }

              int start = DateTime.now().microsecondsSinceEpoch;
              int tempSpotCount = await widget.detector(frame: frame, roiHeightFactor: roiHeightFactor, roiWidthFactor: roiWidthFactor);
              setState(() {
                detectedSpotCount = tempSpotCount;
              });

              recordSpotCount(detectedSpotCount);

              int stop = DateTime.now().microsecondsSinceEpoch;

              await validateSpot();

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
              double displayWidth = constraints.maxWidth;
              double displayHeight = constraints.maxHeight;
              double roiWidth = MediaQuery.of(context).size.width * 0.5;
              double roiHeight = roiWidth;
              roiWidthFactor = roiWidth / displayWidth;
              roiHeightFactor = roiHeight / displayHeight;
              return Stack(
                children: [
                  Container(
                      width: displayWidth,
                      height: displayHeight,
                      child: CameraPreview(controller!)),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: roiWidth,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: detectedValidSpot ? Colors.green : Colors.red, width: 5),
                        shape: BoxShape.circle
                      ),
                    )
                  ),
                  Align(
                      alignment: Alignment.center,
                      child: Container(
                        // width: roiWidth * 9,
                        height: 1000,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: Colors.black87.withOpacity(0.5), width: roiWidth * 0.5),
                            shape: BoxShape.circle,
                        ),
                      )
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Container(


                      color: Colors.black87.withOpacity(0.4),
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          FeedbackTile(title: "Detected", state: detectedSpotCount > 0),
                          FeedbackTile(title: "Clear", state: imageClear),
                          FeedbackTile(title: "Focus", state: imageInFocus && detectedSpotCount < 3 && detectedSpotCount > 0),
                        ],
                      ),
                    ),
                  )

                ],
              );
            }
        ),

      ),
    );
  }
}

class FeedbackTile extends StatelessWidget {
  const FeedbackTile({
    super.key,
    required this.title,
    required this.state,
  });

  final bool state;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: TextStyle(color: Colors.white)),
        SizedBox(width: 20),
        state == false ? Icon(Icons.close, color: Colors.red) : Icon(Icons.check, color: Colors.green)
      ],
    );
  }
}
